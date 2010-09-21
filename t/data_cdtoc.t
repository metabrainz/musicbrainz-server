#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use_ok 'MusicBrainz::Server::Data::CDTOC';
use_ok 'MusicBrainz::Server::Data::MediumCDTOC';

use Sql;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Entity::Medium;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+cdtoc');

my $cdtoc = $c->model('CDTOC')->get_by_id(1);
is($cdtoc->id, 1);
is($cdtoc->discid, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-');
is($cdtoc->freedbid, '5908ea07');
is($cdtoc->track_count, 7);
is($cdtoc->leadout_offset, 171327);
is($cdtoc->track_offset->[0], 150);
is($cdtoc->track_offset->[6], 143398);

$cdtoc = $c->model('CDTOC')->get_by_discid('tLGBAiCflG8ZI6lFcOt87vXjEcI-');
is($cdtoc->id, 1);

my @medium_cdtoc = $c->model('MediumCDTOC')->find_by_cdtoc(1);
is(scalar(@medium_cdtoc), 2);
is($medium_cdtoc[0]->medium_id, 1);
is($medium_cdtoc[1]->medium_id, 2);

@medium_cdtoc = $c->model('MediumCDTOC')->find_by_medium(1);
$c->model('CDTOC')->load(@medium_cdtoc);
is(scalar(@medium_cdtoc), 1);
is($medium_cdtoc[0]->cdtoc_id, 1);
is($medium_cdtoc[0]->cdtoc->discid, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-');

my $medium = MusicBrainz::Server::Entity::Medium->new( id => 1 );
@medium_cdtoc = $c->model('MediumCDTOC')->load_for_mediums($medium);
$c->model('CDTOC')->load(@medium_cdtoc);
is(scalar($medium->all_cdtocs), 1);
is($medium->cdtocs->[0]->cdtoc_id, 1);
is($medium->cdtocs->[0]->cdtoc->discid, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-');

my $id = $c->model('CDTOC')->find_or_insert('1 9 253125 150 38550 69970 83577 100540 118842 168737 194517 228310');
my $id2 = $c->model('CDTOC')->find_or_insert('1 9 253125 150 38550 69970 83577 100540 118842 168737 194517 228310');
is($id, $id2);

done_testing;
