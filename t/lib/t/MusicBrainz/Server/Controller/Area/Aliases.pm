package t::MusicBrainz::Server::Controller::Area::Aliases;
use utf8;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether area aliases are correctly listed on the area
alias page, both on the site itself and on the JSON-LD data.

=cut

test 'Area alias appears on alias page content and on JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+area');

    $mech->get_ok(
        '/area/106e0bec-b638-3b37-b731-f53d507dc00e/aliases',
        'Fetched area aliases page',
    );
    html_ok($mech->content);

    $mech->text_contains('オーストラリア', 'Alias page lists the alias');
    $mech->text_contains('Area name', 'Alias page lists the alias type');

    page_test_jsonld $mech => {
        '@id' => 'http://musicbrainz.org/area/106e0bec-b638-3b37-b731-f53d507dc00e',
        'alternateName' => ["\x{30aa}\x{30fc}\x{30b9}\x{30c8}\x{30e9}\x{30ea}\x{30a2}"],
        '@context' => 'http://schema.org',
        'name' => 'Australia',
        '@type' => 'Country'
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
