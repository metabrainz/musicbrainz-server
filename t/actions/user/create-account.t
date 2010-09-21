use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

MusicBrainz::Server::Test->prepare_test_server;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/register', 'Fetch registration page');
$mech->submit_form( with_fields => {
    'register.username' => 'brand_new_editor',
    'register.password' => 'magic_password',
    'register.confirm_password' => 'magic_password',
    'register.confirm_password' => 'magic_password',
});

like($mech->uri, qr{/user/brand_new_editor}, 'should redirect to profile page after registering');

$mech->get_ok('/register', 'Fetch registration page');
$mech->submit_form( with_fields => {
    'register.username' => 'email_editor',
    'register.password' => 'magic_password',
    'register.confirm_password' => 'magic_password',
    'register.confirm_password' => 'magic_password',
    'register.email' => 'foo@bar.com',
});

like($mech->uri, qr{/user/email_editor}, 'should redirect to profile page after registering');

my $email_transport = MusicBrainz::Server::Email->get_test_transport;
my $email = $email_transport->deliveries->[-1]->{email};
is($email->get_header('Subject'), 'Please verify your email address');
like($email->get_body, qr{/verify-email}, 'has a link to verify email address');

my ($verify_link) = $email->get_body =~ qr{http://localhost(/verify-email.*)};
$mech->get_ok($verify_link, 'verify account');
$mech->content_like(qr/Thank you, your email address has now been verified/);

# remove the newly added users.
use Sql;
my $sql = Sql->new($c->dbh);
$sql->begin;
$sql->do ('DELETE FROM editor WHERE name=\'brand_new_editor\'');
$sql->do ('DELETE FROM editor WHERE name=\'email_editor\'');
$sql->commit;

done_testing;
