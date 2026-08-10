#!/bin/sh
# Regenerates _site with CookCLI, then re-applies the Tufte theme.
#
# `cook build web` bakes its own default custom-styles.css into the output
# on every run (it's embedded in the CLI binary, not read from any vault
# file), overwriting any hand edits made directly in _site/. So the theme
# lives in theme/custom-styles.css and gets copied back into place here.
#
# Only a hand-picked subset of recipes in this vault is meant to be public.
# `cook build web` has no include/exclude flag and never wipes stale pages
# from a previous build, so we stage just the published recipes in a scratch
# directory, wipe _site, and build from that instead of the whole vault.
set -e
cd "$(dirname "$0")"

PUBLISHED="
Veggie Lasagna.cook
Charred Salsa Verde.cook
Peach, Cucumber and Mozzarella Salad With Gochujang Vinaigrette.cook
Roasted Tomato Tart With Ricotta and Pesto.cook
"

STAGING=$(mktemp -d)
trap 'rm -rf "$STAGING"' EXIT
echo "$PUBLISHED" | while IFS= read -r recipe; do
  [ -z "$recipe" ] && continue
  cp "$recipe" "$STAGING/"
done

rm -rf _site
cook build web --base-path "$STAGING" _site
cp theme/custom-styles.css _site/static/css/custom-styles.css
cp theme/et-book-fonts.css _site/static/css/et-book-fonts.css
echo "Applied Tufte theme to _site/static/css/custom-styles.css"
