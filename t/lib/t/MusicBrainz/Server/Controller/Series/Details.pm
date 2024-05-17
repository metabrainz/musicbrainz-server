package t::MusicBrainz::Server::Controller::Series::Details;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks that the series details page contains all the expected data.

=cut

test 'Details tab has all the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get_ok(
        '/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/details',
        'Fetched series details page',
    );
    html_ok($mech->content);
    $mech->text_contains(
        'Permanent link:https://musicbrainz.org/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d',
        'The details tab contains the series permalink',
    );
    $mech->text_contains(
        'MBID:a8749d0c-4a5a-4403-97c5-f6cd018f8e6d',
        'The details tab contains the MBID in plain text',
    );
    $mech->text_contains(
        'Last updated:2002-02-20 00:00 UTC',
        'The details tab contains the last updated date',
    );
    $mech->text_contains(
        '/ws/2/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d?',
        'The details tab contains a WS link',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
