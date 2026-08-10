#!/bin/sh
# Regenerates _site with CookCLI, then re-applies the Tufte theme.
#
# `cook build web` bakes its own default custom-styles.css into the output
# on every run (it's embedded in the CLI binary, not read from any vault
# file), overwriting any hand edits made directly in _site/. So the theme
# lives in theme/custom-styles.css and gets copied back into place here.
set -e
cd "$(dirname "$0")"
cook build web
cp theme/custom-styles.css _site/static/css/custom-styles.css
cp theme/et-book-fonts.css _site/static/css/et-book-fonts.css
echo "Applied Tufte theme to _site/static/css/custom-styles.css"
