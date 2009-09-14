#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use_ok 'MusicBrainz::Server::Validation', qw( is_valid_iswc format_iswc );

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

ok(is_valid_iswc('T-000.000.001-0'));
ok(is_valid_iswc('T-000000001-0'));
ok(!is_valid_iswc('T0000000010'));
ok(!is_valid_iswc('T00010'));
ok(!is_valid_iswc('T-000.000-0'));

is(format_iswc('T-000.000.001-0'), 'T-000.000.001-0');
is(format_iswc('T-000000001-0'), 'T-000.000.001-0');

done_testing;
