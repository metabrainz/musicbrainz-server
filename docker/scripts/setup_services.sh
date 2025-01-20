#!/bin/bash

for SVC in "$@"; do
    SVC_DIR=/etc/service/"$SVC"
    LOG_SVC_DIR="$SVC_DIR"/log
    LOG_DIR=/var/log/service/"$SVC"

    touch "$SVC_DIR"/down
    mkdir -p "$LOG_SVC_DIR" "$LOG_DIR"
    echo -e "#!/bin/sh\nexec svlogd -tt "$LOG_DIR"" > "$LOG_SVC_DIR"/run
    chmod +x "$LOG_SVC_DIR"/run
done
