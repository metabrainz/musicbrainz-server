package t::MusicBrainz::Server::Controller::ISRC::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether linked recordings are appropriately displayed
on the ISRC index page.

=cut

test 'ISRC index page contains the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+controller_isrc');

    $mech->get_ok(
        '/isrc/DEE250800230',
        'Fetched the index page for a valid ISRC in use',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'King of the Mountain',
        'The title of a recording assigned this ISRC is listed',
    );
    $mech->content_contains(
        'Kate Bush',
        'The artist of a recording assigned this ISRC is listed',
    );
    $mech->content_contains('DEE250800230', 'The ISRC itself is listed');

    $mech->get('/isrc/DEE250812345');
    is($mech->status(), 404, 'Valid but not used ISRC page 404s');

    $mech->get('/isrc/xxx');
    is($mech->status(), 404, 'Invalid ISRC page 404s');
};

1;
