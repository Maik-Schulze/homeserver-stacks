#!/bin/bash
set -e -o pipefail
export LC_ALL=C

IN="$1"
if [ -z "$IN" ]; then
  >&2 echo "No input file provided!"
  exit 3
fi

TYPE=$(file -b "$IN")
if [[ "${TYPE%%,*}" != "PDF document" ]]; then
  >&2 echo "Skipping $IN - non PDF [$TYPE]."
  exit 0
fi

PAGES=$(pdfinfo "$IN" | awk '/Pages:/ {print $2}')
>&2 echo "Total pages $PAGES"

# Measured on the library: blank back sides 0.1 to 0.4, sparse real pages (address box only) from 0.35
THRESHOLD=0.3

non_blank() {
  local pages=""
  for i in $(seq 1 "$PAGES"); do
    PERCENT=$(gs -o - -dFirstPage="${i}" -dLastPage="${i}" -sDEVICE=ink_cov "${IN}" |
      grep CMYK | awk '{sum += $1 + $2 + $3 + $4} END {printf "%.5f\n", sum}')
    >&2 echo -n "Color-sum in page $i is $PERCENT: "
    if awk "BEGIN { exit !($PERCENT > $THRESHOLD) }"; then
      pages="$pages $i"
      >&2 echo "Page added to document"
    else
      >&2 echo "Page removed from document"
    fi
  done
  echo "$pages"
}

NON_BLANK=$(non_blank)
KEPT=$(echo $NON_BLANK | wc -w)

# Keep the document untouched if every page is blank or nothing was removed
if [[ "$KEPT" -gt 0 && "$KEPT" -lt "$PAGES" ]]; then
  qpdf "$IN" --replace-input --pages . "$(echo $NON_BLANK | tr ' ' ',')" -- || {
    >&2 echo "qpdf failed on $IN"
    exit 2
  }
fi