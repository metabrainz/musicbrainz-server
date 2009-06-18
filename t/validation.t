#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 5;

use_ok 'MusicBrainz::Server::Validation';

my $a = '  ';
my $b = ' a ';
my $c = ' a  b  ';
my $d = ' a  b  c ';
MusicBrainz::Server::Validation::TrimInPlace($a, $b, $c, $d);

is( $a, '' );
is( $b, 'a' );
is( $c, 'a b' );
is( $d, 'a b c' );
