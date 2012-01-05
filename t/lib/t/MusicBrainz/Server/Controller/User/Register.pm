package t::MusicBrainz::Server::Controller::User::Register;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

$mech->get_ok('/register.js', 'Fetch registration page javascript');
my $iamhuman = $mech->content;
$iamhuman =~ s/^.*([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}).*$/$1/s;
$mech->get_ok('/register', 'Fetch registration page');
$mech->form_number (2);
$mech->set_fields (
    'register.username' => 'brand_new_editor',
    'register.password' => 'magic_password',
    'register.confirm_password' => 'magic_password',
    'data' => $iamhuman,
);
$mech->submit;

like($mech->uri, qr{/user/brand_new_editor}, 'should redirect to profile page after registering');

$mech->get_ok('/register.js', 'Fetch registration page javascript');
$iamhuman = $mech->content;
$iamhuman =~ s/^.*([0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}).*$/$1/s;
$mech->get_ok('/register', 'Fetch registration page');
$mech->form_number (2);
$mech->set_fields (
    'register.username' => 'email_editor',
    'register.password' => 'magic_password',
    'register.confirm_password' => 'magic_password',
    'register.email' => 'foo@bar.com',
    'data' => $iamhuman,
);
$mech->submit;

like($mech->uri, qr{/user/email_editor}, 'should redirect to profile page after registering');

my $email_transport = MusicBrainz::Server::Email->get_test_transport;
my $email = $email_transport->deliveries->[-1]->{email};
is($email->get_header('Subject'), 'Please verify your email address');
like($email->get_body, qr{/verify-email}, 'has a link to verify email address');

my ($verify_link) = $email->get_body =~ qr{http://localhost(/verify-email.*)};
$mech->get_ok($verify_link, 'verify account');
$mech->content_like(qr/Thank you, your email address has now been verified/);

};

1;
