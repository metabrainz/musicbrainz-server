package t::MusicBrainz::Server::Data::ISWC;
use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_set cmp_bag );

use MusicBrainz::Server::Test;

with 't::Context';

test 'Test get_by_id' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    my $iswc = $test->c->model('ISWC')->get_by_id(1);
    ok(defined $iswc, 'Found ISWC with ID 1');
    is($iswc->iswc, 'T-000.000.001-0', 'ISWC id=1 has correct ISWC');
    is($iswc->work_id, 1, 'ISWC id=1 is for work=1');
};

test 'Test find_by_works' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    {
        my @iswcs = $test->c->model('ISWC')->find_by_works(1);
        is(@iswcs, 1, 'Found 1 ISWC for work 1');
        is($iswcs[0]->iswc, 'T-000.000.001-0', 'Work 1 has correct ISWC');
        is($iswcs[0]->work_id, 1, 'ISWC has a back-reference to Work 1');
    }

    {
        my @iswcs = $test->c->model('ISWC')->find_by_works(100);
        is(@iswcs, 0, 'Found no ISWC for work 100');
    }

    {
        my @iswcs = $test->c->model('ISWC')->find_by_works(1, 2);
        is(@iswcs, 2, 'Found 2 ISWCs that are linked to work 1 or 2');
    }
};

test 'Test merge_works' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    $test->c->model('ISWC')->merge_works(1, 2, 5, 10);
    my @iswcs = $test->c->model('ISWC')->find_by_works(1);
    is(scalar @iswcs, 4);
    cmp_bag(
        [ map { $_->iswc } @iswcs ],
        [
            'T-000.000.001-0',
            'T-500.000.001-0',
            'T-500.000.002-0',
            'T-000.000.002-0'
        ],
        'Work id=1 has correct ISWCs',
    );

    is($_->work_id, 1, 'All ISWCs are linked to work 1')
        for @iswcs;
};

test 'Test delete_works' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    $test->c->model('ISWC')->delete_works(1);
    my @iswcs = $test->c->model('ISWC')->find_by_works(1);

    is(@iswcs, 0, 'There are no ISWCs for work=1');
};

test 'Test insert' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    my $iswc = 'T-999.000.001-0';
    my $work_id = 10;

    $test->c->model('ISWC')->insert({
        iswc => $iswc,
        work_id => $work_id
    });

    my @iswcs = $test->c->model('ISWC')->find_by_works($work_id);
    is(@iswcs, 1, 'Found one ISWC for work=10');
    is($iswcs[0]->iswc, $iswc);
    is($iswcs[0]->work_id, $work_id);
};

test 'Test delete' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    $test->c->model('ISWC')->delete(1);
    ok(!defined $test->c->model('ISWC')->get_by_id(1), 'ISWC id=1 no longer exists');
};

test 'Test load_for_works' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    {
        my $work = $test->c->model('Work')->get_by_id(1);
        $test->c->model('ISWC')->load_for_works($work);
        is($work->all_iswcs, 1, 'Work 1 has 1 ISWC');
        is($work->iswcs->[0]->iswc, 'T-000.000.001-0', 'Work 1 has the correct ISWC');
    }

    {
        my $work = $test->c->model('Work')->get_by_id(5);
        $test->c->model('ISWC')->load_for_works($work);
        is($work->all_iswcs, 2, 'Work 5 has 2 ISWCs');
        cmp_bag(
            [ map { $_->iswc } $work->all_iswcs ],
            [ 'T-500.000.001-0', 'T-500.000.002-0' ],
            'Work 5 has the correct ISWCs',
        );
    }

    {
        my $work = $test->c->model('Work')->get_by_id(10);
        $test->c->model('ISWC')->load_for_works($work);
        is($work->all_iswcs, 0, 'Work 10 has no ISWCs');
    }
};

test 'Test find_by_iswc' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    {
        my @iswcs = $test->c->model('Work')->find_by_iswc('T-000.000.001-0');
        is(@iswcs, 1, 'Found 1 ISWC for existing ISWC');
    }

    {
        my @iswcs = $test->c->model('Work')->find_by_iswc('T-111.222.331-0');
        is(@iswcs, 0, 'Found 0 ISWCs for non-existent ISWC');
    }
};

1;
