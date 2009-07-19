use strict;
use warnings;
use Test::More tests => 8;
use Test::Moose;
use_ok 'MusicBrainz::Server::Data::ReleaseStatus';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+releasestatus');

my $lt_data = MusicBrainz::Server::Data::ReleaseStatus->new(c => $c);

my $lt = $lt_data->get_by_id(1);
is ( $lt->id, 1 );
is ( $lt->name, "Official" );

my $lts = $lt_data->get_by_ids(1);
is ( $lts->{1}->id, 1 );
is ( $lts->{1}->name, "Official" );

does_ok($lt_data, 'MusicBrainz::Server::Data::SelectAll');
my @status = $lt_data->get_all;
is(@status, 1);
is($status[0]->id, 1);
