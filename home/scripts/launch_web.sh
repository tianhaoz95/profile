#!/bin/bash
# Get the absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The project root (home/) is one level up from scripts/
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Launching Flutter web in server mode with cross-origin isolation headers..."
echo "Project root: $PROJECT_ROOT"

cd "$PROJECT_ROOT"
flutter run \
  --web-header=Cross-Origin-Opener-Policy=same-origin \
  --web-header=Cross-Origin-Embedder-Policy=require-corp \
  -d web-server \
  "$@"
