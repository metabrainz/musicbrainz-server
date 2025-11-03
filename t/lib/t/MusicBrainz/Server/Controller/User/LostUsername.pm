package t::MusicBrainz::Server::Controller::User::LostUsername;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context', 't::Email';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    $test->skip_unless_mailpit_configured;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('/lost-username');
    html_ok($mech->content);
    $mech->submit_form( with_fields => { 'lostusername.email' => 'test@email.com' } );
    $mech->content_contains('We&#x27;ve sent you information about your MusicBrainz account.');

    my @emails = $test->get_emails;
    my $email = shift @emails;
    is($email->{headers}{Subject}, 'Lost username');
    like($email->{body}, qr{Your MusicBrainz username is: new_editor});
};

1;
