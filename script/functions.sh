#!/bin/bash

trap_jobs() {
    trap 'kill -TERM $(jobs -p); wait; exit' SIGTERM
    trap 'kill -INT $(jobs -p); wait; exit' SIGINT
    wait
}
