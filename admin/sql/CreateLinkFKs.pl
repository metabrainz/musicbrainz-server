#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :

use strict;

print <<EOF;
-- For each pair of entity types, there are four FKs to create:
-- * lt.parent refers to lt.id
-- * l.link_type refers to lt.id
-- * l.link0 and l.link1

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
ALTER TABLE $typetab
    ADD CONSTRAINT fk_${typetab}_parent
    FOREIGN KEY (parent)
    REFERENCES $typetab(id);
ALTER TABLE $linktab
    ADD CONSTRAINT fk_${linktab}_link_type
    FOREIGN KEY (link_type)
    REFERENCES $typetab(id);
ALTER TABLE $linktab
    ADD CONSTRAINT fk_${linktab}_link0
    FOREIGN KEY (link0)
    REFERENCES ${a}(id);
ALTER TABLE $linktab
    ADD CONSTRAINT fk_${linktab}_link1
    FOREIGN KEY (link1)
    REFERENCES ${b}(id);

EOF
    }
}

