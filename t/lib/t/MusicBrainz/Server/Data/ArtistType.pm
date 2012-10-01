package t::MusicBrainz::Server::Data::ArtistType;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::ArtistType;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

with 't::Context';

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+artisttype');

my $at_data = MusicBrainz::Server::Data::ArtistType->new(c => $test->c);

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

does_ok($at_data, 'MusicBrainz::Server::Data::Role::SelectAll');
my @types = $at_data->get_all;
is(@types, 3);
is($types[0]->id, 1);
is($types[1]->id, 2);
is($types[2]->id, 3);

};

1;
