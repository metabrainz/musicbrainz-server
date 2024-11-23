package t::MusicBrainz::Server::Controller::WS::2::SubmitRecording;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

use utf8;
use HTTP::Request;
use HTTP::Status qw( :constants );

use MusicBrainz::Server::Test qw( xml_ok xml_post );
use MusicBrainz::Server::Test ws_test => {
    version => 2,
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;
$mech->default_header('Accept' => 'application/xml');

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
    INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
        VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478', 'foo@example.com', now());
    INSERT INTO recording_gid_redirect (gid, new_id)
        VALUES ('78ad6e24-dc0a-4c20-8284-db2d44d28fb9', 4223060);
    SQL

# Check OPTIONS support
my $req = HTTP::Request->new('OPTIONS', '/ws/2/recording?client=test-1.0');

$mech->request($req);
is($mech->status, HTTP_OK);

my $response1_headers = $mech->response->headers;
is($response1_headers->header('access-control-allow-origin'), '*');
is($response1_headers->header('allow'), 'GET, POST, OPTIONS');

# Check CORS preflight support
$req = HTTP::Request->new('OPTIONS', '/ws/2/recording?client=test-1.0', [
    'Access-Control-Request-Headers' => 'Authorization, Content-Type',
    'Access-Control-Request-Method' => 'POST',
    'Origin' => 'https://example.com',
]);

$mech->request($req);
is($mech->status, HTTP_OK);

my $response2_headers = $mech->response->headers;
is($response2_headers->header('access-control-allow-headers'), 'Authorization, Content-Type, User-Agent');
is($response2_headers->header('access-control-allow-methods'), 'GET, POST, OPTIONS');
is($response2_headers->header('access-control-allow-origin'), '*');
is($response2_headers->header('allow'), 'GET, POST, OPTIONS');

my $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <recording-list>
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
      <isrc-list>
        <isrc id="GBAAA0300123"></isrc>
      </isrc-list>
    </recording>
  </recording-list>
  <edit-note>This is a testy test!

This is the second paragraph of this &quot;test&quot; &amp; it is great!</edit-note>
</metadata>';

$req = xml_post('/ws/2/recording?client=test-1.0', $content);

$mech->request($req);
is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

$mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

$mech->request($req);
is($mech->status, HTTP_OK);
xml_ok($mech->content);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
my $rec = $c->model('Recording')->get_by_gid('162630d9-36d2-4a8d-ade1-1c77440b34e7');
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddISRCs');
is_deeply($edit->data->{isrcs}, [
    { isrc => 'GBAAA0300123',
      recording => {
          id => $rec->id,
          name => $rec->name,
      },
  },
]);
my $en_data = MusicBrainz::Server::Data::EditNote->new(c => $c);
$en_data->load_for_edits($edit);
is(@{ $edit->edit_notes }, 1, 'Edit has an edit note');
check_note($edit->edit_notes->[0],'MusicBrainz::Server::Entity::EditNote',
       editor_id => 1,
       edit_id => $edit->id,
       text => 'This is a testy test!

This is the second paragraph of this "test" & it is great!');

};

sub check_note {
    my ($note, $class, %attrs) = @_;
    isa_ok($note, $class);
    is($note->$_, $attrs{$_}, "check_note: $_ is ".$attrs{$_})
        for keys %attrs;
    ok(defined $note->post_time, 'check_note: edit has post time');
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
