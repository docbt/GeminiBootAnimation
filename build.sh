#!/usr/bin/env bash
# Build script — generates all GeminiBootAnimation variant zips
# Usage: ./build.sh
set -e

VERSION=$(grep '^version=' module.prop | cut -d= -f2)
OUT="dist"
mkdir -p "$OUT"

ANIM="system/media/bootanimation.zip"
ANIM_DARK="system/media/bootanimation-dark.zip"

build_variant() {
    local NAME="$1"       # e.g. standard
    local DESC="$2"       # description for module.prop
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

    # Always install to product/media (Android 9+, higher priority)
    mkdir -p "$TMPDIR/product/media"
    cp "$ANIM"      "$TMPDIR/product/media/bootanimation.zip"
    cp "$ANIM_DARK" "$TMPDIR/product/media/bootanimation-dark.zip"

    # Always install to system/media (fallback)
    mkdir -p "$TMPDIR/system/media"
    cp "$ANIM"      "$TMPDIR/system/media/bootanimation.zip"
    cp "$ANIM_DARK" "$TMPDIR/system/media/bootanimation-dark.zip"

    # Extra variant-specific paths
    for EXTRA in $EXTRA_PATHS; do
        mkdir -p "$TMPDIR/$EXTRA"
        cp "$ANIM"      "$TMPDIR/$EXTRA/bootanimation.zip"
        cp "$ANIM_DARK" "$TMPDIR/$EXTRA/bootanimation-dark.zip"
    done

    # Build update-binary
    local PERM_LINES="set_perm_recursive \"\$MODPATH/product/media\" root root 0755 0644"$'\n'
    PERM_LINES+="  set_perm_recursive \"\$MODPATH/system/media\" root root 0755 0644"
    for EXTRA in $EXTRA_PATHS; do
        PERM_LINES+=$'\n'"  set_perm_recursive \"\$MODPATH/${EXTRA}\" root root 0755 0644"
    done

    # Collect all top-level dirs to extract
    local DIRS="product/* system/*"
    for EXTRA in $EXTRA_PATHS; do
        DIRS+=" $(echo "$EXTRA" | cut -d/ -f1)/*"
    done

    cat > "$TMPDIR/META-INF/com/google/android/update-binary" <<SCRIPT
#!/sbin/sh
SKIPUNZIP=1
unzip -o "\$ZIPFILE" 'product/*' -d "\$MODPATH"
unzip -o "\$ZIPFILE" 'system/*' -d "\$MODPATH"
SCRIPT

    for EXTRA in $EXTRA_PATHS; do
        local TOP
        TOP=$(echo "$EXTRA" | cut -d/ -f1)
        echo "unzip -o \"\$ZIPFILE\" '${TOP}/*' -d \"\$MODPATH\"" \
            >> "$TMPDIR/META-INF/com/google/android/update-binary"
    done

    cat >> "$TMPDIR/META-INF/com/google/android/update-binary" <<SCRIPT
set_perm_recursive "\$MODPATH/product/media" root root 0755 0644
set_perm_recursive "\$MODPATH/system/media" root root 0755 0644
SCRIPT

    for EXTRA in $EXTRA_PATHS; do
        echo "set_perm_recursive \"\$MODPATH/${EXTRA}\" root root 0755 0644" \
            >> "$TMPDIR/META-INF/com/google/android/update-binary"
    done

    # Pack zip
    (cd "$TMPDIR" && zip -r9 - .) > "$OUTZIP"
    rm -rf "$TMPDIR"
    echo "Built: $OUTZIP"
}

# ── Variants ──────────────────────────────────────────────────────────────────

build_variant "standard" \
    "Gemini Boot Animation — Standard (Pixel / AOSP / OnePlus / Realme)" \
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
