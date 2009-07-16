#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 14;
use Test::Moose;
use_ok 'MusicBrainz::Server::Data::ArtistType';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+artisttype');

my $at_data = MusicBrainz::Server::Data::ArtistType->new(c => $c);

my $at = $at_data->get_by_id(1);
is ( $at->id, 1 );
is ( $at->name, "Person" );

$at = $at_data->get_by_id(2);
is ( $at->id, 2 );
is ( $at->name, "Group" );

my $ats = $at_data->get_by_ids(1, 2);
is ( $ats->{1}->id, 1 );
is ( $ats->{1}->name, "Person" );

is ( $ats->{2}->id, 2 );
is ( $ats->{2}->name, "Group" );

does_ok($at_data, 'MusicBrainz::Server::Data::SelectAll');
my @types = $at_data->get_all;
is(@types, 3);
is($types[0]->id, 1);
is($types[1]->id, 2);
is($types[2]->id, 3);
