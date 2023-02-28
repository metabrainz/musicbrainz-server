#!/usr/bin/env bash

# This file is part of MusicBrainz, the open internet music database.
# Copyright (C) 2017 MetaBrainz Foundation
# Licensed under the GPL version 2, or (at your option) any later version:
# http://www.gnu.org/licenses/gpl-2.0.txt

# ---
# Converts perlcritic output to TAP format. Test::Perl::Critic 1.03 provides
# similar functionality, but is prohibitively slow.
#
# We use a shell implementation of Perl::Critic::Utils::all_perl_files,
# because an exact plan is required for `prove`.

FILES=$(find bin lib script t \
    -type f \( \
        -name '*.pl' -or \
        -name '*.pm' -or \
        -name '*.t' ! -name 'critic.t' -or \
        -exec awk '/^#!.*perl/ { exit 0 } { exit 1 }' '{}' \; \
    \) \
    -print)

COUNT=$(echo "$FILES" | wc -l | awk '{ print $1 }')

echo "1..$COUNT"

TAP_PROG=$(cat <<'EOF'
BEGIN { i = 0 }

!/source OK$/ {
    error = $0;
    fname = $0;
    sub(/^[^:]+: /, "", error);
    sub(/: .*$/, "", fname);
    if (!(fname in seen)) {
        i++;
        seen[fname] = 1;
        print "not ok", i, "-", fname;
        print "  ---"
    }
    print " ", error;
    next
}

{
    i++;
    print "ok", i, "-", $0
}
EOF
)

echo "$FILES" | tr '\n' '\0' | xargs -0 perlcritic | awk "$TAP_PROG"
