package t::MusicBrainz::Server::Controller::Recording::Aliases;
use strict;
use warnings;

use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok page_test_jsonld );

with 't::Mechanize', 't::Context';

=head1 DESCRIPTION

This test checks whether recording aliases are correctly listed on the
recording alias page, both on the site itself and on the JSON-LD data.

=cut

test 'Recording alias appears on alias page content and on JSON-LD' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    $mech->get_ok(
        '/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/aliases',
        'Fetched recording aliases page',
    );
    html_ok($mech->content);

    $mech->text_contains('King of the Mt.', 'Alias page lists the alias');
    $mech->text_contains('Recording name', 'Alias page lists the alias type');

    page_test_jsonld $mech => {
        '@id' => 'http://musicbrainz.org/recording/54b9d183-7dab-42ba-94a3-7388a66604b8',
        'alternateName' => ['King of the Mt.'],
        'isrcCode' => 'DEE250800230',
        '@type' => 'MusicRecording',
        '@context' => 'https://schema.org/docs/jsonldcontext.json',
        'duration' => 'PT04M54S',
        'name' => 'King of the Mountain'
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
