package t::MusicBrainz::Server::Controller::Artist::Recordings;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test /artist/gid/recordings
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/recordings', 'get Test Artist page');
html_ok($mech->content);
$mech->title_like(qr/Test Artist/, 'title has Test Artist');
$mech->title_like(qr/recordings/i, 'title indicates recordings listing');
$mech->content_contains('Test Recording');
$mech->content_contains('2:03');
$mech->content_contains('/recording/123c079d-374e-4436-9448-da92dedef3ce', 'has a link to the recording');

page_test_jsonld $mech => {
    'birthDate' => '2009-03-04',
    'track' => {
        'duration' => 'PT02M03S',
        '@type' => 'MusicRecording',
        '@id' => 'http://musicbrainz.org/recording/123c079d-374e-4436-9448-da92dedef3ce',
        'name' => 'Test Recording'
    },
    'name' => 'Test Artist',
    'location' => {
        'name' => 'United Kingdom',
        '@type' => 'Country',
        '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed'
    },
    '@type' => ['Person', 'MusicGroup'],
    '@context' => 'http://schema.org',
    'birthDate' => '2008-01-02',
    'birthPlace' => {
        '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
        '@type' => 'Country',
        'name' => 'United Kingdom'
    },
    'deathDate' => '2009-03-04',
    'deathPlace' => {
        '@type' => 'Country',
        '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
        'name' => 'United Kingdom'
    },
    '@id' => 'http://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce'
};

};

1;
