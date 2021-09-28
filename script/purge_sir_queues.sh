#!/usr/bin/env bash

VHOST=${1:-/sir}

sudo -n rabbitmqctl purge_queue -p "$VHOST" search.delete
sudo -n rabbitmqctl purge_queue -p "$VHOST" search.failed
sudo -n rabbitmqctl purge_queue -p "$VHOST" search.index
sudo -n rabbitmqctl purge_queue -p "$VHOST" search.retry
