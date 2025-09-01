#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../"

exec bin/babel-node t/selenium.mjs "$@"
