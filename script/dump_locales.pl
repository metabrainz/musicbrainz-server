#!/usr/bin/env perl

use strict;
use warnings;

use FindBin '$Bin';
use lib "$Bin/../lib";

use DateTime::Locale;
use JSON::PP;
use MusicBrainz::Server::Constants qw( %ALIAS_LOCALES );

my %hash = map {
    $_ => $ALIAS_LOCALES{$_}->name
} keys %ALIAS_LOCALES;

print JSON::PP->new->indent->indent_length(2)->canonical->utf8->encode(\%hash);
