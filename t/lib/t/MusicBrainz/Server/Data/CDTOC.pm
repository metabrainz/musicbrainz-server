package t::MusicBrainz::Server::Data::CDTOC;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::CDTOC;
use MusicBrainz::Server::Data::MediumCDTOC;

use Sql;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Entity::Medium;

with 't::Context';

=head1 DESCRIPTION

This test checks different functions for Data::CDTOC.

=cut

test 'get_by_id' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+cdtoc');

    my $cdtoc_data = $test->c->model('CDTOC');

    my $cdtoc = $cdtoc_data->get_by_id(1);
    is($cdtoc->id, 1, 'get_by_id returns the right CD TOC');
    is(
        $cdtoc->discid,
        'tLGBAiCflG8ZI6lFcOt87vXjEcI-',
        'The returned CD TOC has the right disc id',
    );
    is(
        $cdtoc->freedb_id,
        '5908ea07',
        'The returned CD TOC has the right FreeDB id',
    );
    is(
        $cdtoc->track_count,
        7,
        'The returned CD TOC has the right track count',
    );
    is(
        $cdtoc->leadout_offset,
        171327,
        'The returned CD TOC has the right leadout offset',
    );
    is(
        $cdtoc->track_offset->[0],
        150,
        'The first track of the returned CD TOC has the right offset',
    );
    is(
        $cdtoc->track_offset->[6],
        143398,
        'The last track of the returned CD TOC has the right offset',
    );
};

test 'get_by_discid' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+cdtoc');

    my $cdtoc_data = $test->c->model('CDTOC');

    my $cdtoc = $cdtoc_data->get_by_discid('tLGBAiCflG8ZI6lFcOt87vXjEcI-');
    is($cdtoc->id, 1, 'get_by_discid returns the right CD TOC');
};

test 'find_or_insert' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+cdtoc');

    my $cdtoc_data = $test->c->model('CDTOC');

    my $id = $cdtoc_data->find_or_insert(
        '1 9 253125 150 38550 69970 83577 100540 118842 168737 194517 228310',
    );
    my $id2 = $cdtoc_data->find_or_insert(
        '1 9 253125 150 38550 69970 83577 100540 118842 168737 194517 228310',
    );
    ok(
        $id == $id2,
        'The returned value for equal find_or_insert calls is the same',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
