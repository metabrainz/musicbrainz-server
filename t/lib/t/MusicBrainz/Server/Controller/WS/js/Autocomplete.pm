package t::MusicBrainz::Server::Controller::WS::js::Autocomplete;
use Test::Routine;

with 't::Mechanize', 't::Context';

use JSON;
use MusicBrainz::Server::Test ws_test => {
    version => 'js'
};

test all => sub {

    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c);

    ws_test 'artist autocomplete response',
        '/artist?q=David&direct=true' =>
            [ {
                "area" => undef,
                "begin_area_id" => undef,
                "begin_date" => undef,
                "comment" => '',
                "editsPending" => JSON::false,
                "end_area_id" => undef,
                "end_date" => undef,
                "ended" => JSON::false,
                "entityType" => "artist",
                "gender_id" => undef,
                "gid" => "5441c29d-3602-4898-b1a1-b77fa23b8e50",
                "id" => 5,
                "name" => "David Bowie",
                "primaryAlias" => undef,
                "sort_name" => "David Bowie",
                "typeID" => undef,
                "unaccented_name" => undef,
              }, { "current" => 1, "pages" => 1 } ];

    ws_test 'label autocomplete response',
        '/label?q=Warp&direct=true' =>
            [ {
                "area" => undef,
                "begin_date" => undef,
                "comment" => 'Sheffield based electronica label',
                "editsPending" => JSON::false,
                "end_date" => undef,
                "ended" => JSON::false,
                "entityType" => 'label',
                "gid" => '46f0f4cd-8aab-4b33-b698-f459faf64190',
                "id" => 2,
                "label_code" => 2070,
                "name" => 'Warp Records',
                "primaryAlias" => undef,
                "typeID" => 4,
                "unaccented_name" => undef,
              }, { "current" => 1, "pages" => 1 } ];

};

1;

