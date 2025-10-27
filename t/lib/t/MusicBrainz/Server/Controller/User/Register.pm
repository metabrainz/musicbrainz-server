package t::MusicBrainz::Server::Controller::User::Register;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context', 't::Email';

test 'Registering without verifying an email address' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('/register', 'Fetch registration page');
    $mech->header_is('referrer-policy', 'strict-origin-when-cross-origin');
    $mech->submit_form( with_fields => {
        'register.username' => 'brand_new_editor',
        'register.password' => 'ıaa2',
        'register.email' => 'test@example.com',
        'register.confirm_password' => 'ıaa2',
    });

    like($mech->uri, qr{/user/brand_new_editor}, 'should redirect to profile page after registering');
};

test 'Registering and verifying an email address' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    $test->skip_unless_mailpit_configured;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('/register', 'Fetch registration page');
    $mech->submit_form( with_fields => {
        'register.username' => 'email_editor',
        'register.password' => 'ıaa2',
        'register.confirm_password' => 'ıaa2',
        'register.email' => 'foo@bar.com',
    });

    like($mech->uri, qr{/user/email_editor}, 'should redirect to profile page after registering');

    my @emails = $test->get_emails;
    my $email = shift @emails;
    is($email->{headers}{Subject}, 'Verify your email');
    my $email_body = $email->{body};
    like($email_body, qr{/verify-email}, 'has a link to verify email address');

    $email_body =~ qr{\[http://localhost(/verify-email.*?)\]}ms;
    my $verify_link = ($1 =~ s/\R//gr);
    $mech->get_ok($verify_link, 'verify account');
    $mech->content_like(qr/Thank you, your email address has now been verified/);

    $mech->get('/user/email_editor');
    $mech->content_like(qr{\(verified at (.*)\)});
    $mech->content =~ qr{\(verified at (.*)\)};
    my $original_verification = $1;
    like($original_verification, qr{\d+.\d+.\d+ \d+.\d+}, "Verification $original_verification looks like a date");
};

test 'Trying to register with an invalid name' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('/register', 'fetch registration page');
    $mech->submit_form( with_fields => {
        'register.username' => 'Deleted Editor #675234',
        'register.password' => 'foo',
        'register.confirm_password' => 'foo',
        'register.email' => 'foobar@example.org',
    });

    like($mech->uri, qr{/register}, 'stays on registration page');
    $mech->content_contains('username is reserved', 'form has error message');

    $mech->submit_form( with_fields => {
        'register.username' => "very\rnew\nlines",
        'register.password' => 'foo',
        'register.confirm_password' => 'foo',
        'register.email' => 'foobar@example.org',
    });
    like($mech->uri, qr{/register}, 'stays on registration page');
    $mech->content_contains('username contains invalid characters', 'form has error message for newlines in username');

    $mech->submit_form( with_fields => {
        'register.username' => 'consecutive  spaces',
        'register.password' => 'foo',
        'register.confirm_password' => 'foo',
        'register.email' => 'foobar@example.org',
    });
    like($mech->uri, qr{/register}, 'stays on registration page');
    $mech->content_contains('username contains invalid characters', 'form has error message for consecutive spaces in username');

    $mech->submit_form( with_fields => {
        'register.username' => "test\N{HANGUL FILLER}\N{HALFWIDTH HANGUL FILLER}\N{BRAILLE PATTERN BLANK}\N{HANGUL CHOSEONG FILLER}\N{HANGUL JUNGSEONG FILLER}",
        'register.password' => 'foo',
        'register.confirm_password' => 'foo',
        'register.email' => 'foobar@example.org',
    });
    like($mech->uri, qr{/register}, 'stays on registration page');
    $mech->content_contains('username contains invalid characters', 'form has error message for invisible characters in username');

    $mech->submit_form( with_fields => {
        'register.username' => "test\N{TAG LATIN CAPITAL LETTER T}\N{TAG LATIN CAPITAL LETTER E}\N{TAG LATIN CAPITAL LETTER S}\N{TAG LATIN CAPITAL LETTER T}",
        'register.password' => 'foo',
        'register.confirm_password' => 'foo',
        'register.email' => 'foobar@example.org',
    });
    like($mech->uri, qr{/register}, 'stays on registration page');
    $mech->content_contains('username contains invalid characters', 'form has error message for tag characters in username');

    $mech->submit_form( with_fields => {
        'register.username' => 'looks://like_a_url_to_me',
        'register.password' => 'foo',
        'register.confirm_password' => 'foo',
        'register.email' => 'foobar@example.org',
    });
    like($mech->uri, qr{/register}, 'stays on registration page');
    $mech->content_contains('username contains invalid characters', 'form has error message for :// in username');
};

test 'Trying to register with an existing name' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('/register', 'fetch registration page');
    $mech->submit_form( with_fields => {
        'register.username' => 'aLiCe',
        'register.password' => 'bar',
        'register.confirm_password' => 'bar',
        'register.email' => 'barfoo@example.org',
    });

    like($mech->uri, qr{/register}, 'stays on registration page');
    $mech->content_contains('already taken', 'form has error message');

    # Try with a previously-used name (MBS-9271).
    $mech->submit_form( with_fields => {
        'register.username' => 'im_gone',
        'register.password' => 'foo',
        'register.confirm_password' => 'foo',
        'register.email' => 'foobar@example.org',
    });
    like($mech->uri, qr{/register}, 'stays on registration page');
    $mech->content_contains('already taken', 'form has error message');
};

test 'Opening a new registration form does not invalidate CSRF token on previous form' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get_ok('/register', 'fetch registration page');
    $mech->get_ok('/register', 'fetch registration page again');
    $mech->back; # go back to the first form

    $mech->submit_form(with_fields => {
        'register.username' => 'baby',
        'register.password' => 'goo goo ga ga',
        'register.email' => 'baby@example.com',
        'register.confirm_password' => 'goo goo ga ga',
    });

    like($mech->uri, qr{/user/baby}, 'original form is submitted');
};

1;
