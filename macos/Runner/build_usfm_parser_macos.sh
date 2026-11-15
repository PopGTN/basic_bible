#!/bin/sh
set -e

PROJECT_DIR_INPUT="$1"
APP_BUNDLE_INPUT="$2"

if [ -z "$PROJECT_DIR_INPUT" ] || [ -z "$APP_BUNDLE_INPUT" ]; then
  echo "USFM parser build script requires PROJECT_DIR and APP_BUNDLE paths." >&2
  exit 1
fi

if ! command -v cargo >/dev/null 2>&1; then
  echo "warning: cargo not found; skipping native USFM parser build for macOS." >&2
  exit 0
fi

PROJECT_DIR_ABS="$(cd "$PROJECT_DIR_INPUT" && pwd)"
REPO_ROOT="$(cd "$PROJECT_DIR_ABS/.." && pwd)"
APP_BUNDLE_ABS="$(cd "$(dirname "$APP_BUNDLE_INPUT")" && pwd)/$(basename "$APP_BUNDLE_INPUT")"

PROFILE_DIR="debug"
PROFILE_FLAG=""
case "${CONFIGURATION:-Debug}" in
  Release|Profile)
    PROFILE_DIR="release"
    PROFILE_FLAG="--release"
    ;;
esac

echo "Building native USFM parser for macOS (${CONFIGURATION:-Debug})..."
cargo build --manifest-path "$REPO_ROOT/native/usfm_parser/Cargo.toml" $PROFILE_FLAG

SOURCE_LIB="$REPO_ROOT/native/usfm_parser/target/$PROFILE_DIR/libbasic_bible_usfm_parser.dylib"
DEST_DIR="$APP_BUNDLE_ABS/Contents/Frameworks"
DEST_LIB="$DEST_DIR/libbasic_bible_usfm_parser.dylib"

if [ ! -f "$SOURCE_LIB" ]; then
  echo "warning: expected native USFM parser library not found at $SOURCE_LIB" >&2
  exit 0
fi

mkdir -p "$DEST_DIR"
cp -f "$SOURCE_LIB" "$DEST_LIB"
echo "Bundled native USFM parser at $DEST_LIB"
