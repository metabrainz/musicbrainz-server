#!/bin/bash

for SVC in "$@"; do
    LOG_SVC_DIR=/etc/service/"$SVC"/log
    LOG_DIR=/var/log/service/"$SVC"

    mkdir -p "$LOG_SVC_DIR" "$LOG_DIR"
    echo -e "#!/bin/sh\nexec svlogd -tt "$LOG_DIR"" > "$LOG_SVC_DIR"/run
    chmod +x "$LOG_SVC_DIR"/run
done
