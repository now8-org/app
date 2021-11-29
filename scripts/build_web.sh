#!/bin/sh
# Downloads WASM locally
# Temporary solution until https://github.com/flutter/flutter/issues/70101 and 77580 provide a better way
flutter build web
wasmLocation=$(grep canvaskit-wasm build/web/main.dart.js | sed -e "s/.*https/https/g" -e "s/\\/bin.*/\\/bin/" | uniq)
echo "Downloading WASM from $wasmLocation"
curl -o build/web/canvaskit.js "$wasmLocation/canvaskit.js"
curl -o build/web/canvaskit.wasm "$wasmLocation/canvaskit.wasm"
sed -i -e "s!$wasmLocation!.!" \
  build/web/main.dart.js
