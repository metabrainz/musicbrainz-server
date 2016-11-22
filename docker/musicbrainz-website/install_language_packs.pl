#!/usr/bin/perl

use DBDefs;

my @languages = DBDefs->MB_LANGUAGES;
s/-.+$// for @languages;
my @not_installed;

for (@languages) {
    my $package = "language-pack-$_";
    if (system qw( dpkg -s ), $package) {
        push @not_installed, $package;
    }
}

if (@not_installed) {
    system qw( apt-get update );
    system qw( apt-get install -y ), @not_installed;
}
