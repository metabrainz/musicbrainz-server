#!/usr/bin/env bash

VHOST=${1:-/sir}

rabbitmqctl purge_queue -p "$VHOST" search.delete
rabbitmqctl purge_queue -p "$VHOST" search.failed
rabbitmqctl purge_queue -p "$VHOST" search.index
rabbitmqctl purge_queue -p "$VHOST" search.retry
