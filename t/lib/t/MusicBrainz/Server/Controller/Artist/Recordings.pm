package t::MusicBrainz::Server::Controller::Artist::Recordings;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether the artist recordings page properly displays
recordings for the artist, both on the site itself and on the JSON-LD data.

=cut

test 'Artist recordings page contains the expected data and JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_artist');

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/recordings',
        'Fetched artist recordings page',
    );
    html_ok($mech->content);
    $mech->title_like(
        qr/Test Artist/,
        'The page title contains Test Artist',
    );
    $mech->title_like(
        qr/recordings/i,
        'The page title indicates this is a recordings listing',
    );
    $mech->content_contains('Test Recording', 'The recording name is listed');
    $mech->content_contains('2:03', 'The recording length is listed');
    $mech->content_contains(
        '/recording/123c079d-374e-4436-9448-da92dedef3ce',
        'A link to the recording is present',
    );

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
