package t::MusicBrainz::Server::Controller::Label::Aliases;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

=head2 Test description

This test checks whether label aliases are correctly listed on the label
alias page, both on the site itself and on the JSON-LD data.

=cut

test 'Label alias appears on alias page content and on JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok(
        '/label/46f0f4cd-8aab-4b33-b698-f459faf64190/aliases',
        'Fetched label aliases page',
    );
    html_ok($mech->content);

    $mech->text_contains('Test Label Alias', 'Alias page lists the alias');
    $mech->text_contains('Label name', 'Alias page lists the alias type');

    page_test_jsonld $mech => {
        'foundingDate' => '1989-02-03',
        'dissolutionDate' => '2008-05-19',
        'sameAs' => 'http://musicbrainz.org/label/efdf3fe9-c293-4acd-b4b2-8d2a7d4f9592',
        'name' => 'Warp Records',
        'foundingLocation' => {
            'name' => 'United Kingdom',
            '@id' => 'http://musicbrainz.org/area/8a754a16-0027-3a29-b6d7-2b40ea0481ed',
            '@type' => 'Country'
        },
        '@id' => 'http://musicbrainz.org/label/46f0f4cd-8aab-4b33-b698-f459faf64190',
        '@type' => 'MusicLabel',
        '@context' => 'https://schema.org/docs/jsonldcontext.json',
        'alternateName' => ['Test Label Alias']
    };
};

1;
