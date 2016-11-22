#!/bin/bash

for target in "$@"; do
    m4 -D GIT_INFO="$GIT_INFO" -I templates -P templates/$target.m4 > $target
done
