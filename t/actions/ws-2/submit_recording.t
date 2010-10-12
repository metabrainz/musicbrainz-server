use strict;
use warnings;
use Test::More;

use HTTP::Status qw( :constants );
use MusicBrainz::Server::Test qw( schema_validator xml_ok xml_post );
use MusicBrainz::WWW::Mechanize;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');

my $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <recording-list>
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
      <puid-list>
        <puid id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e"></puid>
      </puid-list>
    </recording>
  </recording-list>
</metadata>';

my $req = xml_post('/ws/2/recording?client=test-1.0', $content);

$mech->request($req);
is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

$mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

$mech->request($req);
is($mech->status, HTTP_OK);
xml_ok($mech->content);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddPUIDs');
is_deeply($edit->data->{puids}, [
    { puid => 'eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e',
      recording_id => $c->model('Recording')->get_by_gid('162630d9-36d2-4a8d-ade1-1c77440b34e7')->id }
]);

$content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <recording-list>
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
      <isrc-list>
        <isrc id="GBAAA0300123"></isrc>
      </isrc-list>
    </recording>
  </recording-list>
</metadata>';

$req = xml_post('/ws/2/recording?client=test-1.0', $content);
$mech->request($req);
is($mech->status, HTTP_OK);
xml_ok($mech->content);

$edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddISRCs');
is_deeply($edit->data->{isrcs}, [
    { isrc => 'GBAAA0300123',
      recording_id => $c->model('Recording')->get_by_gid('162630d9-36d2-4a8d-ade1-1c77440b34e7')->id }
]);

done_testing;
