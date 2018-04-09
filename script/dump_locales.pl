#!/usr/bin/env perl

use strict;
use warnings;
use DateTime::Locale;
use JSON::PP;

my %hash = map {
    $_ => DateTime::Locale->load($_)->name
} DateTime::Locale->codes;

print JSON::PP->new->indent->indent_length(2)->canonical->utf8->encode(\%hash);
