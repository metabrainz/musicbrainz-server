package t::MusicBrainz::Server::Controller::User::Reverify;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use DateTime;

with 't::Mechanize', 't::Context', 't::Email';

test all => sub {
   my $test = shift;
   my $mech = $test->mech;
   my $c    = $test->c;

   $test->skip_unless_mailpit_configured;

   MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

   ok($c->sql->do('UPDATE editor SET email = ?, email_confirm_date = ? WHERE name = ?', 'new_email@example.com', '2003-01-01T00:00:00+0:00', 'new_editor'),
      'successfully inserted 2003-01-01 as old verification date');
   ok(DateTime->now->year > 2003, 'current year is bigger than 2003');

   $mech->get('/login');
   $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

   $mech->content_contains('/account/resend-verification');

   $mech->follow_link_ok({ url_regex => qr%/account/resend-verification% }, 'User page contains a reverification link');

   my @emails = $test->get_emails;
   my $reverify_email = shift @emails;
   is($reverify_email->{headers}{To}, 'new_email@example.com', 'email sent to right place');
   is($reverify_email->{headers}{Subject}, 'Verify your email', 'email subject is correct');
   my $reverify_email_body = $reverify_email->{body};
   like($reverify_email_body, qr{http://localhost/verify-email.*}, 'email contains verify-email link');

   $reverify_email_body =~ qr{\[http://localhost(/verify-email.*?)\]}ms;
   my $reverify_email_path = ($1 =~ s/\R//gr);
   $mech->get_ok($reverify_email_path);
   $mech->content_contains('Thank you, your email address has now been verified!');

   $mech->get_ok('/user/new_editor');
   $mech->content_like(qr{\(verified at (.*)\)});

   my $editor = $c->model('Editor')->get_by_name('new_editor');
   ok($editor->email_confirmation_date->year > 2003, 'Reverification date is newer than original verification date');
};

1;
