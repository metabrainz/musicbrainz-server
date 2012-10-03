package t::MusicBrainz::Server::Controller::User::LostUsername;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

$mech->get_ok('/lost-username');
html_ok($mech->content);
$mech->submit_form( with_fields => { 'lostusername.email' => 'test@email.com' } );
$mech->content_contains("We've sent you information about your MusicBrainz account.");

my $email_transport = MusicBrainz::Server::Email->get_test_transport;
my $email = $email_transport->shift_deliveries->{email};
is($email->get_header('Subject'), 'Lost username');
like($email->get_body, qr{Your MusicBrainz username is: new_editor});

};

1;
