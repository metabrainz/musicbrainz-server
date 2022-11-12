package t::MusicBrainz::Server::Controller::Area::Show;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether basic area data is correctly listed in the JSON-LD
of an area's index (main) page.

=cut

test 'Basic area data appears on JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');

    $mech->get_ok(
        '/area/3f179da4-83c6-4a28-a627-e46b4a8ff1ed',
        'Fetched area index page',
    );
    html_ok($mech->content);

    page_test_jsonld $mech => {
        '@id' => 'http://musicbrainz.org/area/3f179da4-83c6-4a28-a627-e46b4a8ff1ed',
        '@context' => 'http://schema.org',
        'name' => 'Sydney',
        '@type' => 'City',
        'containedIn' => {
            '@id' => 'http://musicbrainz.org/area/106e0bec-b638-3b37-b731-f53d507dc00e',
            '@type' => 'Country',
            'name' => 'Australia',
        },
    };
};

1;
