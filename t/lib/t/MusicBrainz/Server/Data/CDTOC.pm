package t::MusicBrainz::Server::Data::CDTOC;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use_ok 'MusicBrainz::Server::Data::CDTOC';
use_ok 'MusicBrainz::Server::Data::MediumCDTOC';

use Sql;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Entity::Medium;

with 't::Context';

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+cdtoc');

my $cdtoc_data = $test->c->model('CDTOC');
my $medium_cdtoc_data = $test->c->model('MediumCDTOC');
memory_cycle_ok($cdtoc_data);
memory_cycle_ok($medium_cdtoc_data);

my $cdtoc = $cdtoc_data->get_by_id(1);
is($cdtoc->id, 1);
is($cdtoc->discid, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-');
is($cdtoc->freedb_id, '5908ea07');
is($cdtoc->track_count, 7);
is($cdtoc->leadout_offset, 171327);
is($cdtoc->track_offset->[0], 150);
is($cdtoc->track_offset->[6], 143398);
memory_cycle_ok($cdtoc_data);
memory_cycle_ok($cdtoc);

$cdtoc = $cdtoc_data->get_by_discid('tLGBAiCflG8ZI6lFcOt87vXjEcI-');
is($cdtoc->id, 1);
memory_cycle_ok($cdtoc_data);
memory_cycle_ok($cdtoc);

my @medium_cdtoc = $medium_cdtoc_data->find_by_cdtoc(1);
is(scalar(@medium_cdtoc), 2);
is($medium_cdtoc[0]->medium_id, 1);
is($medium_cdtoc[1]->medium_id, 2);
memory_cycle_ok($medium_cdtoc_data);
memory_cycle_ok(\@medium_cdtoc);

@medium_cdtoc = $medium_cdtoc_data->find_by_medium(1);
$cdtoc_data->load(@medium_cdtoc);
is(scalar(@medium_cdtoc), 1);
is($medium_cdtoc[0]->cdtoc_id, 1);
is($medium_cdtoc[0]->cdtoc->discid, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-');
memory_cycle_ok($medium_cdtoc_data);
memory_cycle_ok(\@medium_cdtoc);

my $medium = MusicBrainz::Server::Entity::Medium->new( id => 1 );
@medium_cdtoc = $medium_cdtoc_data->load_for_mediums($medium);
$cdtoc_data->load(@medium_cdtoc);
is(scalar($medium->all_cdtocs), 1);
is($medium->cdtocs->[0]->cdtoc_id, 1);
is($medium->cdtocs->[0]->cdtoc->discid, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-');

memory_cycle_ok($medium_cdtoc_data);
memory_cycle_ok(\@medium_cdtoc);
memory_cycle_ok($medium);

my $id  = $cdtoc_data->find_or_insert('1 9 253125 150 38550 69970 83577 100540 118842 168737 194517 228310');
my $id2 = $cdtoc_data->find_or_insert('1 9 253125 150 38550 69970 83577 100540 118842 168737 194517 228310');
is($id, $id2);

memory_cycle_ok($cdtoc_data);

};

1;
