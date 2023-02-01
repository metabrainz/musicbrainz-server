package t::MusicBrainz::Server::Controller::Place::Aliases;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether place aliases are correctly listed on the place
alias page, both on the site itself and on the JSON-LD data.

=cut

test 'Place alias appears on alias page content and on JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');
    MusicBrainz::Server::Test->prepare_test_database($c, '+area_hierarchy');
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
        'alternateName' => ['A Test Alias'],
        'geo' => {
            'latitude' => '0.323',
            'longitude' => '1.234',
            '@type' => 'GeoCoordinates'
        },
        'name' => 'A Test Place',
        '@context' => 'https://schema.org/docs/jsonldcontext.json',
        '@type' => 'Place',
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
