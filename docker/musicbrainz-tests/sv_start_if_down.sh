function sv_start_if_down() {
  while [[ $# -gt 0 ]]
  do
    if [[ -e "/etc/service/$1/down" ]]
    then
      rm -fv "/etc/service/$1/down"
      sv -w 30 start "$1"
    fi
    shift
  done
}
