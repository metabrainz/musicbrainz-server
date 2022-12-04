package t::MusicBrainz::Server::Data::ISRC;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use MusicBrainz::Server::Data::ISRC;

use Sql;
use MusicBrainz::Server::Test;

with 't::Context';

=head1 DESCRIPTION

This test checks different ISRC functions.

=cut

test 'Test get_by_id' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+isrc');

    my $isrc = $test->c->model('ISRC')->get_by_id(1);
    is($isrc->id, 1, 'Found ISRC with ID 1');
    is($isrc->isrc, 'DEE250800230', 'The ISRC is DEE250800230');
};

test 'Test find_by_recordings' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+isrc');

    my @isrcs = $test->c->model('ISRC')->find_by_recordings(1);
    is(@isrcs, 1, 'Found 1 ISRC for recording 1');
    is($isrcs[0]->isrc, 'DEE250800230', 'The ISRC is DEE250800230');


    @isrcs = $test->c->model('ISRC')->find_by_recordings(2);
    is(@isrcs, 2, 'Found 2 ISRCs for recording 2');
    is($isrcs[0]->isrc, 'DEE250800230', 'The first ISRC is DEE250800230');
    is($isrcs[1]->isrc, 'DEE250800231', 'The second ISRC is DEE250800231');

    @isrcs = $test->c->model('ISRC')->find_by_recordings([1, 2]);
    is(@isrcs, 3, 'Found 3 ISRCs that are linked to recordings 1 or 2');
};

test 'Test merge_recordings' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+isrc');

    note('We merge the ISRCs from two recordings');
    $test->c->model('ISRC')->merge_recordings(1, 2);

    my @isrcs = $test->c->model('ISRC')->find_by_recordings(1);
    is(scalar @isrcs, 2, 'The destination recording has 2 ISRCs');
    is($isrcs[0]->isrc, 'DEE250800230', 'The first ISRC is DEE250800230');
    is($isrcs[1]->isrc, 'DEE250800231', 'The second ISRC is DEE250800231');

    @isrcs = $test->c->model('ISRC')->find_by_recordings(2);
    is(scalar @isrcs, 0, 'The merged recording has no ISRCs now');
};

test 'Can merge with multiple recordings and the same ISRC' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+isrc');

    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO isrc (id, recording, isrc)
            VALUES (4, 3, 'DEE250800230');
        SQL

    $c->model('ISRC')->merge_recordings(1, 2, 3);

    my @isrcs = $c->model('ISRC')->find_by_recordings(1);
    is(scalar @isrcs, 2, 'The merged recording has 2 ISRCs');
};

test 'Test delete_recordings' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+isrc');

    note('We delete ISRCs from recording 1');
    $test->c->model('ISRC')->delete_recordings(1);

    my @isrcs = $test->c->model('ISRC')->find_by_recordings(1);
    is(@isrcs, 0, 'There are no ISRCs for recording 1');
};

test 'Test insert' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+isrc');

    note('We add an ISRC to recording 3');
    $test->c->model('ISRC')->insert({
        isrc => 'DEE250800232',
        recording_id => 3,
    });

    my @isrcs = $test->c->model('ISRC')->find_by_recordings(3);
    is(@isrcs, 1, 'Found one ISRC for recording 3');
    is($isrcs[0]->isrc, 'DEE250800232', 'The correct ISRC was returned');
    is(
        $isrcs[0]->recording_id,
        3,
        'The ISRC has a back-reference to recording 3',
    );
};

test 'Test delete' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+isrc');

    note('We delete ISRC 1');
    $test->c->model('ISRC')->delete(1);
    ok(
        !defined $test->c->model('ISRC')->get_by_id(1),
        'ISRC 1 no longer exists',
    );
};

test 'Test find_by_isrc' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+isrc');

    my @isrcs = $test->c->model('ISRC')->find_by_isrc('DEE250800231');
    is(@isrcs, 1, 'Found 1 ISRC for existing ISRC');

    @isrcs = $test->c->model('ISRC')->find_by_isrc('DEE250850231');
    is(@isrcs, 0, 'Found 0 ISRCs for non-existent ISRC');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
