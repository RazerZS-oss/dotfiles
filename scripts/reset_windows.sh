#!/usr/bin/env bash
#
# reset_windows.sh - Emergency Window Rescue Script
# Resets all open windows back to the center of the main display.
#

echo "==> Stopping any running Paneru instances..."
killall paneru 2>/dev/null || true

echo "==> Snapping all windows back to the main screen..."
osascript <<'EOF'
tell application "System Events"
    set appList to every process whose background only is false
    repeat with theApp in appList
        try
            tell theApp
                set windowList to every window
                repeat with theWindow in windowList
                    set position of theWindow to {60, 60}
                    set size of theWindow to {1200, 800}
                end repeat
            end tell
        end try
    end repeat
end tell
EOF

echo "✅ All windows have been restored to your screen!"
