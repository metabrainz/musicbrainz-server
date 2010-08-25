use utf8;
use strict;
use Test::More;

use HTTP::Request::Common;
use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

use MusicBrainz::WWW::Mechanize;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');

subtest 'Submit a set of PUIDs' => sub {
    my $request = POST '/ws/1/track/?type=xml', [
        client => 'test-1.0',
        puid   => '162630d9-36d2-4a8d-ade1-1c77440b34e7 7b8a868f-1e67-852b-5141-ad1edfb1e492'
    ];

    $mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

    my $response = $mech->request($request);
    ok($mech->success);

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddPUIDs');
    is_deeply($edit->data->{puids}, [
        { puid => '7b8a868f-1e67-852b-5141-ad1edfb1e492',
          recording_id => $c->model('Recording')->get_by_gid('162630d9-36d2-4a8d-ade1-1c77440b34e7')->id }
    ]);

    done_testing;
};

subtest 'Submit a set of ISRCs' => sub {
    my $request = POST '/ws/1/track/?type=xml', [
        client => 'test-1.0',
        isrc   => '162630d9-36d2-4a8d-ade1-1c77440b34e7 GBAAA9400365'
    ];

    $mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

    my $response = $mech->request($request);
    ok($mech->success);

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddISRCs');
    is_deeply($edit->data->{isrcs}, [
        { isrc => 'GBAAA9400365',
          recording_id => $c->model('Recording')->get_by_gid('162630d9-36d2-4a8d-ade1-1c77440b34e7')->id }
    ]);

    done_testing;
};

done_testing;

