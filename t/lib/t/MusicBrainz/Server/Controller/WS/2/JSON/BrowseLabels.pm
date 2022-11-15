package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseLabels;
use utf8;
use strict;
use warnings;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'browse labels via release' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse labels via release',
    '/label?release=aff4a693-5970-4e2e-bd46-e2ee49c22de7' =>
        {
            'label-count' => 1,
            'label-offset' => 0,
            labels => [
                {
                    type => 'Original Production',
                    'type-id' => '7aaa37fe-2def-3476-b359-80245850062d',
                    id => '72a46579-e9a0-405a-8ee1-e6e6b63b8212',
                    name => 'rhythm zone',
                    'sort-name' => 'rhythm zone',
                    country => 'JP',
                    'area' => {
                        disambiguation => '',
                        'id' => '2db42837-c832-3c27-b4a3-08198f75693c',
                        'name' => 'Japan',
                        'sort-name' => 'Japan',
                        'iso-3166-1-codes' => ['JP'],
                        'type' => JSON::null,
                        'type-id' => JSON::null,
                    },
                    'life-span' => {
                        begin => JSON::null,
                        end => JSON::null,
                        ended => JSON::false,
                    },
                    disambiguation => '',
                    'label-code' => JSON::null,
                    ipis => [],
                    isnis => [],
                }]
        };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
