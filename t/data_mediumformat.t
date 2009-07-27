#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 15;
use Test::Moose;
use_ok 'MusicBrainz::Server::Data::MediumFormat';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+mediumformat');

my $mf_data = MusicBrainz::Server::Data::MediumFormat->new(c => $c);

my $mf = $mf_data->get_by_id(1);
is ( $mf->id, 1 );
is ( $mf->name, "CD" );
is ( $mf->year, 1982 );

$mf = $mf_data->get_by_id(2);
is ( $mf->id, 2 );
is ( $mf->name, "Vinyl" );
is ( $mf->year, undef );

my $mfs = $mf_data->get_by_ids(1, 2);
is ( $mfs->{1}->id, 1 );
is ( $mfs->{1}->name, "CD" );

is ( $mfs->{2}->id, 2 );
is ( $mfs->{2}->name, "Vinyl" );


does_ok($mf_data, 'MusicBrainz::Server::Data::SelectAll');
my @formats = $mf_data->get_all;
is(@formats, 2);
is($formats[0]->id, 1);
is($formats[1]->id, 2);
