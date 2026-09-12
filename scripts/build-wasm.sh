#!/bin/sh
# Builds js_motiongfx for the browser and copies the output into
# assets/wasm/, where the site actually serves it from. `tola serve`
# doesn't know js_motiongfx exists, it only watches Typst/asset files,
# so this has to be run by hand after changing js_motiongfx/src/.
set -eu

cd "$(dirname "$0")/../js_motiongfx"
wasm-pack build --target web --out-dir pkg --out-name js_motiongfx

cp pkg/js_motiongfx.js pkg/js_motiongfx_bg.wasm ../assets/wasm/

echo "Copied js_motiongfx into assets/wasm/. Run 'tola build' or let 'tola serve' pick it up."
