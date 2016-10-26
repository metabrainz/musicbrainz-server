#!/bin/bash

pushd "$(dirname "${BASH_SOURCE[0]}")"

source config.default.sh

if [ -e config.user.sh ]; then
    source config.user.sh
fi

popd
