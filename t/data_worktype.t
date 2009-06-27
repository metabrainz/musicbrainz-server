use strict;
use warnings;
use Test::More tests => 9;
use_ok 'MusicBrainz::Server::Data::WorkType';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $wt_data = MusicBrainz::Server::Data::WorkType->new(c => $c);

my $wt = $wt_data->get_by_id(1);
is ( $wt->id, 1 );
is ( $wt->name, "Composition" );

$wt = $wt_data->get_by_id(2);
is ( $wt->id, 2 );
is ( $wt->name, "Symphony" );

my $wts = $wt_data->get_by_ids(1, 2);
is ( $wts->{1}->id, 1 );
is ( $wts->{1}->name, "Composition" );

is ( $wts->{2}->id, 2 );
is ( $wts->{2}->name, "Symphony" );
