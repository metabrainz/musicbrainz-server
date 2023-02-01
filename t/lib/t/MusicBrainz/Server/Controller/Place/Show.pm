package t::MusicBrainz::Server::Controller::Place::Show;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');
    MusicBrainz::Server::Test->prepare_test_database($c, '+area_hierarchy');
    MusicBrainz::Server::Test->prepare_test_database($c, '+place');

    $mech->get_ok('/place/df9269dd-0470-4ea2-97e8-c11e46080edd', 'fetch place index page');
    html_ok($mech->content);

    $mech->content_contains('London', 'mentions area');
    $mech->content_contains('England', 'mentions containing subdivision');
    $mech->content_contains('United Kingdom', 'mentions containing country');

    page_test_jsonld $mech => {
        'containedIn' => {
            'name' => 'London',
            '@id' => 'http://musicbrainz.org/area/f03d09b3-39dc-4083-afd6-159e3f0d462f',
            '@type' => 'City',
            'containedIn' => {
                'name' => 'England',
                '@id' => 'http://musicbrainz.org/area/9d5dd675-3cf4-4296-9e39-67865ebee758',
                '@type' => 'AdministrativeArea',
                'containedIn' => {
                    'name' => 'United Kingdom',
                    '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                    '@type' => 'Country',
                },
            },
        },
        'name' => 'A Test Place',
        'geo' => {
            '@type' => 'GeoCoordinates',
            'longitude' => '1.234',
            'latitude' => '0.323'
        },
        '@type' => 'Place',
        '@context' => 'https://schema.org/docs/jsonldcontext.json',
        'foundingDate' => '2013',
        '@id' => 'http://musicbrainz.org/place/df9269dd-0470-4ea2-97e8-c11e46080edd'
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
