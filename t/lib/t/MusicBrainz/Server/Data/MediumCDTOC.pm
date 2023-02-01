package t::MusicBrainz::Server::Data::MediumCDTOC;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;

use MusicBrainz::Server::Data::MediumCDTOC;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test qw( capture_edits );

with 't::Context';

=head1 DESCRIPTION

This test checks different functions for Data::MediumCDTOC, and whether
attaching a CD TOC to a medium has the expected effects.

=cut

test 'Adding a CD TOC to a medium creates SetTrackLengths edit' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+medium-cdtoc');

    my @edits = capture_edits {
        $c->model('MediumCDTOC')->insert({medium => 1, cdtoc => 1});
    } $c;

    is(@edits, 1, 'Attaching a CD TOC to a medium created 1 edit');
    isa_ok($edits[0], 'MusicBrainz::Server::Edit::Medium::SetTrackLengths');
    is($edits[0]->editor_id, 4, 'The editor for the edit is ModBot')
};

test 'Adding a CD TOC to a medium removes CD stubs' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+cdtoc');
    MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdstub_raw');
    MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
        INSERT INTO cdtoc
            (id, discid, freedb_id, track_count, leadout_offset, track_offset)
        VALUES
            (3, 'YfSgiOEayqN77Irs.VNV.UNJ0Zs-', '5908ea07', 7, 171327,
            ARRAY[150,22179,49905,69318,96240,121186,143398]);
        SQL

    my $discid = 'YfSgiOEayqN77Irs.VNV.UNJ0Zs-';
    my $cdstub = $test->c->model('CDStub')->get_by_discid($discid);
    ok($cdstub, 'CD stub exists before the CD TOC is added to a medium');

    $test->c->model('MediumCDTOC')->insert({
        medium => 1,
        cdtoc  => 3
    });

    $cdstub = $test->c->model('CDStub')->get_by_discid($discid);
    ok(
        !$cdstub,
        'CD stub no longer exists after the CD TOC is added to a medium',
    );
};

test 'find_by_discid' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+cdtoc');

    my $medium_cdtoc_data = $test->c->model('MediumCDTOC');

    my @medium_cdtoc = $medium_cdtoc_data->find_by_discid(
        'tLGBAiCflG8ZI6lFcOt87vXjEcI-',
    );
    is(scalar(@medium_cdtoc), 2, 'find_by_discid returns two results');
    is(
        $medium_cdtoc[0]->medium_id,
        1,
        'The first result is for the medium with row id 1',
    );
    is(
        $medium_cdtoc[1]->medium_id,
        2,
        'The first result is for the medium with row id 2',
    );
};

test 'medium_has_cdtoc' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+cdtoc');

    my $cdtoc_data = $test->c->model('CDTOC');
    my $medium_cdtoc_data = $test->c->model('MediumCDTOC');

    my $cdtoc = $cdtoc_data->get_by_discid('tLGBAiCflG8ZI6lFcOt87vXjEcI-');

    ok(
        $medium_cdtoc_data->medium_has_cdtoc(1, $cdtoc),
        'Medium 1 has the given CD TOC, as expected',
    );
    ok(
        $medium_cdtoc_data->medium_has_cdtoc(2, $cdtoc),
        'Medium 2 has the given CD TOC, as expected',
    );
    ok(
        !$medium_cdtoc_data->medium_has_cdtoc(3, $cdtoc),
        'Medium 3 does not have the given CD TOC, as expected',
    );
};

test 'find_by_medium' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+cdtoc');

    my $cdtoc_data = $test->c->model('CDTOC');
    my $medium_cdtoc_data = $test->c->model('MediumCDTOC');

    my @medium_cdtoc = $medium_cdtoc_data->find_by_medium(1);
    $cdtoc_data->load(@medium_cdtoc);
    is(scalar(@medium_cdtoc), 1, 'find_by_medium returns one CD TOC');
    is(
        $medium_cdtoc[0]->cdtoc_id,
        1,
        'The returned CD TOC has the expected row id',
    );
    is(
        $medium_cdtoc[0]->cdtoc->discid,
        'tLGBAiCflG8ZI6lFcOt87vXjEcI-',
        'The returned CD TOC has the expected disc id',
    );
};

test 'load_for_mediums' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+cdtoc');

    my $cdtoc_data = $test->c->model('CDTOC');
    my $medium_cdtoc_data = $test->c->model('MediumCDTOC');

    my $medium = MusicBrainz::Server::Entity::Medium->new( id => 1 );
    my @medium_cdtoc = $medium_cdtoc_data->load_for_mediums($medium);
    $cdtoc_data->load(@medium_cdtoc);
    is(scalar($medium->all_cdtocs), 1, 'load_for_mediums loads one CD TOC');
    is(
        $medium->cdtocs->[0]->cdtoc_id,
        1,
        'The loaded CD TOC has the expected row id',
    );
    is(
        $medium->cdtocs->[0]->cdtoc->discid,
        'tLGBAiCflG8ZI6lFcOt87vXjEcI-',
        'The loaded CD TOC has the expected disc id',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
