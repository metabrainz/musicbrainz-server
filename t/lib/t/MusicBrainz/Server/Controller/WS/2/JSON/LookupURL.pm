package t::MusicBrainz::Server::Controller::WS::2::JSON::LookupURL;
use utf8;
use JSON;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test ws_test_json => {
    version => 2
};

with 't::Mechanize', 't::Context';

test 'basic url lookup' => sub {

    MusicBrainz::Server::Test->prepare_test_database(shift->c, '+webservice');

    ws_test_json 'basic url lookup',
    '/url/e0a79771-e9f0-4127-b58a-f5e6869c8e96' => encode_json (
      { id => "e0a79771-e9f0-4127-b58a-f5e6869c8e96",
        resource => "http://www.discogs.com/artist/Paul+Allgood"
      });

    ws_test_json 'basic url lookup (by URL)',
    '/url?resource=http://www.discogs.com/artist/Paul%2BAllgood' => encode_json (
      { id => "e0a79771-e9f0-4127-b58a-f5e6869c8e96",
        resource => "http://www.discogs.com/artist/Paul+Allgood"
      });

    ws_test_json 'basic url lookup (with inc=artist-rels)',
    '/url/e0a79771-e9f0-4127-b58a-f5e6869c8e96?inc=artist-rels' => encode_json (
        {
            id => "e0a79771-e9f0-4127-b58a-f5e6869c8e96",
            resource => "http://www.discogs.com/artist/Paul+Allgood",
            relations => [
                {
                    attributes => [],
                    direction => 'backward',
                    artist => {
                        id => "05d83760-08b5-42bb-a8d7-00d80b3bf47c",
                        name => 'Paul Allgood',
                        'sort-name' => 'Allgood, Paul',
                        disambiguation => ''
                    },
                    ended => JSON::false,
                    begin => JSON::null,
                    type => 'discogs',
                    'type-id' => '04a5b104-a4c2-4bac-99a1-7b837c37d9e4',
                    end => JSON::null
                }]
        });
};

1;
