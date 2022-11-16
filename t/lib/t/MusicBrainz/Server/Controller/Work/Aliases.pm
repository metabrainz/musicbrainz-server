package t::MusicBrainz::Server::Controller::Work::Aliases;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether work aliases are correctly listed on the work
alias page, both on the site itself and on the JSON-LD data.

=cut

test 'Work alias appears on alias page content and on JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+controller_work');

    $mech->get_ok(
        '/work/559be0c1-2c87-45d6-ba43-1b1feb8f831e/aliases',
        'Fetched release aliases page',
    );
    html_ok($mech->content);

    $mech->text_contains('WA1', 'Alias page lists the first alias');
    $mech->text_contains('WA2', 'Alias page lists the second alias');
    $mech->text_contains('Work name', 'Alias page lists the alias type');

    page_test_jsonld $mech => {
        'sameAs' => 'http://musicbrainz.org/work/a30a4245-a7ec-4979-8b1e-b549f2782239',
        '@context' => 'http://schema.org',
        '@id' => 'http://musicbrainz.org/work/559be0c1-2c87-45d6-ba43-1b1feb8f831e',
        'iswcCode' => ['T-000.000.001-0', 'T-000.000.002-0'],
        'alternateName' => ['WA1', 'WA2'],
        'inLanguage' => 'en',
        'name' => 'W1',
        '@type' => 'MusicComposition'
    };
};

1;
