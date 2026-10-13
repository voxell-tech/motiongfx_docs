#!/bin/sh
# Builds js_motiongfx for the browser and copies the output into
# assets/wasm/, where the site actually serves it from. `tola dev`
# doesn't know js_motiongfx exists, it only watches Typst/asset files,
# so this has to be run by hand after changing js_motiongfx/src/.
#
# The JS glue is copied in as .mjs: it uses `import.meta`, which Tola
# 0.8's minifier only accepts in a file it knows is a module.
set -eu

cd "$(dirname "$0")/../js_motiongfx"
wasm-pack build --target web --out-dir pkg --out-name js_motiongfx

cp pkg/js_motiongfx.js ../assets/wasm/js_motiongfx.mjs
cp pkg/js_motiongfx_bg.wasm ../assets/wasm/

echo "Copied js_motiongfx into assets/wasm/. Run 'tola build' or let 'tola dev' pick it up."
