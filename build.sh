#!/bin/bash

echo "Building WarmBar..."

# Compile the Swift code
swiftc main.swift \
  -o WarmBar.app/Contents/MacOS/WarmBar \
  -framework SwiftUI \
  -framework AppKit \
  -framework CoreGraphics

# Make it executable
chmod +x WarmBar.app/Contents/MacOS/WarmBar

# Optional: Ad-hoc sign to reduce warnings
codesign --force --deep --sign - WarmBar.app

echo "Build complete! Run with: open WarmBar.app"
