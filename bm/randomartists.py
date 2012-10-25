#!/usr/bin/env python2

from __future__ import absolute_import
from __future__ import print_function
from __future__ import unicode_literals

import sys
import csv
import codecs
import random
from sre_compile import isstring


def randomName (syllables):

    name = ""
    for x in xrange(random.choice (range(2,6))):
        name = name + random.choice (['', ' ']) + random.choice (syllables)

    return name.strip ()


def randomIPI ():
    digits = "0123456789"

    ipi = "00"
    for x in xrange(9):
        ipi = ipi + random.choice (digits)

    return ipi


def utf8_encode (s):
    if isstring (s):
        return s.encode ('utf-8')

    return s


def createArtist (syllables):
    name = randomName (syllables)
    begin = [
        random.choice (range (1930,2011)),
        random.choice (range (1,12)),
        random.choice (range (1,28))
        ]
    end = [
        random.choice (range (begin[0],2011)),
        random.choice (range (1,12)),
        random.choice (range (1,28))
        ]

    parts = [
        name,                     # name
        name,                     # sort name
        None,                     # country
        None,                     # gender
        randomName (syllables),   # comment
        1,                        # ended
        begin[0],                 # begin date
        begin[1],
        begin[2],
        end[0],                   # end date
        end[1],
        end[2],
        # randomIPI()               # IPI
        ]

    return [ utf8_encode (p) for p in parts ]


def help ():
    print ("Usage: randomartists.py <count>")
    sys.exit (1)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        help ()

    count = int (sys.argv[1])
    filename = "test-artists.csv"

    with codecs.open ("syll.txt", "rb", "ascii") as inputfile:
        syllables = [ s.strip () for s in inputfile.readlines () ]

        with open (filename, "wb") as csvfile:
            csvwriter = csv.writer (csvfile, dialect='excel')

            for i in xrange(count):
                csvwriter.writerow (createArtist (syllables))

    print ("Wrote", count, "artists to", filename)
