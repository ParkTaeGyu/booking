#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.38.7"
ARCHIVE_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

curl -fsSL "$ARCHIVE_URL" -o flutter.tar.xz

tar -xf flutter.tar.xz

export PATH="$PWD/flutter/bin:$PATH"

flutter --version

flutter build web \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
