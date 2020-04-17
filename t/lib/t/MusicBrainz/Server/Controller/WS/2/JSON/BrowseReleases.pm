package t::MusicBrainz::Server::Controller::WS::2::JSON::BrowseReleases;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'errors' => sub {

    use Test::JSON import => [ 'is_json' ];

    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+webservice');

    my $mech = $test->mech;
    $mech->default_header("Accept" => "application/json");
    $mech->get('/ws/2/release?recording=7b1f6e95-b523-43b6-a048-810ea5d463a8');
    is($mech->status, 404, 'browse releases via non-existent recording');

    is_json($mech->content, encode_json({
          error => "Not Found",
          help => 'For usage, please see: https://musicbrainz.org/development/mmd',
    }));
};

test 'browse releases via artist (paging)' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse releases via artist (paging)',
    '/release?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&offset=2' =>
        {
            "release-count" => 3,
            "release-offset" => 2,
            releases => [
                {
                    id => "fbe4eb72-0f24-3875-942e-f581589713d4",
                    title => "For Beginner Piano",
                    status => "Official",
                    'status-id' => "4e304316-386d-3409-af2e-78857eec5cfe",
                    quality => "normal",
                    "text-representation" => { language => "eng", script => "Latn" },
                    "cover-art-archive" => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => "1999-09-23",
                    country => "US",
                    "release-events" => [{
                        date => "1999-09-23",
                        "area" => {
                            disambiguation => "",
                            "id" => "489ce91b-6658-3307-9877-795b68554c98",
                            "name" => "United States",
                            "sort-name" => "United States",
                            "iso-3166-1-codes" => ["US"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    asin => "B00001IVAI",
                    barcode => JSON::null,
                    disambiguation => "",
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                }]
        };
};

test 'browse releases via label' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse releases via label',
    '/release?inc=mediums&label=b4edce40-090f-4956-b82a-5d9d285da40b' =>
        {
            "release-count" => 2,
            "release-offset" => 0,
            releases => [
                {
                    id => "3b3d130a-87a8-4a47-b9fb-920f2530d134",
                    title => "Repercussions",
                    status => "Official",
                    'status-id' => "4e304316-386d-3409-af2e-78857eec5cfe",
                    quality => "normal",
                    "text-representation" => { language => "eng", script => "Latn" },
                    "cover-art-archive" => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => "2008-11-17",
                    country => "GB",
                    "release-events" => [{
                        date => "2008-11-17",
                        "area" => {
                            disambiguation => "",
                            "id" => "8a754a16-0027-3a29-b6d7-2b40ea0481ed",
                            "name" => "United Kingdom",
                            "sort-name" => "United Kingdom",
                            "iso-3166-1-codes" => ["GB"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    barcode => "600116822123",
                    media => [
                        {
                            format => "CD",
                            'format-id' => '9712d52a-4509-3d4b-a1a2-67c88c643e31',
                            position => 1,
                            "track-count" => 9,
                            title => '',
                        },
                        {
                            format => "CD",
                            'format-id' => '9712d52a-4509-3d4b-a1a2-67c88c643e31',
                            position => 2,
                            "track-count" => 9,
                            title => "Chestplate Singles"
                        }],
                    asin => "B001IKWNCE",
                    disambiguation => "",
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                },
                {
                    id => "adcf7b48-086e-48ee-b420-1001f88d672f",
                    title => "My Demons",
                    status => "Official",
                    'status-id' => "4e304316-386d-3409-af2e-78857eec5cfe",
                    quality => "normal",
                    "text-representation" => { language => "eng", script => "Latn" },
                    "cover-art-archive" => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => "2007-01-29",
                    country => "GB",
                    "release-events" => [{
                        date => "2007-01-29",
                        "area" => {
                            disambiguation => "",
                            "id" => "8a754a16-0027-3a29-b6d7-2b40ea0481ed",
                            "name" => "United Kingdom",
                            "sort-name" => "United Kingdom",
                            "iso-3166-1-codes" => ["GB"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    barcode => "600116817020",
                    media => [
                        {
                            format => "CD",
                            'format-id' => '9712d52a-4509-3d4b-a1a2-67c88c643e31',
                            position => 1,
                            "track-count" => 12,
                            title => '',
                        } ],
                    asin => "B000KJTG6K",
                    disambiguation => "",
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                }]
        };
};

test  'browse releases via release group' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse releases via release group',
    '/release?release-group=b84625af-6229-305f-9f1b-59c0185df016' =>
        {
            "release-count" => 2,
            "release-offset" => 0,
            releases => [
                {
                    id => "0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e",
                    title => "サマーれげぇ!レインボー",
                    status => "Official",
                    'status-id' => "4e304316-386d-3409-af2e-78857eec5cfe",
                    quality => "normal",
                    "text-representation" => { language => "jpn", script => "Jpan" },
                    "cover-art-archive" => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => "2001-07-04",
                    country => "JP",
                    "release-events" => [{
                        date => "2001-07-04",
                        "area" => {
                            disambiguation => "",
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso-3166-1-codes" => ["JP"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    barcode => "4942463511227",
                    asin => "B00005LA6G",
                    disambiguation => "",
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                },
                {
                    id => "b3b7e934-445b-4c68-a097-730c6a6d47e6",
                    title => "Summer Reggae! Rainbow",
                    status => "Pseudo-Release",
                    'status-id' => "41121bb9-3413-3818-8a9a-9742318349aa",
                    quality => "normal",
                    "text-representation" => { language => "jpn", script => "Latn" },
                    "cover-art-archive" => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => "2001-07-04",
                    country => "JP",
                    "release-events" => [{
                        date => "2001-07-04",
                        "area" => {
                            disambiguation => "",
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso-3166-1-codes" => ["JP"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    barcode => "4942463511227",
                    asin => "B00005LA6G",
                    disambiguation => "",
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                }]
        };
};

test 'browse releases via recording' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse releases via recording',
    '/release?inc=labels&status=official&recording=0c0245df-34f0-416b-8c3f-f20f66e116d0' =>
        {
            "release-count" => 2,
            "release-offset" => 0,
            releases => [
                {
                    id => "28fc2337-985b-3da9-ac40-ad6f28ff0d8e",
                    title => "LOVE & HONESTY",
                    status => "Official",
                    'status-id' => "4e304316-386d-3409-af2e-78857eec5cfe",
                    quality => "normal",
                    "text-representation" => { language => "jpn", script => "Jpan" },
                    "cover-art-archive" => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => "2004-01-15",
                    country => "JP",
                    "release-events" => [{
                        date => "2004-01-15",
                        "area" => {
                            disambiguation => "",
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso-3166-1-codes" => ["JP"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    barcode => "4988064173891",
                    asin => "B0000YGBSG",
                    "label-info" => [
                        {
                            "catalog-number" => "AVCD-17389",
                            label => {
                                id => "168f48c8-057e-4974-9600-aa9956d21e1a",
                                name => "avex trax",
                                "sort-name" => "avex trax",
                                "label-code" => JSON::null,
                                disambiguation => "",
                                "type" => "Original Production",
                                "type-id" => "7aaa37fe-2def-3476-b359-80245850062d",
                            }
                        }],
                    disambiguation => "",
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                },
                {
                    id => "cacc586f-c2f2-49db-8534-6f44b55196f2",
                    title => "LOVE & HONESTY",
                    status => "Official",
                    'status-id' => "4e304316-386d-3409-af2e-78857eec5cfe",
                    quality => "normal",
                    "text-representation" => { language => "jpn", script => "Jpan" },
                    "cover-art-archive" => {
                        artwork => JSON::false,
                        count => 0,
                        front => JSON::false,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => "2004-01-15",
                    country => "JP",
                    "release-events" => [{
                        date => "2004-01-15",
                        "area" => {
                            disambiguation => "",
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso-3166-1-codes" => ["JP"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    barcode => "4988064173907",
                    asin => "B0000YG9NS",
                    "label-info" => [
                        {
                            "catalog-number" => "AVCD-17390",
                            label => {
                                id => "168f48c8-057e-4974-9600-aa9956d21e1a",
                                name => "avex trax",
                                "sort-name" => "avex trax",
                                "label-code" => JSON::null,
                                disambiguation => "",
                                "type" => "Original Production",
                                "type-id" => "7aaa37fe-2def-3476-b359-80245850062d",
                            }
                        }],
                    disambiguation => "",
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                }]
        };
};

test 'browse releases via track artist' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'browse releases via track artist',
    '/release?track_artist=a16d1433-ba89-4f72-a47b-a370add0bb55' =>
        {
            "release-count" => 1,
            "release-offset" => 0,
            releases => [
                {
                    id => "aff4a693-5970-4e2e-bd46-e2ee49c22de7",
                    title => "the Love Bug",
                    status => "Official",
                    'status-id' => "4e304316-386d-3409-af2e-78857eec5cfe",
                    quality => "normal",
                    "text-representation" => { language => "eng", script => "Latn" },
                    "cover-art-archive" => {
                        artwork => JSON::true,
                        count => 1,
                        front => JSON::true,
                        back => JSON::false,
                        darkened => JSON::false,
                    },
                    date => "2004-03-17",
                    country => "JP",
                    "release-events" => [{
                        date => "2004-03-17",
                        "area" => {
                            disambiguation => "",
                            "id" => "2db42837-c832-3c27-b4a3-08198f75693c",
                            "name" => "Japan",
                            "sort-name" => "Japan",
                            "iso-3166-1-codes" => ["JP"],
                            "type" => JSON::null,
                            "type-id" => JSON::null,
                        },
                    }],
                    barcode => "4988064451180",
                    asin => "B0001FAD2O",
                    disambiguation => "",
                    packaging => JSON::null,
                    'packaging-id' => JSON::null,
                }]
        };
};

1;

