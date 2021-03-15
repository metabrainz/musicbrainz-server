package t::MusicBrainz::Server::Controller::Place::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');
    MusicBrainz::Server::Test->prepare_test_database($c, '+place');

    $mech->get_ok('/place/df9269dd-0470-4ea2-97e8-c11e46080edd', 'fetch place index page');
    html_ok($mech->content);

    page_test_jsonld $mech => {
        'containedIn' => {
            'name' => 'Europe',
            '@id' => 'http://musicbrainz.org/area/89a675c2-3e37-3518-b83c-418bad59a85a',
            '@type' => 'Country'
        },
        'name' => 'A Test Place',
        'geo' => {
            '@type' => 'GeoCoordinates',
            'longitude' => '1.234',
            'latitude' => '0.323'
        },
        '@type' => 'Place',
        '@context' => 'http://schema.org',
        'foundingDate' => '2013',
        '@id' => 'http://musicbrainz.org/place/df9269dd-0470-4ea2-97e8-c11e46080edd'
    };
};

1;
