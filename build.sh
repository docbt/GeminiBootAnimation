#!/usr/bin/env bash
# Build script — generates all GeminiBootAnimation variant zips
# Files are stored once and copied to target paths by the install script.
# Usage: ./build.sh
set -e

VERSION=$(grep '^version=' module.prop | cut -d= -f2)
OUT="dist"
mkdir -p "$OUT"

ANIM="system/media/bootanimation.zip"
ANIM_DARK="system/media/bootanimation-dark.zip"

build_variant() {
    local NAME="$1"        # e.g. standard
    local DESC="$2"        # description for module.prop
    local EXTRA_PATHS="$3" # space-separated extra target dirs (relative, no leading slash)

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

    # Store animation files only once
    mkdir -p "$TMPDIR/files"
    cp "$ANIM"      "$TMPDIR/files/bootanimation.zip"
    cp "$ANIM_DARK" "$TMPDIR/files/bootanimation-dark.zip"

    # Build install paths list:
    # - product/media          (standard separate /product partition)
    # - system/product/media   (ROMs where /product is symlinked under /system)
    # - system/media           (legacy fallback)
    local ALL_PATHS="product/media system/product/media system/media"
    for EXTRA in $EXTRA_PATHS; do
        ALL_PATHS="$ALL_PATHS $EXTRA"
    done

    # Build update-binary — extract once, cp to each target path
    cat > "$TMPDIR/META-INF/com/google/android/update-binary" <<'HEADER'
#!/sbin/sh
SKIPUNZIP=1

ui_print "- Installing Gemini Boot Animation..."
ui_print "  Module path: $MODPATH"

# Extract source files
unzip -o "$ZIPFILE" 'files/*' -d "$MODPATH" \
  && ui_print "  Files extracted." \
  || { ui_print "! ERROR: failed to extract files"; exit 1; }
HEADER

    for TARGET in $ALL_PATHS; do
        cat >> "$TMPDIR/META-INF/com/google/android/update-binary" <<SCRIPT

ui_print "  -> \$MODPATH/${TARGET}"
mkdir -p "\$MODPATH/${TARGET}"
cp "\$MODPATH/files/bootanimation.zip"      "\$MODPATH/${TARGET}/bootanimation.zip" \
  || ui_print "  ! copy failed for ${TARGET}/bootanimation.zip"
cp "\$MODPATH/files/bootanimation-dark.zip" "\$MODPATH/${TARGET}/bootanimation-dark.zip" \
  || ui_print "  ! copy failed for ${TARGET}/bootanimation-dark.zip"
SCRIPT
    done

    cat >> "$TMPDIR/META-INF/com/google/android/update-binary" <<'FOOTER'

# Remove staging dir — not needed on device
rm -rf "$MODPATH/files"

# Permissions: dirs 0755, files 0644, owner root:root
set_perm_recursive "$MODPATH" root root 0755 0644

# Fix SELinux context so bootanimation service can read the files
# (chcon may not exist on all recoveries — ignore errors)
chcon -R u:object_r:bootanim_data_file:s0 "$MODPATH" 2>/dev/null || true

ui_print "- Done. Reboot to see the animation."
FOOTER

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
    "system_ext/media system/media/theme"

build_variant "MTK" \
    "Gemini Boot Animation — MediaTek (custom/media priority path)" \
    "custom/media"

echo ""
echo "Done. Zips in $OUT/:"
ls -lh "$OUT/"
