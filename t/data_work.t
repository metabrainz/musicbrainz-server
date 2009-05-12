use strict;
use warnings;
use Test::More tests => 17;
use_ok 'MusicBrainz::Server::Data::Work';
use MusicBrainz::Server::Data::WorkType;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Context->new();
MusicBrainz::Server::Test->prepare_test_database($c);

my $work_data = MusicBrainz::Server::Data::Work->new(c => $c);

my $work = $work_data->get_by_id(1);
is ( $work->id, 1 );
is ( $work->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $work->name, "Dancing Queen" );
is ( $work->artist_credit_id, 2 );
is ( $work->iswc, "T-000.000.001-0" );
is ( $work->type_id, 1 );
is ( $work->edits_pending, 0 );

$work = $work_data->get_by_gid("745c079d-374e-4436-9448-da92dedef3ce");
is ( $work->id, 1 );
is ( $work->gid, "745c079d-374e-4436-9448-da92dedef3ce" );
is ( $work->name, "Dancing Queen" );
is ( $work->artist_credit_id, 2 );
is ( $work->iswc, "T-000.000.001-0" );
is ( $work->type_id, 1 );
is ( $work->edits_pending, 0 );

is ( $work->type, undef );
MusicBrainz::Server::Data::WorkType->new(c => $c)->load($work);
is ( $work->type->name, "Composition" );
