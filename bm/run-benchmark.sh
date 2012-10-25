#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

if [ -z "$1" ]; then
    echo "Usage: run-benchmark.sh <count>"
    exit 1
fi

echo "Starting benchmark for $1 artists."
echo "----------------------------------"

cd "$DIR"
python ./randomartists.py $1
cd "$DIR/.."

echo -n "Benchmark createArtist with perl/ngs data access layer ... "
carton exec -- bm/createArtist.pl < bm/test-artists.csv > bm/createArtist-pl.txt
echo "saved to bm/createArtist-pl.txt"
echo -n "Benchmark createArtist with haskell/nes data access layer ... "
carton exec -- bm/createArtist-nes.pl < bm/test-artists.csv > bm/createArtist-nes.txt
echo "saved to bm/createArtist-nes.txt"
echo -n "Preparing artist mbids to query ... "
cat bm/createArtist-nes.txt bm/createArtist-pl.txt | awk '-F, ' '{ print $2 }' | sort > query-mbids.txt
echo "saved to query-mbids.txt"
echo -n "Benchmark findArtist with perl/ngs data access layer ... "
cat bm/query-mbids.txt | carton exec -- bm/findArtist.pl > bm/findArtist-pl.txt
echo "saved to bm/findArtist-pl.txt"
echo -n "Benchmark findArtist with haskell/nes data access layer ... "
cat bm/query-mbids.txt | carton exec -- bm/findArtist-nes.pl > bm/findArtist-nes.txt
echo "saved to bm/findArtist-nes.txt"
