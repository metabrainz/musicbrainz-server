package t::MusicBrainz::Server::Controller::Artist::Aliases;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether artist aliases are correctly listed on the artist
alias page, both on the site itself and on the JSON-LD data.

=cut

test 'Artist alias appears on alias page content and on JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database(
        $c,
        '+controller_artist',
    );

    $mech->get_ok(
        '/artist/745c079d-374e-4436-9448-da92dedef3ce/aliases',
        'Fetched artist aliases page',
    );
    html_ok($mech->content);

    $mech->text_contains('Test Alias', 'Alias page lists the alias');
    $mech->text_contains('Artist name', 'Alias page lists the alias type');
    $mech->text_contains(
        '2000-01-01',
        'Alias page lists the alias begin date',
    );
    $mech->text_contains(
        '2005-05-06',
        'Alias page lists the alias end date',
    );

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
};

1;
