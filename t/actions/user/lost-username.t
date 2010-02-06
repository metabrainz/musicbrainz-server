use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

MusicBrainz::Server::Test->prepare_test_server;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/lost-username');
xml_ok($mech->content);
$mech->submit_form( with_fields => { 'lostusername.email' => 'test@email.com' } );
$mech->content_contains("We've sent you informations about your MusicBrainz account.");

my $email_transport = MusicBrainz::Server::Email->get_test_transport;
my $email = $email_transport->deliveries->[-1]->{email};
is($email->get_header('Subject'), 'Lost username');
like($email->get_body, qr{Your MusicBrainz username is: new_editor});

done_testing;
