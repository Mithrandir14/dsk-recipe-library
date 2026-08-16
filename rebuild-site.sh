#!/bin/sh
# Regenerates _site with CookCLI, then re-applies the Tufte theme.
#
# `cook build web` bakes its own default custom-styles.css, favicon set, and
# per-page <title> suffix into the output on every run (they're embedded in
# the CLI binary, not read from any vault file), overwriting any hand edits
# made directly in _site/. So the theme, favicon set, and site name live
# under theme/ and get reapplied here after each build.
#
# Only a hand-picked subset of recipes in this vault is meant to be public.
# `cook build web` has no include/exclude flag and never wipes stale pages
# from a previous build, so we stage just the published recipes in a scratch
# directory, wipe _site, and build from that instead of the whole vault.
set -e

SITE_NAME="Akshayapatra"
cd "$(dirname "$0")"

PUBLISHED="
Veggie Lasagna.cook
Charred Salsa Verde.cook
Peach, Cucumber and Mozzarella Salad With Gochujang Vinaigrette.cook
Roasted Tomato Tart With Ricotta and Pesto.cook
To try/Pasta with Saffron, Corn, and Harissa Breadcrumbs.cook
"

STAGING=$(mktemp -d)
trap 'rm -rf "$STAGING"' EXIT
echo "$PUBLISHED" | while IFS= read -r recipe; do
  [ -z "$recipe" ] && continue
  mkdir -p "$STAGING/$(dirname "$recipe")"
  cp "$recipe" "$STAGING/$recipe"
done

rm -rf _site
cook build web --base-path "$STAGING" _site
cp theme/custom-styles.css _site/static/css/custom-styles.css
cp theme/et-book-fonts.css _site/static/css/et-book-fonts.css
echo "Applied Tufte theme to _site/static/css/custom-styles.css"

cp theme/favicon/*.ico theme/favicon/*.png theme/favicon/site.webmanifest _site/static/
echo "Applied favicon set to _site/static/"

find _site -name '*.html' -exec sed -i '' "s/ - Cook<\/title>/ - $SITE_NAME<\/title>/" {} +
echo "Retitled browser tabs to \"$SITE_NAME\""

# The static build ships timer badges as inert text (no click-to-start —
# that only exists in the dynamic `cook server` app). Append the missing
# behavior onto the generator's own keyboard-shortcuts.js, which every
# page already loads, rather than editing any generated HTML.
cat theme/timer.js >> _site/static/js/keyboard-shortcuts.js
echo "Appended click-to-start timers to _site/static/js/keyboard-shortcuts.js"
