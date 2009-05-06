use strict;
use warnings;
use Test::More tests => 13;
use_ok 'MusicBrainz::Server::Data::Recording';

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $rec_data = MusicBrainz::Server::Data::Recording->new(c => $c);

my $work = $rec_data->get_by_id(1);
is ( $work->id, 1 );
is ( $work->gid, "123c079d-374e-4436-9448-da92dedef3ce" );
is ( $work->name, "Dancing Queen" );
is ( $work->artist_credit_id, 2 );
is ( $work->length, 123456 );
is ( $work->edits_pending, 0 );

$work = $rec_data->get_by_gid("123c079d-374e-4436-9448-da92dedef3ce");
is ( $work->id, 1 );
is ( $work->gid, "123c079d-374e-4436-9448-da92dedef3ce" );
is ( $work->name, "Dancing Queen" );
is ( $work->artist_credit_id, 2 );
is ( $work->length, 123456 );
is ( $work->edits_pending, 0 );
