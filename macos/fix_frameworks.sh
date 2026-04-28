#!/bin/bash
# Fix malformed framework bundles (ITMS-90291) before App Store upload.
# Usage:
#   ./macos/fix_frameworks.sh path/to/Surveillance.app
#   ./macos/fix_frameworks.sh path/to/Some.framework
#
# For Xcode archive, this script is run as a build phase and receives:
#   "$TARGET_BUILD_DIR/$WRAPPER_NAME"

set -euo pipefail

TARGET_PATH="${1:-build/macos/Build/Products/Release/Surveillance.app}"

if [ ! -e "$TARGET_PATH" ]; then
  echo "ERROR: Target path not found at $TARGET_PATH"
  exit 1
fi

if [ -d "$TARGET_PATH/Contents/Frameworks" ]; then
  FRAMEWORKS_DIR="$TARGET_PATH/Contents/Frameworks"
elif [[ "$TARGET_PATH" == *.framework ]] && [ -d "$TARGET_PATH" ]; then
  FRAMEWORKS_DIR=""
else
  echo "ERROR: Unsupported target. Provide an .app or .framework path."
  exit 1
fi

fix_framework() {
  local fw="$1"
  local name
  name=$(basename "$fw" .framework)
  echo ""
  echo "→ $name.framework"

  if [ ! -d "$fw/Versions/A" ]; then
    echo "   Not a versioned bundle, skipping."
    return
  fi

  pushd "$fw" > /dev/null

  # 1) Versions/Current -> A
  if [ ! -L "Versions/Current" ] || [ "$(readlink Versions/Current)" != "A" ]; then
    rm -rf "Versions/Current"
    ln -s "A" "Versions/Current"
    echo "   ✓ Versions/Current -> A"
  fi

  # 2) Top-level binary symlink (must point to Versions/Current/<name>)
  if [ -f "Versions/A/$name" ]; then
    if [ ! -L "$name" ] || [ "$(readlink "$name")" != "Versions/Current/$name" ]; then
      rm -rf "$name"
      ln -s "Versions/Current/$name" "$name"
      echo "   ✓ $name -> Versions/Current/$name"
    fi
  fi

  # 3) Resources symlink (the main culprit for ITMS-90291).
  #    Must be a symlink pointing to Versions/Current/Resources — not
  #    Versions/A/Resources, and not a real directory.
  if [ -d "Versions/A/Resources" ]; then
    if [ ! -L "Resources" ] || [ "$(readlink Resources)" != "Versions/Current/Resources" ]; then
      rm -rf "Resources"
      ln -s "Versions/Current/Resources" "Resources"
      echo "   ✓ Resources -> Versions/Current/Resources"
    fi
  else
    # Some Flutter plugin frameworks ship Resources at top level only.
    # Move it inside Versions/A and create the symlink.
    if [ -d "Resources" ] && [ ! -L "Resources" ]; then
      mv "Resources" "Versions/A/Resources"
      ln -s "Versions/Current/Resources" "Resources"
      echo "   ✓ moved Resources into Versions/A and created symlink"
    fi
  fi

  # 4) Headers / Modules (if present) — also must point to Versions/Current
  for dir in Headers Modules; do
    if [ -d "Versions/A/$dir" ]; then
      if [ ! -L "$dir" ] || [ "$(readlink "$dir")" != "Versions/Current/$dir" ]; then
        rm -rf "$dir"
        ln -s "Versions/Current/$dir" "$dir"
        echo "   ✓ $dir -> Versions/Current/$dir"
      fi
    fi
  done

  popd > /dev/null

}

if [ -n "$FRAMEWORKS_DIR" ]; then
  echo "Scanning $FRAMEWORKS_DIR ..."
  if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo "No Frameworks directory found."
    exit 0
  fi
  for fw in "$FRAMEWORKS_DIR"/*.framework; do
    [ -d "$fw" ] || continue
    fix_framework "$fw"
  done
else
  echo "Scanning $TARGET_PATH ..."
  fix_framework "$TARGET_PATH"
fi

echo ""
echo "Done."
