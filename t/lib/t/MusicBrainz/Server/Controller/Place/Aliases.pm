package t::MusicBrainz::Server::Controller::Place::Aliases;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether place aliases are correctly listed on the place
alias page, both on the site itself and on the JSON-LD data.

=cut

test 'Place alias appears on alias page content and on JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');
    MusicBrainz::Server::Test->prepare_test_database($c, '+place');

    $mech->get_ok(
        '/place/df9269dd-0470-4ea2-97e8-c11e46080edd/aliases',
        'Fetched place aliases page',
    );
    html_ok($mech->content);

    $mech->text_contains('A Test Alias', 'Alias page lists the alias');
    $mech->text_contains('Place name', 'Alias page lists the alias type');

    page_test_jsonld $mech => {
        'foundingDate' => '2013',
        'containedIn' => {
            '@type' => 'Country',
            '@id' => 'http://musicbrainz.org/area/89a675c2-3e37-3518-b83c-418bad59a85a',
            'name' => 'Europe'
        },
        'alternateName' => ['A Test Alias'],
        'geo' => {
            'latitude' => '0.323',
            'longitude' => '1.234',
            '@type' => 'GeoCoordinates'
        },
        'name' => 'A Test Place',
        '@context' => 'http://schema.org',
        '@type' => 'Place',
        '@id' => 'http://musicbrainz.org/place/df9269dd-0470-4ea2-97e8-c11e46080edd'
    };
};

1;
