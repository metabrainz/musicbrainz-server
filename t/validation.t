#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use_ok 'MusicBrainz::Server::Validation', qw( is_valid_iswc format_iswc is_valid_ipi format_ipi );

my $a = '  ';
my $b = ' a ';
my $c = ' a  b  ';
my $d = ' a  b  c ';
MusicBrainz::Server::Validation::TrimInPlace($a, $b, $c, $d);

is( $a, '' );
is( $b, 'a' );
is( $c, 'a b' );
is( $d, 'a b c' );

ok(MusicBrainz::Server::Validation::is_valid_isrc('USPR37300012'));
ok(!MusicBrainz::Server::Validation::is_valid_isrc('12PR37300012'));
ok(!MusicBrainz::Server::Validation::is_valid_isrc(''));
ok(!MusicBrainz::Server::Validation::is_valid_isrc('123'));

ok(MusicBrainz::Server::Validation::is_valid_discid('D5LsXhbWwpctL4s5xHSTS_SefQw-'));
ok(!MusicBrainz::Server::Validation::is_valid_discid('aivDFb2Tw6HzN.XdYZFj5zr1Q9EY'));
ok(!MusicBrainz::Server::Validation::is_valid_discid(''));
ok(!MusicBrainz::Server::Validation::is_valid_discid('123'));

ok(is_valid_iswc('T-000.000.001-0'));
ok(is_valid_iswc('T-000000001-0'));
ok(is_valid_iswc('T-000000001.0'));
ok(is_valid_iswc('T0000000010'));
ok(!is_valid_iswc('T00010'));
ok(!is_valid_iswc('T-000.000-0'));
ok(is_valid_iswc('T- 101.914.232-4'));

is(format_iswc('T-000.000.001-0'), 'T-000.000.001-0');
is(format_iswc('T-000000001-0'), 'T-000.000.001-0');
is(format_iswc('T-000000001.0'), 'T-000.000.001-0');
is(format_iswc('T0000000010'), 'T-000.000.001-0');
is(format_iswc('T- 101.914.232-4'), 'T-101.914.232-4');

ok(is_valid_ipi('00014107338'));
is(format_ipi('014107338'), '00014107338');

my ($alice, $bob) = MusicBrainz::Server::Validation::normalise_strings ('alice', 'bob');
is ($alice, 'alice');
is ($bob, 'bob');

done_testing;
