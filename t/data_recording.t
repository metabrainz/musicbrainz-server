use strict;
use warnings;
use Test::More tests => 20;
use_ok 'MusicBrainz::Server::Data::Recording';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $rec_data = MusicBrainz::Server::Data::Recording->new(c => $c);

my $rec = $rec_data->get_by_id(1);
is ( $rec->id, 1 );
is ( $rec->gid, "123c079d-374e-4436-9448-da92dedef3ce" );
is ( $rec->name, "Dancing Queen" );
is ( $rec->artist_credit_id, 2 );
is ( $rec->length, 123456 );
is ( $rec->edits_pending, 0 );

$rec = $rec_data->get_by_gid("123c079d-374e-4436-9448-da92dedef3ce");
is ( $rec->id, 1 );
is ( $rec->gid, "123c079d-374e-4436-9448-da92dedef3ce" );
is ( $rec->name, "Dancing Queen" );
is ( $rec->artist_credit_id, 2 );
is ( $rec->length, 123456 );
is ( $rec->edits_pending, 0 );

my ($recs, $hits) = $rec_data->find_by_artist(7, 100);
is( $hits, 16 );
is( scalar(@$recs), 16 );
is( $recs->[0]->name, "A Coral Room" );
is( $recs->[1]->name, "Aerial" );
is( $recs->[14]->name, "The Painter's Link" );
is( $recs->[15]->name, "π" );

$rec = $rec_data->get_by_gid('0986e67c-6b7a-40b7-b4ba-c9d7583d6426');
is ( $rec->id, 1 );
