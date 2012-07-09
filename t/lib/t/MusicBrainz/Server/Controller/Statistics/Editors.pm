package t::MusicBrainz::Server::Controller::Statistics::Editors;
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Test qw( html_ok );
with 't::Context', 't::Mechanize';

test 'Fetch /statistics/editors' => sub {
    my $test = shift;
    $test->mech->get_ok('/statistics/editors');
    html_ok($test->mech->content);
};

1;
