#!/bin/sh
find * -type f -iname '*-9999.ebuild' | while read f; do echo "$(dirname ${f})::lua **" > Documentation/package.keywords/$(basename "${f//-9999.ebuild}"); done;
