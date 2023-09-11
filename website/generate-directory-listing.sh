#!/usr/bin/env bash
ROOT=$1
OUT="$ROOT/index.html"

i=0
echo "<html>
<head>
<title>$ROOT - tzurl.org</title>
</head>
<body>
<h1 style="font-family:monospace">$ROOT</h1>" >$OUT
echo "<ul>" >>$OUT
for filepath in $(find "$ROOT" -maxdepth 1 -mindepth 1 -type d | sort); do
  path=$(basename "$filepath")
  echo "<li><a href=\"$path/index.html\">$path</a></li>" >>$OUT
  website/generate-directory-listing.sh $filepath
done
echo "</ul>" >>$OUT

echo "<ul>" >>$OUT
for filepath in $(find "$ROOT" -maxdepth 1 -mindepth 1 -type f -name *.ics | sort); do
  path=$(basename "$filepath")
  echo "<li><a href=\"$path\">$path</a></li>" >>$OUT
done
echo "</ul>" >>$OUT
echo "</body>
</html>" >>$OUT
