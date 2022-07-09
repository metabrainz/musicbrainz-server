#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../"

exec bin/sucrase-node t/selenium.mjs "$@"
