package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupRecording;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic recording lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic recording lookup',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7' => encode_json (
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            length => 296026,
        });

};

# ws_test 'recording lookup with releases',
#     '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases' =>
#     '<?xml version="1.0" encoding="UTF-8"?>
# <metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
#     <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
#         <title>サマーれげぇ!レインボー</title><length>296026</length>
#         <release-list count="2">
#             <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
#                 <title>サマーれげぇ!レインボー</title><status>Official</status>
#                 <quality>normal</quality>
#                 <text-representation>
#                     <language>jpn</language><script>Jpan</script>
#                 </text-representation>
#                 <date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode>
#             </release>
#             <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
#                 <title>Summer Reggae! Rainbow</title><status>Pseudo-Release</status>
#                 <quality>normal</quality>
#                 <text-representation>
#                     <language>jpn</language><script>Latn</script>
#                 </text-representation>
#                 <date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode>
#             </release>
#         </release-list>
#     </recording>
# </metadata>';

# ws_test 'lookup recording with official singles',
#     '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases&status=official&type=single' =>
#     '<?xml version="1.0" encoding="UTF-8"?>
# <metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
#     <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
#         <title>サマーれげぇ!レインボー</title><length>296026</length>
#         <release-list count="1">
#             <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
#                 <title>サマーれげぇ!レインボー</title><status>Official</status>
#                 <quality>normal</quality>
#                 <text-representation>
#                     <language>jpn</language><script>Jpan</script>
#                 </text-representation>
#                 <date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode>
#             </release>
#         </release-list>
#     </recording>
# </metadata>';

# ws_test 'lookup recording with official singles (+media)',
#     '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases+media&status=official&type=single' =>
#     '<?xml version="1.0" encoding="UTF-8"?>
# <metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
#     <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
#         <title>サマーれげぇ!レインボー</title><length>296026</length>
#         <release-list count="1">
#             <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
#                 <title>サマーれげぇ!レインボー</title><status>Official</status><date>2001-07-04</date><country>JP</country>
#                 <quality>normal</quality>
#                 <medium-list count="1">
#                     <medium>
#                         <position>1</position><format>CD</format>
#                         <track-list count="3" offset="0">
#                             <track>
#                                 <position>1</position><number>1</number>
#                                 <title>サマーれげぇ!レインボー</title>
#                                 <length>296026</length>
#                             </track>
#                         </track-list>
#                     </medium>
#                 </medium-list>
#             </release>
#         </release-list>
#     </recording>
# </metadata>';

test 'recording lookup with artists' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with artists',
    '/recording/0cf3008f-e246-428f-abc1-35f87d584d60?inc=artists' => encode_json (
        {
            id => "0cf3008f-e246-428f-abc1-35f87d584d60",
            title => "the Love Bug",
            length => 242226,
            "artist-credit" => [
                {
                    name => "m-flo",
                    artist => {
                        id => "22dd2db3-88ea-4428-a7a8-5cd3acf23175",
                        name => "m-flo",
                        "sort-name" => "m-flo",
                    },
                    joinphrase => "♥",
                },
                {
                    name => "BoA",
                    artist => {
                        id => "a16d1433-ba89-4f72-a47b-a370add0bb55",
                        name => "BoA",
                        "sort-name" => "BoA",
                    },
                    joinphrase => "",
                }
                ],
        });
};

test 'recording lookup with puids and isrcs' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'recording lookup with puids and isrcs',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=puids+isrcs' => encode_json (
        {
            id => "162630d9-36d2-4a8d-ade1-1c77440b34e7",
            title => "サマーれげぇ!レインボー",
            length => 296026,
            puids => [ "cdec3fe2-0473-073c-3cbb-bfb0c01a87ff" ],
            isrcs => [ "JPA600102450" ],
        });
};

1;

