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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
