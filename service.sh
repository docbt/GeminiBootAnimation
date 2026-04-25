#!/system/bin/sh
# Gemini Boot Animation — direct-write fallback for KernelSU+SUSFS setups
MODDIR="/data/adb/modules/gemini-bootanimation"
SRC="$MODDIR/files"

[ -f "$SRC/bootanimation.zip" ] || exit 0

# Wait for full boot before attempting any write operations.
# Without this, remount silently fails on KernelSU and the files are never
# copied — causing the "needs 2 reboots" symptom.
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 3
done
sleep 3

our_size=$(stat -c %s "$SRC/bootanimation.zip" 2>/dev/null) || exit 0

try_write() {
    local dir="$1"
    [ -d "$dir" ] || return 1

    # Skip if already our version
    cur=$(stat -c %s "$dir/bootanimation.zip" 2>/dev/null) || cur=0
    [ "$cur" = "$our_size" ] && return 0

    # Try remounting: first the dir itself, then parent partition
    local parent="${dir%/*}"
    mount -o remount,rw "$dir"    2>/dev/null || \
    mount -o remount,rw "$parent" 2>/dev/null || \
    return 1

    # Copy main animation
    cp "$SRC/bootanimation.zip" "$dir/bootanimation.zip" || return 1
    chmod 644 "$dir/bootanimation.zip"

    # Remove symlink (if dark zip is symlink) and copy real file
    rm -f "$dir/bootanimation-dark.zip" 2>/dev/null
    cp "$SRC/bootanimation-dark.zip" "$dir/bootanimation-dark.zip"
    chmod 644 "$dir/bootanimation-dark.zip"

    # Remount ro
    mount -o remount,ro "$parent" 2>/dev/null || \
    mount -o remount,ro "$dir"    2>/dev/null || true
    return 0
}

try_write /product/media
try_write /system/media
