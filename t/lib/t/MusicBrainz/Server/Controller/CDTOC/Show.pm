package t::MusicBrainz::Server::Controller::CDTOC::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether the disc ID page displays data about the releases
the disc ID is attached to.

=cut

test 'Test disc ID page display' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+controller_cdtoc');

    $mech->get_ok(
        '/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI-',
        'Fetched disc ID page',
    );
    html_ok($mech->content);
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
