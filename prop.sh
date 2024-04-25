#!/usr/bin/env zsh

find content -name '*.md' -exec sh -c '
for file do
cp "$file" "public/${file#content/}"
done
' sh {} +
