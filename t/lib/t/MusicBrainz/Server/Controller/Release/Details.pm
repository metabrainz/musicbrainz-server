package t::MusicBrainz::Server::Controller::Release::Details;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks that the release details page contains all the expected data,
and that it shows the release sidebar data as well.

=cut

test 'Details tab has all the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok(
        '/release/f205627f-b70a-409d-adbe-66289b614e80/details',
        'Fetched release details page',
    );
    html_ok($mech->content);
    $mech->text_contains(
        'Permanent link:https://musicbrainz.org/release/f205627f-b70a-409d-adbe-66289b614e80',
        'The details tab contains the release permalink',
    );
    $mech->text_contains(
        'MBID:f205627f-b70a-409d-adbe-66289b614e80',
        'The details tab contains the MBID in plain text',
    );
    $mech->text_contains(
        'Last updated:2020-02-20 00:00 UTC',
        'The details tab contains the last updated date',
    );
    $mech->text_contains(
        '/ws/2/release/f205627f-b70a-409d-adbe-66289b614e80?',
        'The details tab contains a WS link',
    );

    # Sidebar content
    $mech->text_contains(
        'CD',
        'The details page displays the medium format',
    );
    $mech->text_contains(
        'Official',
        'The details page displays the release status',
    );
    $mech->text_contains(
        'Album',
        'The details page displays the release group type',
    );
    $mech->text_contains(
        '343 960 2',
        'The details page displays the catalog number',
    );
    $mech->text_contains(
        'Warp Records',
        'The details page displays the label name',
    );
    $mech->content_contains(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190',
        'The details page contains a link to the label',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
