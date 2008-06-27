#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :

use strict;

print <<EOF;
-- For each pair of entity types, there are four FKs to create:
-- * lt.parent refers to lt.id
-- * l.link_type refers to lt.id
-- * l.link1 and l.link2

EOF

my @e = qw( album artist track url );
for my $a (@e)
{
    for my $b (@e)
    {
        next unless $a le $b;

        my $typetab = "lt_${a}_${b}";
        my $linktab = "l_${a}_${b}";

        print <<EOF;
DROP TABLE $linktab;
DROP TABLE $typetab;
EOF
    }
}

