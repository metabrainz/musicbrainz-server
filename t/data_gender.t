use strict;
use warnings;
use Test::More tests => 9;
use_ok 'MusicBrainz::Server::Data::Gender';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $gender_data = MusicBrainz::Server::Data::Gender->new(c => $c);

my $gender = $gender_data->get_by_id(1);
is ( $gender->id, 1 );
is ( $gender->name, "Male" );

$gender = $gender_data->get_by_id(2);
is ( $gender->id, 2 );
is ( $gender->name, "Female" );

my $genders = $gender_data->get_by_ids(1, 2);
is ( $genders->{1}->id, 1 );
is ( $genders->{1}->name, "Male" );

is ( $genders->{2}->id, 2 );
is ( $genders->{2}->name, "Female" );
