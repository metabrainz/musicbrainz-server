package t::MusicBrainz::Server::Controller::Tracklist;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( html_ok );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    MusicBrainz::Server::Test->prepare_test_database($test->c);
    $test->$orig(@args);
};

with 't::Context', 't::Mechanize';

test 'Can fetch /tracklist pages' => sub {
    my $test = shift;
    $test->mech->get_ok("/tracklist/1", 'fetch tracklist index page');
    html_ok($test->mech->content);
    $test->mech->content_contains('Dancing Queen', 'track 1');
    $test->mech->content_contains('/recording/123c079d-374e-4436-9448-da92dedef3ce', 'track 1');
    $test->mech->content_contains('ABBA', 'track 1');
    $test->mech->content_contains('/artist/a45c079d-374e-4436-9448-da92dedef3cf', 'track 1');
    $test->mech->content_contains('2:03', 'track 1');

    $test->mech->content_contains('Dancing Queen', 'track 2');
    $test->mech->content_contains('/recording/123c079d-374e-4436-9448-da92dedef3ce', 'track 1');
    $test->mech->content_contains('ABBA', 'track 1');
    $test->mech->content_contains('/artist/a45c079d-374e-4436-9448-da92dedef3cf', 'track 1');
    $test->mech->content_contains('2:03', 'track 1');

    $test->mech->content_contains('/release/f34c079d-374e-4436-9448-da92dedef3ce', 'shows releases');
    $test->mech->content_contains('Arrival', 'shows releases');
    $test->mech->content_contains('1/2', 'release medium position');
    $test->mech->content_contains('Warp Records', 'release label');
    $test->mech->content_contains('ABC-123', 'release catno');
    $test->mech->content_contains('ABC-123-X', 'release catno');
    $test->mech->content_contains('GB', 'release country');
    $test->mech->content_contains('2009-05-08', 'release date');
};

1;
