package t::MusicBrainz::Server::Controller::User::LostPassword;
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

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('/lost-password');
    html_ok($mech->content);
    $mech->submit_form( with_fields => {
        'lostpassword.username' => 'new_editor',
        'lostpassword.email' => 'test@email.com',
    } );
    $mech->content_contains('We&#x27;ve sent you instructions on how to reset your password.');
};

1;
