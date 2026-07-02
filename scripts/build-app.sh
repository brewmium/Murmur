#!/bin/zsh
# Assemble Murmur.app from the SPM build product.
# Usage: scripts/build-app.sh [debug|release]   (default: release)
set -euo pipefail

cd "${0:a:h}/.."
CONFIG="${1:-release}"
APP="build/Murmur.app"

swift build -c "$CONFIG"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp ".build/$CONFIG/Murmur" "$APP/Contents/MacOS/Murmur"
cp Support/Info.plist "$APP/Contents/Info.plist"

# SPM resource bundles from dependencies must live in Contents/Resources
for b in .build/"$CONFIG"/*.bundle(N); do
	cp -R "$b" "$APP/Contents/Resources/"
done

# A real identity keeps the TCC (permissions) identity stable across rebuilds;
# ad-hoc signatures change every build and macOS silently drops granted permissions.
IDENTITY="$(security find-identity -v -p codesigning 2>/dev/null | awk -F'"' '/Apple Development|Developer ID Application/ {print $2; exit}')"
if [[ -n "${IDENTITY:-}" ]]; then
	echo "Signing with: $IDENTITY"
	codesign --force --sign "$IDENTITY" "$APP"
else
	echo "No signing identity found; signing ad-hoc (re-grant permissions after each rebuild)"
	codesign --force --sign - "$APP"
fi

echo "Built $APP"
