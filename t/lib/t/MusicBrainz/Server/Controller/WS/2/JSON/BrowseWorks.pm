package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseWorks;
use utf8;
use strict;
use warnings;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2,
};

with 't::Mechanize', 't::Context';

test 'browse works via artist (first page)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse works via artist (first page)',
    '/work?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&limit=5' =>
        {
            'work-offset' => 0,
            'work-count' => 10,
            works => [
                {
                    attributes => [],
                    id => '25c7c80f-a624-3b3e-b643-4204b05cb447',
                    title => 'On My Bus',
                    disambiguation => '',
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    'type-id' => JSON::null,
                },
                {
                    attributes => [],
                    id => '2734cd31-4bab-3bf6-a758-c5d94ad957bb',
                    title => 'Marbles',
                    disambiguation => '',
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    'type-id' => JSON::null,
                },
                {
                    attributes => [],
                    id => '294f16fe-e123-3634-a0f4-03953e111321',
                    title => 'Busy Working',
                    disambiguation => '',
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    'type-id' => JSON::null,
                },
                {
                    attributes => [],
                    id => '37814c05-f7ff-308d-a339-21570bc56003',
                    title => 'Be Rude to Your School',
                    disambiguation => '',
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    'type-id' => JSON::null,
                },
                {
                    attributes => [],
                    id => '3a62a9f7-1365-32aa-9da8-3e0ef1f2b0ca',
                    title => 'Bibi Plone',
                    disambiguation => '',
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    'type-id' => JSON::null,
                }],
        };
};


test 'browse works via artist (second page)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse works via artist (second page)',
    '/work?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&limit=5&offset=5' =>
        {
            'work-offset' => 5,
            'work-count' => 10,
            works => [
                {
                    attributes => [],
                    id => '4290c4aa-f538-31d8-b502-cb01fc7fc5af',
                    title => 'Top & Low Rent',
                    disambiguation => '',
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    'type-id' => JSON::null,
                },
                {
                    attributes => [],
                    id => '482530c1-a2ab-32e8-be43-ea5240aa7913',
                    title => 'Plock',
                    disambiguation => '',
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    'type-id' => JSON::null,
                },
                {
                    attributes => [],
                    id => '93836f17-7646-374e-a679-455429162c20',
                    title => 'Press a Key',
                    disambiguation => '',
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    'type-id' => JSON::null,
                },
                {
                    attributes => [],
                    id => 'e67f54be-a68b-351d-9fbf-57468e61fd95',
                    title => 'Summer Plays Out',
                    disambiguation => '',
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    'type-id' => JSON::null,
                },
                {
                    attributes => [],
                    id => 'f4f581d8-50e0-3886-bcd3-610187821bcd',
                    title => 'The Greek Alphabet',
                    disambiguation => '',
                    iswcs => [],
                    language => JSON::null,
                    languages => [],
                    type => JSON::null,
                    'type-id' => JSON::null,
                }],
        };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
