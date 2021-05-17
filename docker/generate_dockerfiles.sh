#!/usr/bin/env bash

for target in "$@"; do
    m4 \
        -D GIT_BRANCH="$GIT_BRANCH" \
        -D GIT_MSG="$GIT_MSG" \
        -D GIT_SHA="$GIT_SHA" \
        -I templates \
        -P templates/$target.m4 \
        > $target
done
