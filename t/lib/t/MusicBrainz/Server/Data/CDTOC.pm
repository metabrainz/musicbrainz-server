package t::MusicBrainz::Server::Data::CDTOC;
use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::CDTOC;
use MusicBrainz::Server::Data::MediumCDTOC;

use Sql;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Entity::Medium;

with 't::Context';

test 'Adding a CDTOC to a medium removes CD stubs' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+cdtoc');
    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+cdstub_raw');
    MusicBrainz::Server::Test->prepare_test_database($test->c, <<~'SQL');
        INSERT INTO cdtoc
            (id, discid, freedb_id, track_count, leadout_offset, track_offset)
        VALUES
            (3, 'YfSgiOEayqN77Irs.VNV.UNJ0Zs-', '5908ea07', 7, 171327,
            ARRAY[150,22179,49905,69318,96240,121186,143398]);
        SQL

    my $discid = 'YfSgiOEayqN77Irs.VNV.UNJ0Zs-';
    my $cdstub = $test->c->model('CDStub')->get_by_discid($discid);
    ok($cdstub, 'cd stub exists');

    $test->c->model('MediumCDTOC')->insert({
        medium => 1,
        cdtoc  => 3
    });

    $cdstub = $test->c->model('CDStub')->get_by_discid($discid);
    ok(!$cdstub, 'cd stub no longer exists');
};

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+cdtoc');

my $cdtoc_data = $test->c->model('CDTOC');
my $medium_cdtoc_data = $test->c->model('MediumCDTOC');

my $cdtoc = $cdtoc_data->get_by_id(1);
is($cdtoc->id, 1);
is($cdtoc->discid, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-');
is($cdtoc->freedb_id, '5908ea07');
is($cdtoc->track_count, 7);
is($cdtoc->leadout_offset, 171327);
is($cdtoc->track_offset->[0], 150);
is($cdtoc->track_offset->[6], 143398);

$cdtoc = $cdtoc_data->get_by_discid('tLGBAiCflG8ZI6lFcOt87vXjEcI-');
is($cdtoc->id, 1);

my @medium_cdtoc = $medium_cdtoc_data->find_by_discid($cdtoc->discid);
is(scalar(@medium_cdtoc), 2);
is($medium_cdtoc[0]->medium_id, 1);
is($medium_cdtoc[1]->medium_id, 2);

ok($medium_cdtoc_data->medium_has_cdtoc(1, $cdtoc));
ok($medium_cdtoc_data->medium_has_cdtoc(2, $cdtoc));
ok(!$medium_cdtoc_data->medium_has_cdtoc(3, $cdtoc));

@medium_cdtoc = $medium_cdtoc_data->find_by_medium(1);
$cdtoc_data->load(@medium_cdtoc);
is(scalar(@medium_cdtoc), 1);
is($medium_cdtoc[0]->cdtoc_id, 1);
is($medium_cdtoc[0]->cdtoc->discid, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-');

my $medium = MusicBrainz::Server::Entity::Medium->new( id => 1 );
@medium_cdtoc = $medium_cdtoc_data->load_for_mediums($medium);
$cdtoc_data->load(@medium_cdtoc);
is(scalar($medium->all_cdtocs), 1);
is($medium->cdtocs->[0]->cdtoc_id, 1);
is($medium->cdtocs->[0]->cdtoc->discid, 'tLGBAiCflG8ZI6lFcOt87vXjEcI-');


my $id  = $cdtoc_data->find_or_insert('1 9 253125 150 38550 69970 83577 100540 118842 168737 194517 228310');
my $id2 = $cdtoc_data->find_or_insert('1 9 253125 150 38550 69970 83577 100540 118842 168737 194517 228310');
is($id, $id2);


};

1;
