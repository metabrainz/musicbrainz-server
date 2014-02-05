#!/bin/bash
tx pull -f &&
perl -pi -e 's/(Last-Translator: .*<)[^<>]+(>\\n")$/$1email address hidden$2/' *.po &&
perl -pi -e 's/^(#.*<)[^<>]+(>, [0-9]+.*)$/$1email address hidden$2/' *.po &&
perl -pi -e 's/ENCODING/8bit/' *.po
