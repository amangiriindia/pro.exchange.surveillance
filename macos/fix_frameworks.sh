#!/bin/bash
# Fix malformed framework bundles (ITMS-90291) before App Store upload.
# Usage:  ./macos/fix_frameworks.sh path/to/Surveillance.app
#         (defaults to build/macos/Build/Products/Release/Surveillance.app)

set -euo pipefail

APP_PATH="${1:-build/macos/Build/Products/Release/Surveillance.app}"

if [ ! -d "$APP_PATH" ]; then
  echo "ERROR: App not found at $APP_PATH"
  exit 1
fi

FRAMEWORKS_DIR="$APP_PATH/Contents/Frameworks"
echo "Scanning $FRAMEWORKS_DIR ..."

if [ ! -d "$FRAMEWORKS_DIR" ]; then
  echo "No Frameworks directory found."
  exit 0
fi

CODESIGN_IDENTITY="${CODESIGN_IDENTITY-}"
if [ -z "$CODESIGN_IDENTITY" ]; then
  # Pick the first Developer ID / Apple Distribution identity available
  CODESIGN_IDENTITY=$(security find-identity -v -p codesigning 2>/dev/null | \
    grep -E "Apple Distribution|3rd Party Mac Developer Application|Developer ID Application" | \
    head -n1 | sed -E 's/.*"([^"]+)".*/\1/' || true)
fi
echo "Using codesign identity: ${CODESIGN_IDENTITY:-<none, will skip resign>}"

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

  # 5) Re-sign the framework so the new structure is valid
  if [ -n "$CODESIGN_IDENTITY" ]; then
    codesign --force --sign "$CODESIGN_IDENTITY" --timestamp --options runtime "$fw"
    echo "   ✓ re-signed"
  fi
}

for fw in "$FRAMEWORKS_DIR"/*.framework; do
  [ -d "$fw" ] || continue
  fix_framework "$fw"
done

# Re-sign the outer app last so the changed framework hashes are recorded.
if [ -n "$CODESIGN_IDENTITY" ]; then
  echo ""
  echo "Re-signing $APP_PATH ..."
  codesign --force --deep --sign "$CODESIGN_IDENTITY" --timestamp --options runtime "$APP_PATH"
  echo "✓ App re-signed."
fi

echo ""
echo "Done. Verify with:  codesign --verify --deep --strict --verbose=2 \"$APP_PATH\""
