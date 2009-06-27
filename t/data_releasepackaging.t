use strict;
use warnings;
use Test::More tests => 5;
use_ok 'MusicBrainz::Server::Data::ReleasePackaging';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $lt_data = MusicBrainz::Server::Data::ReleasePackaging->new(c => $c);

my $lt = $lt_data->get_by_id(1);
is ( $lt->id, 1 );
is ( $lt->name, "Jewel Case" );

my $lts = $lt_data->get_by_ids(1);
is ( $lts->{1}->id, 1 );
is ( $lts->{1}->name, "Jewel Case" );
