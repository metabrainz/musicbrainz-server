package t::MusicBrainz::Server::Controller::Statistics;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( html_ok );

with 't::Context', 't::Mechanize';

sub initialize_stats {
    my ($c) = @_;

    # Some general sample data to calculate stats from
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+statistics');

    $c->model('Statistics')->recalculate_all;
};

sub statistics_test {
    my (@endpoints) = @_;
    return sub {
        my ($test) = @_;
        for my $endpoint (@endpoints) {
            $test->mech->get_ok($endpoint, "Fetched $endpoint okay without stats");
            html_ok($test->mech->content);
        }

        initialize_stats($test->c);

        for my $endpoint (@endpoints) {
            $test->mech->get_ok($endpoint, "Fetched $endpoint okay with stats");
            html_ok($test->mech->content);

            if ($endpoint !~ /timeline/) {
                $test->mech->content_like(qr{Last updated: [0-9]+}, "Last updated date is shown on $endpoint");
            }
        }
    }
}

test 'Fetch statistics pages' => statistics_test(
    '/statistics',
    '/statistics/countries',
    '/statistics/coverart',
    '/statistics/languages-scripts',
    '/statistics/formats',
    '/statistics/relationships',
    '/statistics/edits',
    '/statistics/editors',

    '/statistics/timeline',
    '/statistics/timeline/main',
    '/statistics/timeline/count.artist');

test 'country statistics have area links' => sub {
    my $test = shift;
    initialize_stats($test->c);

    $test->mech->get_ok('/statistics/countries');
    $test->mech->content_like(qr%/area/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"%, 'Has links to main area pages');
    $test->mech->content_like(qr%/area/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/artists"%, 'Has links to artist area pages');
    $test->mech->content_like(qr%/area/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/labels"%, 'Has links to label area pages');
    $test->mech->content_like(qr%/area/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/releases"%, 'Has links to release area pages');
};

test 'Fetch /statistics/dataset' => sub {
    my $test = shift;
    $test->mech->get_ok('/statistics/dataset/count.artist');
    like($test->mech->content, qr{^\s*\[.*\]\s*$}, "Looks like a JSON array");

    initialize_stats($test->c);

    $test->mech->get_ok('/statistics/dataset/count.artist');
    like($test->mech->content, qr{^\s*\[.*[0-9].*\]\s*$}, "Looks like a JSON array including at least one number");
};

1;
