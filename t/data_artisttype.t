use strict;
use warnings;
use Test::More tests => 9;
use_ok 'MusicBrainz::Server::Data::ArtistType';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

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
