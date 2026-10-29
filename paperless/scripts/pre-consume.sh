#!/bin/sh
set -e

# Paperless passes the file only via environment, changes belong in the working copy, never in the original
/scripts/remove-blank-pages.sh "$DOCUMENT_WORKING_PATH"
