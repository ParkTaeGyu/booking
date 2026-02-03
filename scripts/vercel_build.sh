#!/bin/sh
set -eu

FLUTTER_VERSION="3.38.7"
ARCHIVE_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

python3 - <<PY
import tarfile
import urllib.request

url = "${ARCHIVE_URL}"
archive = "flutter.tar.xz"
urllib.request.urlretrieve(url, archive)
with tarfile.open(archive) as tar:
    tar.extractall()
PY

export PATH="$PWD/flutter/bin:$PATH"

flutter --version

flutter build web \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
