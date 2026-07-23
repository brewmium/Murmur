#!/bin/zsh
# Build a release Murmur.app and install it into /Applications.
# Quits any running copy, replaces the bundle, relaunches from /Applications.
# The stable /Applications path + real signing identity keep TCC permissions
# (Mic, Input Monitoring, Accessibility) intact across deploys.
set -euo pipefail

cd "${0:a:h}/.."
SRC="build/Murmur.app"
DEST="/Applications/Murmur.app"

# Build the release bundle first (signs with a real identity if available).
./scripts/build-app.sh release

# Quit any running instance so we can overwrite the bundle cleanly.
if pgrep -x Murmur >/dev/null; then
	echo "Quitting running Murmur..."
	osascript -e 'tell application "Murmur" to quit' 2>/dev/null || pkill -x Murmur || true
	for _ in {1..20}; do
		pgrep -x Murmur >/dev/null || break
		sleep 0.25
	done
	pkill -x Murmur 2>/dev/null || true
fi

echo "Installing to $DEST"
rm -rf "$DEST"
cp -R "$SRC" "$DEST"

echo "Launching $DEST"
open "$DEST"
echo "Deployed. Murmur is running from /Applications."
