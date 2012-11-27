#!/bin/bash
sed -i 's/&ndash;/\&#x2013;/g' mb_server.*.po
sed -i 's/&mdash;/\&#x2014;/g' mb_server.*.po
sed -i 's/&nbsp;/\&#xa0;/g' mb_server.*.po
sed -i 's/&raquo;/»/g' mb_server.*.po
