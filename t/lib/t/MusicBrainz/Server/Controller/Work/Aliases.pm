package t::MusicBrainz::Server::Controller::Work::Aliases;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+controller_work');

    $mech->get_ok('/work/559be0c1-2c87-45d6-ba43-1b1feb8f831e/aliases', 'fetch work aliases tab');
    html_ok($mech->content);

    page_test_jsonld $mech => {
        'sameAs' => 'http://musicbrainz.org/work/a30a4245-a7ec-4979-8b1e-b549f2782239',
        '@context' => 'http://schema.org',
        '@id' => 'http://musicbrainz.org/work/559be0c1-2c87-45d6-ba43-1b1feb8f831e',
        'iswcCode' => ['T-000.000.001-0', 'T-000.000.002-0'],
        'alternateName' => ['WA1', 'WA2'],
        'inLanguage' => 'en',
        'name' => 'W1',
        '@type' => 'MusicComposition'
    };
};

1;
