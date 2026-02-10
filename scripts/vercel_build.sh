#!/bin/sh
set -eux

if [ -d flutter ]; then
  cd flutter
  git fetch --depth 1 origin stable
  git reset --hard FETCH_HEAD
  cd ..
else
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git
fi

./flutter/bin/flutter --version
./flutter/bin/flutter config --enable-web

./flutter/bin/flutter build web --release --web-renderer html \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
