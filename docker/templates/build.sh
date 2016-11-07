#!/bin/bash

MB_SERVER_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../" && pwd)
cd "$MB_SERVER_ROOT"

M4_FILES=$(find . -name 'Dockerfile.*.m4')

shopt -s expand_aliases
alias M4="m4 -Idocker/templates/ -P"

for f in $M4_FILES; do
    M4 "$f" > "$(basename "$f" .m4)"
done
