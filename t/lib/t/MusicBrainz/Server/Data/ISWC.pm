package t::MusicBrainz::Server::Data::ISWC;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_bag );

use MusicBrainz::Server::Test;

with 't::Context';

=head1 DESCRIPTION

This test checks different ISWC functions.

=cut

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

    my @iswcs = $test->c->model('ISWC')->find_by_works(1);
    is(@iswcs, 1, 'Found 1 ISWC for work 1');
    is($iswcs[0]->iswc, 'T-000.000.001-0', 'Work 1 has correct ISWC');
    is($iswcs[0]->work_id, 1, 'ISWC has a back-reference to work 1');

    @iswcs = $test->c->model('ISWC')->find_by_works(100);
    is(@iswcs, 0, 'Found no ISWCs for work 100');

    @iswcs = $test->c->model('ISWC')->find_by_works(1, 2);
    is(@iswcs, 2, 'Found 2 ISWCs that are linked to work 1 or 2');
};

test 'Test merge_works' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    note('We merge the ISWCs from four works');
    $test->c->model('ISWC')->merge_works(1, 2, 5, 10);
    my @iswcs = $test->c->model('ISWC')->find_by_works(1);
    is(scalar @iswcs, 4, 'The work has four ISWCs');
    cmp_bag(
        [ map { $_->iswc } @iswcs ],
        [
            'T-000.000.001-0',
            'T-500.000.001-0',
            'T-500.000.002-0',
            'T-000.000.002-0'
        ],
        'The ISWCs are the expected ones',
    );

    is($_->work_id, 1, 'ISWC ' . $_->iswc . ' has a back-reference to work 1')
        for @iswcs;
};

test 'Test delete_works' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    note('We delete ISWCs from work 1');
    $test->c->model('ISWC')->delete_works(1);
    my @iswcs = $test->c->model('ISWC')->find_by_works(1);

    is(@iswcs, 0, 'There are no ISWCs for work=1');
};

test 'Test insert' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    my $iswc = 'T-999.000.001-0';
    my $work_id = 10;

    note('We add an ISWC to work 10');
    $test->c->model('ISWC')->insert({
        iswc => $iswc,
        work_id => $work_id
    });

    my @iswcs = $test->c->model('ISWC')->find_by_works($work_id);
    is(@iswcs, 1, 'Found one ISWC for work 10');
    is($iswcs[0]->iswc, $iswc, 'The correct ISWC was returned');
    is(
        $iswcs[0]->work_id,
        $work_id,
        'The ISWC has a back-reference to work 10',
    );
};

test 'Test delete' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    note('We delete ISWC 1');
    $test->c->model('ISWC')->delete(1);
    ok(
        !defined $test->c->model('ISWC')->get_by_id(1),
        'ISWC id=1 no longer exists',
    );
};

test 'Test load_for_works' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    my $work = $test->c->model('Work')->get_by_id(1);
    $test->c->model('ISWC')->load_for_works($work);
    is($work->all_iswcs, 1, 'Work 1 has 1 ISWC');
    is(
        $work->iswcs->[0]->iswc,
        'T-000.000.001-0',
        'Work 1 has the correct ISWC',
    );

    $work = $test->c->model('Work')->get_by_id(5);
    $test->c->model('ISWC')->load_for_works($work);
    is($work->all_iswcs, 2, 'Work 5 has 2 ISWCs');
    cmp_bag(
        [ map { $_->iswc } $work->all_iswcs ],
        [ 'T-500.000.001-0', 'T-500.000.002-0' ],
        'Work 5 has the correct ISWCs',
    );

    $work = $test->c->model('Work')->get_by_id(10);
    $test->c->model('ISWC')->load_for_works($work);
    is($work->all_iswcs, 0, 'Work 10 has no ISWCs');
};

test 'Test find_by_iswc' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+work');

    my @iswcs = $test->c->model('ISWC')->find_by_iswc('T-000.000.001-0');
    is(@iswcs, 1, 'Found 1 ISWC for existing ISWC');

    @iswcs = $test->c->model('ISWC')->find_by_iswc('T-111.222.331-0');
    is(@iswcs, 0, 'Found 0 ISWCs for non-existent ISWC');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
