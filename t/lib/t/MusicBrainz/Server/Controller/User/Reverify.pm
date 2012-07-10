package t::MusicBrainz::Server::Controller::User::Reverify;
use Test::Routine;
use Test::More;
use Test::MockTime qw( :all );
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/account/edit');
html_ok($mech->content);
$mech->submit_form( with_fields => {
    'profile.website' => 'http://example.com/~new_editor/',
    'profile.biography' => 'hello world!',
    'profile.email' => 'new_email@example.com',
} );
$mech->content_contains('Your profile has been updated');
$mech->content_contains('We have sent you a verification email');

my $email_transport = MusicBrainz::Server::Email->get_test_transport;
my $email = $email_transport->deliveries->[-1]->{email};
is($email->get_header('To'), 'new_email@example.com', 'email sent to right place');
is($email->get_header('Subject'), 'Please verify your email address', 'email subject is correct');
like($email->get_body, qr{http://localhost/verify-email.*}, 'email contains verify-email link');

$email->get_body =~ qr{http://localhost(/verify-email.*)};
my $verify_email_path = $1;
$mech->get_ok($verify_email_path);
$mech->content_contains("Thank you, your email address has now been verified!");
my $orig_now = $c->sql->select_single_value('select now()');

$mech->get('/user/new_editor');
$mech->content_like(qr{\(verified at (.*)\)});
$mech->content =~ qr{\(verified at (.*)\)};
my $original_verification = $1;
like($original_verification, qr{\d+.\d+.\d+ \d+.\d+}, "Verification $original_verification looks like a date");
$mech->content_contains('/account/resend-verification');

set_relative_time(1); #ensure the timestamp will be different

$mech->follow_link_ok({ url_regex => qr%/account/resend-verification% }, "User page contains a reverification link");

my $reverify_email = $email_transport->deliveries->[-1]->{email};
is($reverify_email->get_header('To'), 'new_email@example.com', 'email sent to right place');
is($reverify_email->get_header('Subject'), 'Please verify your email address', 'email subject is correct');
like($reverify_email->get_body, qr{http://localhost/verify-email.*}, 'email contains verify-email link');

$reverify_email->get_body =~ qr{http://localhost(/verify-email.*)};
my $reverify_email_path = $1;
isnt($reverify_email_path, $verify_email_path, "Email verification paths differ");
$mech->get_ok($reverify_email_path);
$mech->content_contains("Thank you, your email address has now been verified!");

$mech->get_ok('/user/new_editor');
$mech->content_like(qr{\(verified at (.*)\)});
$mech->content =~ qr{\(verified at (.*)\)};
my $reverification = $1;
like($reverification, qr{\d+.\d+.\d+ \d+.\d+}, "Reverification $reverification looks like a date");

restore_time();

};

1;
