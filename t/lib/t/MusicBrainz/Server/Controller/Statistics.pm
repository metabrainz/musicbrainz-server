package t::MusicBrainz::Server::Controller::Statistics;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( html_ok );

sub initialize_stats {
    my ($c) = @_;

    # Some general sample data to calculate stats from
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+statistics');

    $c->model('Statistics')->recalculate_all;
};

with 't::Context', 't::Mechanize';

test 'Fetch /statistics' => sub {
    my $test = shift;
    $test->mech->get_ok('/statistics');
    html_ok($test->mech->content);

    initialize_stats($test->c);

    $test->mech->get_ok('/statistics');
    html_ok($test->mech->content);
};

test 'Fetch /statistics/countries' => sub {
    my $test = shift;
    $test->mech->get_ok('/statistics/countries');
    html_ok($test->mech->content);

    initialize_stats($test->c);

    $test->mech->get_ok('/statistics/countries');
    html_ok($test->mech->content);
};

test 'Fetch /statistics/coverart' => sub {
    my $test = shift;
    $test->mech->get_ok('/statistics/coverart');
    html_ok($test->mech->content);

    initialize_stats($test->c);

    $test->mech->get_ok('/statistics/coverart');
    html_ok($test->mech->content);
};

test 'Fetch /statistics/languages-scripts' => sub {
    my $test = shift;
    $test->mech->get_ok('/statistics/languages-scripts');
    html_ok($test->mech->content);

    initialize_stats($test->c);

    $test->mech->get_ok('/statistics/languages-scripts');
    html_ok($test->mech->content);
};

test 'Fetch /statistics/formats' => sub {
    my $test = shift;
    $test->mech->get_ok('/statistics/formats');
    html_ok($test->mech->content);

    initialize_stats($test->c);

    $test->mech->get_ok('/statistics/formats');
    html_ok($test->mech->content);
};

test 'Fetch /statistics/relationships' => sub {
    my $test = shift;
    $test->mech->get_ok('/statistics/relationships');
    html_ok($test->mech->content);

    initialize_stats($test->c);

    $test->mech->get_ok('/statistics/relationships');
    html_ok($test->mech->content);
};

test 'Fetch /statistics/edits' => sub {
    my $test = shift;
    $test->mech->get_ok('/statistics/edits');
    html_ok($test->mech->content);

    initialize_stats($test->c);

    $test->mech->get_ok('/statistics/edits');
    html_ok($test->mech->content);
};

test 'Fetch /statistics/editors' => sub {
    my $test = shift;
    $test->mech->get_ok('/statistics/editors');
    html_ok($test->mech->content);

    initialize_stats($test->c);

    $test->mech->get_ok('/statistics/editors');
    html_ok($test->mech->content);
};

test 'Fetch /statistics/timeline' => sub {
    my $test = shift;
    $test->mech->get_ok('/statistics/timeline');
    html_ok($test->mech->content);

    $test->mech->get_ok('/statistics/timeline/main');
    html_ok($test->mech->content);

    $test->mech->get_ok('/statistics/timeline/count.artist');
    html_ok($test->mech->content);

    initialize_stats($test->c);

    $test->mech->get_ok('/statistics/timeline');
    html_ok($test->mech->content);

    $test->mech->get_ok('/statistics/timeline/main');
    html_ok($test->mech->content);

    $test->mech->get_ok('/statistics/timeline/count.artist');
    html_ok($test->mech->content);
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
