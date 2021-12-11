package t::MusicBrainz::Server::Controller::Artist::Aliases;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test aliases
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/aliases', 'get artist aliases');
html_ok($mech->content);
$mech->content_contains('Test Alias', 'has the artist alias');
$mech->content_contains('2000-01-01', 'has alias begin date');
$mech->content_contains('2005-05-06', 'has alias end date');

page_test_jsonld $mech => {
    '@context' => 'http://schema.org',
    '@id' => 'http://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce',
    '@type' => ['Person', 'MusicGroup'],
    'alternateName' => ['Test Alias'],
    'birthDate' => '2008-01-02',
    'birthPlace' => {
        '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
        '@type' => 'Country',
        'name' => 'United Kingdom',
    },
    'deathPlace' => {
        '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
        '@type' => 'Country',
        'name' => 'United Kingdom',
    },
    'deathDate' => '2009-03-04',
    'location' => {
        '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
        '@type' => 'Country',
        'name' => 'United Kingdom',
    },
    'name' => 'Test Artist',
};

$mech->get_ok('/artist/60e5d080-c964-11de-8a39-0800200c9a66', 'get artist aliases');
html_ok($mech->content);
$mech->content_unlike(qr/Test Alias/, 'other artist pages do not have the alias');

page_test_jsonld $mech => {
    '@context' => 'http://schema.org',
    '@type' => 'MusicGroup',
    '@id' => 'http://musicbrainz.org/artist/60e5d080-c964-11de-8a39-0800200c9a66',
    'name' => 'Empty Artist'
};

};

1;
