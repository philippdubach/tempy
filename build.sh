#!/bin/bash
# Quick build script for Tempy

set -e

cd "$(dirname "$0")"

echo "Building Tempy..."
xcodebuild -project Tempy.xcodeproj \
           -scheme Tempy \
           -configuration Release \
           clean build

# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Tempy.app" -path "*/Release/*" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "Error: Could not find built app"
    exit 1
fi

echo "Installing to /Applications..."
cp -R "$APP_PATH" /Applications/
xattr -cr /Applications/Tempy.app

echo "Done! Launch from Applications folder."

