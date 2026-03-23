#!/usr/bin/env bash
# Build script — generates all GeminiBootAnimation variant zips
# v1.3: added Motorola (oem/media) and EMUI (system/etc/media) variants
# Usage: ./build.sh
set -e

VERSION=$(grep '^version=' module.prop | cut -d= -f2)
OUT="dist"
mkdir -p "$OUT"

ANIM="system/media/bootanimation.zip"
ANIM_DARK="system/media/bootanimation-dark.zip"

build_variant() {
    local NAME="$1"              # e.g. standard
    local DESC="$2"              # description for module.prop
    local EXTRA_DIRS="$3"        # space-separated extra magic-mount dirs (relative)
    local SERVICE_EXTRA="$4"     # space-separated extra absolute paths for service.sh try_write

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

    # Magic mount dirs — populated by update-binary at install time (not in ZIP)
    local ALL_DIRS="product/media system/media system/product/media"
    for D in $EXTRA_DIRS; do
        ALL_DIRS="$ALL_DIRS $D"
    done

    # ── service.sh ───────────────────────────────────────────────────────────
    # Fallback for KernelSU + SUSFS setups where magic mount is hidden from
    # system processes. Tries to write directly to the partition (works when
    # dm-verity is disabled, e.g. crDroid). Runs after every boot — safe to
    # call repeatedly (skips if sizes already match).
    cat > "$TMPDIR/service.sh" <<'SERVICESH'
#!/sbin/sh
# Gemini Boot Animation — direct-write fallback for KernelSU+SUSFS setups
MODDIR="${0%/*}"
SRC="$MODDIR/files"

[ -f "$SRC/bootanimation.zip" ] || exit 0

our_size=$(stat -c %s "$SRC/bootanimation.zip" 2>/dev/null) || exit 0

try_write() {
    local dir="$1"
    [ -d "$dir" ] || return 1

    # Skip if already our version
    cur=$(stat -c %s "$dir/bootanimation.zip" 2>/dev/null) || cur=0
    [ "$cur" = "$our_size" ] && return 0

    # Attempt remount rw
    mount -o remount,rw "$dir" 2>/dev/null || return 1

    cp "$SRC/bootanimation.zip"      "$dir/bootanimation.zip"
    cp "$SRC/bootanimation-dark.zip" "$dir/bootanimation-dark.zip"
    chmod 644 "$dir/bootanimation.zip" "$dir/bootanimation-dark.zip"

    mount -o remount,ro "$dir" 2>/dev/null || true
}

try_write /product/media
try_write /system/media
SERVICESH

    for P in $SERVICE_EXTRA; do
        echo "try_write ${P}" >> "$TMPDIR/service.sh"
    done

    chmod 755 "$TMPDIR/service.sh"

    # ── update-binary (installer) ─────────────────────────────────────────────
    cat > "$TMPDIR/META-INF/com/google/android/update-binary" <<UBEOF
#!/sbin/sh
SKIPUNZIP=1

# ── Environment detection ────────────────────────────────────────────────────
ROOT_IMPL="Magisk"
SUSFS_ACTIVE=false

if [ "\$KSU" = "true" ]; then
    ROOT_IMPL="KernelSU"
    if [ -e "/proc/sys/fs/susfs_enabled" ] || \
       grep -q "susfs" /proc/version 2>/dev/null || \
       [ -e "/sys/kernel/sus_su" ]; then
        SUSFS_ACTIVE=true
        ROOT_IMPL="KernelSU + SUSFS"
    fi
fi

ui_print "- Gemini Boot Animation ${VERSION}"
ui_print "  Root: \$ROOT_IMPL"

# ── Extract files ────────────────────────────────────────────────────────────
ui_print "  Extracting..."
unzip -o "\$ZIPFILE" 'files/*'    -d "\$MODPATH" || { ui_print "! Extract failed"; exit 1; }
unzip -o "\$ZIPFILE" 'service.sh' -d "\$MODPATH" || { ui_print "! service.sh missing"; exit 1; }

# ── Magic mount structure (copy from files/ to each target dir) ──────────────
UBEOF

    for D in $ALL_DIRS; do
        cat >> "$TMPDIR/META-INF/com/google/android/update-binary" <<MMSCRIPT
ui_print "  -> \$MODPATH/${D}"
mkdir -p "\$MODPATH/${D}"
cp "\$MODPATH/files/bootanimation.zip"      "\$MODPATH/${D}/bootanimation.zip"
cp "\$MODPATH/files/bootanimation-dark.zip" "\$MODPATH/${D}/bootanimation-dark.zip"
MMSCRIPT
    done

    cat >> "$TMPDIR/META-INF/com/google/android/update-binary" <<'UBEFOOTER'

# ── Permissions ──────────────────────────────────────────────────────────────
set_perm_recursive "$MODPATH" root root 0755 0644
chmod 755 "$MODPATH/service.sh"

# ── Summary ──────────────────────────────────────────────────────────────────
if [ "$SUSFS_ACTIVE" = "true" ]; then
    ui_print "  SUSFS detected — service.sh will write directly on first boot"
else
    ui_print "  Magic Mount active"
fi
ui_print "- Done. Reboot to apply."
UBEFOOTER

    # Pack zip
    (cd "$TMPDIR" && zip -r9 - .) > "$OUTZIP"
    rm -rf "$TMPDIR"
    echo "Built: $OUTZIP"
}

# ── Variants ──────────────────────────────────────────────────────────────────

build_variant "standard" \
    "Gemini Boot Animation v1.3 — Standard (Pixel / AOSP / crDroid / OnePlus / Realme)" \
    "" \
    ""

build_variant "MIUI" \
    "Gemini Boot Animation v1.3 — Xiaomi MIUI (all MIUI media paths)" \
    "system_ext/media system/media/theme" \
    ""

build_variant "MTK" \
    "Gemini Boot Animation v1.3 — MediaTek (custom/media priority path)" \
    "custom/media" \
    ""

build_variant "Motorola" \
    "Gemini Boot Animation v1.3 — Motorola (oem/media partition path)" \
    "oem/media" \
    "/oem/media"

build_variant "EMUI" \
    "Gemini Boot Animation v1.3 — Huawei EMUI (system/etc/media path)" \
    "system/etc/media" \
    "/system/etc/media"

echo ""
echo "Done. Zips in $OUT/:"
ls -lh "$OUT/"
