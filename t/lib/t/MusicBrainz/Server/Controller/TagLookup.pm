package t::MusicBrainz::Server::Controller::TagLookup;
use utf8;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( html_ok );

around run_test => sub {
    my ($orig, $test, @args) = @_;
    MusicBrainz::Server::Test->prepare_test_database($test->c);
    $test->$orig(@args);
};

with 't::Context', 't::Mechanize';

test 'Can perform tag lookups with artist and release titles' => sub {
    my $test = shift;
    $test->mech->get_ok('/taglookup?artist=中島+美嘉&release=love', 'performed tag lookup');
    html_ok($test->mech->content);
    $test->mech->content_contains('中島美嘉', 'has correct artist result');
    $test->mech->content_contains('LOVE', 'has correct release result');
};

test 'Can perform tag lookups with PUIDs' => sub {
    my $test = shift;
    $test->mech->get_ok('/taglookup?puid=b9c8f51f-cc9a-48fa-a415-4c91fcca80f0', 'lookup puid ... ');
    html_ok($test->mech->content);
    $test->mech->content_contains('ABBA', 'has correct artist result');
    $test->mech->content_contains('Arrival', 'has correct release result');
};

1;
