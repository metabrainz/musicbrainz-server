package t::MusicBrainz::Server::Controller::CDTOC::Show;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether the disc ID page displays data about both the disc ID
itself and the releases the disc ID is attached to.

=cut

test 'Disc ID page contains the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+controller_cdtoc');

    $mech->get_ok(
        '/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI-',
        'Fetched disc ID page',
    );
    html_ok($mech->content);

    $mech->text_contains(
        '1 7 171327 150 22179 49905 69318 96240 121186 143398',
        'The full TOC is displayed',
    );
    $mech->text_contains(
        '5908ea07',
        'The FreeDB ID for the disc ID is displayed',
    );
    $mech->text_contains(
        'Total tracks:7',
        'The number of tracks on the disc ID is displayed',
    );

    $mech->content_contains(
        '/release/85455330-cae8-11de-8a39-0800200c9a66',
        'A link to the associated release is present',
    );
    $mech->content_like(qr{Aerial}, 'The release title is displayed');
    $mech->content_like(qr{Kate Bush}, 'The release artist is displayed');
    $mech->content_like(
        qr{<td>\s*CD\s*</td>},
        'The medium format is displayed',
    );

    $mech->get_ok(
      '/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI',
      'Fetched the disc ID page, without the ending dash',
    );

    ok(
        $mech->uri =~ qr{/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI-/?$},
        'The user is redirected to the version with the dash',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
