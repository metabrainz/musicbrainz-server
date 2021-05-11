#!/usr/bin/env bash

trap_jobs_nowait() {
    trap 'kill -TERM $(jobs -p); wait; exit' SIGTERM
    trap 'kill -INT $(jobs -p); wait; exit' SIGINT
}

trap_jobs() {
    trap_jobs_nowait
    wait
}
