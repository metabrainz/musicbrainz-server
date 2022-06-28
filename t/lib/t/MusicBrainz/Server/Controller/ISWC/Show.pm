package t::MusicBrainz::Server::Controller::ISWC::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether linked works are appropriately displayed on the ISWC
index page, and whether different ISWC formats all reach the same page.

=cut

test 'ISWC index page contains the expected data' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+controller_iswc');

    $mech->get_ok(
        '/iswc/T-702.152.911-5',
        'Fetched ISWC index page using the default format',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'vient le vent',
        'The title of a work assigned this ISWC is listed',
    );

    $mech->get_ok(
        '/iswc/T-702.152.911.5',
        'Fetched ISWC index page using only periods',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'vient le vent',
        'The title of a work assigned this ISWC is still listed',
    );

    $mech->get_ok(
        '/iswc/T7021529115',
        'Fetched ISWC index page using no punctuation',
    );
    html_ok($mech->content);
    $mech->content_contains(
        'vient le vent',
        'The title of a work assigned this ISWC is still listed',
    );

    $mech->get('/iswc/xxx');
    is($mech->status(), 404, 'Invalid ISWC page 404s');
};

1;
