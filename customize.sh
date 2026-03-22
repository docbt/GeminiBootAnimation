##########################################################################################
# Gemini Boot Animation — Customize Script
##########################################################################################

SKIPUNZIP=1

ui_print ""
ui_print "****************************"
ui_print "   Gemini Boot Animation"
ui_print "   by docbt"
ui_print "****************************"
ui_print ""
ui_print "- Device: $(getprop ro.product.model)"
ui_print "- Android: $(getprop ro.build.version.release)"
ui_print ""

# Extract system files
ui_print "- Extracting animation files..."
unzip -o "$ZIPFILE" 'system/*' -d "$MODPATH" >&2

if [ ! -f "$MODPATH/system/media/bootanimation.zip" ]; then
  abort "- ERROR: bootanimation.zip not found!"
fi

ui_print "- Setting permissions..."
set_perm_recursive "$MODPATH/system/media" root root 0644 0644
set_perm "$MODPATH/system/media/bootanimation.zip" root root 0644

ui_print ""
ui_print "- Installation complete!"
ui_print "- Reboot to enjoy your new Gemini Boot Animation."
ui_print ""
