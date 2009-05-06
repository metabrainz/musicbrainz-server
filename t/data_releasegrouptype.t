use strict;
use warnings;
use Test::More tests => 9;
use_ok 'MusicBrainz::Server::Data::ReleaseGroupType';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $rgt_data = MusicBrainz::Server::Data::ReleaseGroupType->new(c => $c);

my $rgt = $rgt_data->get_by_id(1);
is ( $rgt->id, 1 );
is ( $rgt->name, "Album" );

$rgt = $rgt_data->get_by_id(2);
is ( $rgt->id, 2 );
is ( $rgt->name, "Single" );

my $rgts = $rgt_data->get_by_ids(1, 2);
is ( $rgts->{1}->id, 1 );
is ( $rgts->{1}->name, "Album" );

is ( $rgts->{2}->id, 2 );
is ( $rgts->{2}->name, "Single" );
