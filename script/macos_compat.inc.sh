if [[ $OSTYPE == darwin* ]]
then
  if ! command -v gsed &> /dev/null
  then
    echo 'You must install gnu-sed (e.g. with Homebrew) to run this script.'
    exit 1
  fi
  alias sed=gsed
  shopt -s expand_aliases
fi
