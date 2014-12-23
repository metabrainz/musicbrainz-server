#!/bin/bash
git rm mb_server.{es_ES,el_GR,et_EE}.po
tx pull -f &&
perl -pi -e 's/(Last-Translator: .*<)[^<>]+(>\\n")$/$1email address hidden$2/' *.po &&
perl -pi -e 's/^(#.*<)[^<>]+(>, [0-9]+.*)$/$1email address hidden$2/' *.po &&
perl -pi -e 's/ENCODING/8bit/' *.po
git checkout HEAD mb_server.{es_ES,el_GR,et_EE}.po
