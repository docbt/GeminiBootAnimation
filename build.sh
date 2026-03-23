#!/usr/bin/env bash
# Build script — generates all GeminiBootAnimation variant zips
# Uses post-fs-data.sh bind-mounts for reliable bootanimation replacement.
# Usage: ./build.sh
set -e

VERSION=$(grep '^version=' module.prop | cut -d= -f2)
OUT="dist"
mkdir -p "$OUT"

ANIM="system/media/bootanimation.zip"
ANIM_DARK="system/media/bootanimation-dark.zip"

build_variant() {
    local NAME="$1"         # e.g. standard
    local DESC="$2"         # description for module.prop
    local EXTRA_DIRS="$3"   # space-separated extra bind-mount dirs (absolute paths)

    local TMPDIR
    TMPDIR=$(mktemp -d)
    local OUTZIP="$OUT/GeminiBootAnimation-${NAME}-${VERSION}.zip"

    # META-INF
    mkdir -p "$TMPDIR/META-INF/com/google/android"
    cp META-INF/com/google/android/updater-script \
       "$TMPDIR/META-INF/com/google/android/updater-script"

    # module.prop
    sed "s|^description=.*|description=${DESC}|" module.prop \
        > "$TMPDIR/module.prop"

    # Animation files stored once under files/
    mkdir -p "$TMPDIR/files"
    cp "$ANIM"      "$TMPDIR/files/bootanimation.zip"
    cp "$ANIM_DARK" "$TMPDIR/files/bootanimation-dark.zip"

    # ── update-binary (installer) ─────────────────────────────────────────────
    cat > "$TMPDIR/META-INF/com/google/android/update-binary" <<'EOF'
#!/sbin/sh
SKIPUNZIP=1

ui_print "- Gemini Boot Animation installer"
ui_print "  MODPATH: $MODPATH"

# Extract animation files
unzip -o "$ZIPFILE" 'files/*' -d "$MODPATH" \
  && ui_print "  Files extracted OK." \
  || { ui_print "! ERROR: extraction failed"; exit 1; }

# Set permissions
set_perm_recursive "$MODPATH/files" root root 0755 0644
set_perm "$MODPATH/post-fs-data.sh" root root 0755
chmod 755 "$MODPATH/post-fs-data.sh"

ui_print "- Done. post-fs-data.sh will bind-mount on next boot."
EOF

    # ── post-fs-data.sh (runs before bootanimation, applies bind mounts) ──────
    # Build list of absolute target directories
    local ALL_DIRS="/system/media /product/media /system/product/media"
    for D in $EXTRA_DIRS; do
        ALL_DIRS="$ALL_DIRS $D"
    done

    cat > "$TMPDIR/post-fs-data.sh" <<POSTFS
#!/sbin/sh
# Bind-mount Gemini bootanimation over system paths.
# Runs in post-fs-data phase — before bootanimation service starts.
MODDIR="\${0%/*}"
SRC="\$MODDIR/files"

bind_anim() {
    local dir="\$1"
    [ -d "\$dir" ] || return 0
    for f in bootanimation.zip bootanimation-dark.zip; do
        [ -f "\$dir/\$f" ] || continue
        [ -f "\$SRC/\$f" ]  || continue
        mount --bind "\$SRC/\$f" "\$dir/\$f" \\
          && log -t GeminiAnim "bind OK: \$dir/\$f" \\
          || log -t GeminiAnim "bind FAIL: \$dir/\$f"
    done
}

POSTFS

    for D in $ALL_DIRS; do
        echo "bind_anim \"${D}\"" >> "$TMPDIR/post-fs-data.sh"
    done

    chmod 755 "$TMPDIR/post-fs-data.sh"

    # Pack zip
    (cd "$TMPDIR" && zip -r9 - .) > "$OUTZIP"
    rm -rf "$TMPDIR"
    echo "Built: $OUTZIP"
}

# ── Variants ──────────────────────────────────────────────────────────────────

build_variant "standard" \
    "Gemini Boot Animation — Standard (Pixel / AOSP / crDroid / OnePlus / Realme)" \
    ""

build_variant "MIUI" \
    "Gemini Boot Animation — Xiaomi MIUI (all MIUI media paths)" \
    "/system_ext/media /system/media/theme"

build_variant "MTK" \
    "Gemini Boot Animation — MediaTek (custom/media priority path)" \
    "/custom/media"

echo ""
echo "Done. Zips in $OUT/:"
ls -lh "$OUT/"
