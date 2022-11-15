package t::MusicBrainz::Server::Data::ISRC;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::ISRC;

use Sql;
use MusicBrainz::Server::Test;

with 't::Context';

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
    is(scalar @isrcs, 2);
};

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_test_database($test->c, '+isrc');

my $isrc = $test->c->model('ISRC')->get_by_id(1);
is($isrc->id, 1);
is($isrc->isrc, 'DEE250800230');


my @isrcs = $test->c->model('ISRC')->find_by_recordings(1);
is(scalar @isrcs, 1);
is($isrcs[0]->isrc, 'DEE250800230');


@isrcs = $test->c->model('ISRC')->find_by_recordings(2);
is(scalar @isrcs, 2);
is($isrcs[0]->isrc, 'DEE250800230');
is($isrcs[1]->isrc, 'DEE250800231');

@isrcs = $test->c->model('ISRC')->find_by_recordings([1, 2]);
is(scalar @isrcs, 3);

my $sql = $test->c->sql;
$sql->begin;
$test->c->model('ISRC')->merge_recordings(1, 2);
$sql->commit;

@isrcs = $test->c->model('ISRC')->find_by_recordings(1);
is(scalar @isrcs, 2);
is($isrcs[0]->isrc, 'DEE250800230');
is($isrcs[1]->isrc, 'DEE250800231');

@isrcs = $test->c->model('ISRC')->find_by_recordings(2);
is(scalar @isrcs, 0);

$sql->begin;
$test->c->model('ISRC')->delete_recordings(1);
$sql->commit;

@isrcs = $test->c->model('ISRC')->find_by_recordings(1);
is(scalar @isrcs, 0);

$sql->begin;
$test->c->model('ISRC')->insert(
    { isrc => 'DEE250800232', recording_id => 2 }
);
$sql->commit;

@isrcs = $test->c->model('ISRC')->find_by_recordings(2);
is(scalar @isrcs, 1);
is($isrcs[0]->isrc, 'DEE250800232');

$sql->begin;

$test->c->model('ISRC')->delete(1);
$isrc = $test->c->model('ISRC')->get_by_id(1);
ok(!defined $isrc);

$sql->commit;

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
