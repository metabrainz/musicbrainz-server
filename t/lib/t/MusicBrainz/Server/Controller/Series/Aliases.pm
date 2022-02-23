package t::MusicBrainz::Server::Controller::Series::Aliases;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Edit';
with 't::Mechanize';
with 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+series');

    $mech->get_ok('/series/a8749d0c-4a5a-4403-97c5-f6cd018f8e6d/aliases', 'get series aliases');
    html_ok($mech->content);
    $mech->content_contains('Test Series Alias', 'has the series alias');
    $mech->content_contains('Search hint', 'has the series alias type');
};

1;
