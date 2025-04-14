#!/usr/bin/env bash

VHOST=${1:-/sir}

RABBITMQCTL_COMMAND="${RABBITMQCTL_COMMAND:-sudo -n rabbitmqctl}"

$RABBITMQCTL_COMMAND purge_queue -p "$VHOST" search.delete
$RABBITMQCTL_COMMAND purge_queue -p "$VHOST" search.failed
$RABBITMQCTL_COMMAND purge_queue -p "$VHOST" search.index
$RABBITMQCTL_COMMAND purge_queue -p "$VHOST" search.retry
