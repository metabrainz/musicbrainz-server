package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupReleaseGroup;
use utf8;
use strict;
use warnings;

use JSON;
use Test::Routine;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic release group lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic release group lookup',
    '/release-group/b84625af-6229-305f-9f1b-59c0185df016' =>
        {
            id => 'b84625af-6229-305f-9f1b-59c0185df016',
            title => 'サマーれげぇ!レインボー',
            disambiguation => '',
            'first-release-date' => '2001-07-04',
            'primary-type' => 'Single',
            'primary-type-id' => 'd6038452-8ee0-3f68-affc-2de9a1ede0b9',
            'secondary-types' => [],
            'secondary-type-ids' => [],
        };
};

test 'basic release group lookup, inc=annotation' => sub {

    my $c = shift->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

    ws_test_json 'basic release group lookup, inc=annotation',
    '/release-group/22b54315-6e51-350b-bb34-e6e16f7688bd?inc=annotation' =>
        {
            id => '22b54315-6e51-350b-bb34-e6e16f7688bd',
            title => 'My Demons',
            annotation => 'this is a release group annotation',
            disambiguation => '',
            'first-release-date' => '2007-01-29',
            'primary-type' => 'Album',
            'primary-type-id' => 'f529b476-6e62-324f-b0aa-1f3e33d313fc',
            'secondary-types' => [],
            'secondary-type-ids' => [],
        };
};

test 'release group lookup with releases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release group lookup with releases',
    '/release-group/56683a0b-45b8-3664-a231-5b68efe2e7e2?inc=releases' =>
        {
            id => '56683a0b-45b8-3664-a231-5b68efe2e7e2',
            title => 'Repercussions',
            'first-release-date' => '2008-11-17',
            'primary-type' => 'Album',
            'primary-type-id' => 'f529b476-6e62-324f-b0aa-1f3e33d313fc',
            'secondary-types' => [ 'Remix' ],
            'secondary-type-ids' => [ '0c60f497-ff81-3818-befd-abfc84a4858b' ],
            releases => [
                {
                    id => '3b3d130a-87a8-4a47-b9fb-920f2530d134',
                    title => 'Repercussions',
                    status => 'Official',
                    'status-id' => '4e304316-386d-3409-af2e-78857eec5cfe',
                    quality => 'normal',
                    'text-representation' => { language => 'eng', script => 'Latn' },
                    date => '2008-11-17',
                    country => 'GB',
                    'release-events' => [{
                        date => '2008-11-17',
                        'area' => {
                            disambiguation => '',
                            'id' => '8a754a16-0027-3a29-b6d7-2b40ea0481ed',
                            'name' => 'United Kingdom',
                            'sort-name' => 'United Kingdom',
                            'iso-3166-1-codes' => ['GB'],
                            'type' => JSON::null,
                            'type-id' => JSON::null,
                        },
                    }],
                    barcode => '600116822123',
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                    disambiguation => '',
                }],
            disambiguation => '',
        };
};

test 'release group lookup with artists' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release group lookup with artists',
    '/release-group/56683a0b-45b8-3664-a231-5b68efe2e7e2?inc=artists' =>
        {
            id => '56683a0b-45b8-3664-a231-5b68efe2e7e2',
            title => 'Repercussions',
            'first-release-date' => '2008-11-17',
            'primary-type' => 'Album',
            'primary-type-id' => 'f529b476-6e62-324f-b0aa-1f3e33d313fc',
            'secondary-types' => [ 'Remix' ],
            'secondary-type-ids' => [ '0c60f497-ff81-3818-befd-abfc84a4858b' ],
            'artist-credit' => [
                {
                    name => 'Distance',
                    artist => {
                        id => '472bc127-8861-45e8-bc9e-31e8dd32de7a',
                        name => 'Distance',
                        'sort-name' => 'Distance',
                        disambiguation => 'UK dubstep artist Greg Sanders',
                        'type' => 'Person',
                        'type-id' => 'b6e035f4-3ce9-331c-97df-83397230b0df',
                    },
                    joinphrase => '',
                }],
            disambiguation => '',
        };
};

test 'release group lookup with inc=artists+releases+tags+ratings' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release group lookup with inc=artists+releases+tags+ratings',
    '/release-group/153f0a09-fead-3370-9b17-379ebd09446b?inc=artists+releases+tags+ratings' =>
        {
            id => '153f0a09-fead-3370-9b17-379ebd09446b',
            title => 'the Love Bug',
            'first-release-date' => '2004-03-17',
            'primary-type' => 'Single',
            'primary-type-id' => 'd6038452-8ee0-3f68-affc-2de9a1ede0b9',
            'secondary-types' => [],
            'secondary-type-ids' => [],
            'artist-credit' => [
                {
                    name => 'm-flo',
                    artist => {
                        id => '22dd2db3-88ea-4428-a7a8-5cd3acf23175',
                        name => 'm-flo',
                        'sort-name' => 'm-flo',
                        disambiguation => '',
                        tags => [],
                        'type' => 'Group',
                        'type-id' => 'e431f5f6-b5d2-343d-8b36-72607fffb74b',
                    },
                    joinphrase => '',
                }],
            releases => [
                {
                    id => 'aff4a693-5970-4e2e-bd46-e2ee49c22de7',
                    title => 'the Love Bug',
                    status => 'Official',
                    'status-id' => '4e304316-386d-3409-af2e-78857eec5cfe',
                    quality => 'normal',
                    'text-representation' => { language => 'eng', script => 'Latn' },
                    date => '2004-03-17',
                    country => 'JP',
                    'release-events' => [{
                        date => '2004-03-17',
                        'area' => {
                            disambiguation => '',
                            'id' => '2db42837-c832-3c27-b4a3-08198f75693c',
                            'name' => 'Japan',
                            'sort-name' => 'Japan',
                            'iso-3166-1-codes' => ['JP'],
                            'type' => JSON::null,
                            'type-id' => JSON::null,
                        },
                    }],
                    barcode => '4988064451180',
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                    disambiguation => '',
                    tags => [],
                }],
            disambiguation => '',
            rating => { 'votes-count' => 2, value => 5 },
            tags => [],
        };
};

test 'release group lookup with pseudo-releases' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'release group lookup with pseudo-releases',
    '/release-group/153f0a09-fead-3370-9b17-379ebd09446b?inc=artists+releases&status=pseudo-release' =>
        {
            id => '153f0a09-fead-3370-9b17-379ebd09446b',
            title => 'the Love Bug',
            'first-release-date' => '2004-03-17',
            'primary-type' => 'Single',
            'primary-type-id' => 'd6038452-8ee0-3f68-affc-2de9a1ede0b9',
            'secondary-types' => [],
            'secondary-type-ids' => [],
            'artist-credit' => [
                {
                    name => 'm-flo',
                    artist => {
                        id => '22dd2db3-88ea-4428-a7a8-5cd3acf23175',
                        name => 'm-flo',
                        'sort-name' => 'm-flo',
                        disambiguation => '',
                        'type' => 'Group',
                        'type-id' => 'e431f5f6-b5d2-343d-8b36-72607fffb74b',
                    },
                    joinphrase => '',
                }],
            releases => [],
            disambiguation => '',
        };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
