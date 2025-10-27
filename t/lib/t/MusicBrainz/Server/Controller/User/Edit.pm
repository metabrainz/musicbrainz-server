package t::MusicBrainz::Server::Controller::User::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Test qw( html_ok test_xpath_html );

use HTTP::Status qw( :constants );

with 't::Mechanize', 't::Context', 't::Email';

test all => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    $test->skip_unless_mailpit_configured;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

    $mech->get_ok('/account/edit');
    html_ok($mech->content);
    $mech->submit_form( with_fields => {
        'profile.website' => 'foo',
        'profile.biography' => 'hello world!',
    } );
    $mech->content_contains('Invalid URL format', q(Invalid URL format 'foo' triggers validation failure.));
    $mech->submit_form( with_fields => {
        'profile.birth_date.year' => 0,
        'profile.birth_date.month' => 1,
        'profile.birth_date.day' => 1,
    } );
    $mech->content_contains('invalid date', 'Invalid date 0-1-1 triggers validation failure.');
    $mech->submit_form( with_fields => {
        'profile.website' => 'http://example.com/~new_editor/',
        'profile.biography' => 'hello world!',
        'profile.email' => 'new_email@example.com',
        'profile.birth_date.year' => '',
        'profile.birth_date.month' => '',
        'profile.birth_date.day' => '',
    } );
    $mech->content_contains('Your profile has been updated');
    $mech->content_contains('We have sent you a verification email');

    my @emails = $test->get_emails;
    my $email = shift @emails;
    is($email->{headers}{To}, 'new_email@example.com', 'Verification email sent to correct address');
    is($email->{headers}{Subject}, 'Verify your email', 'Verification email has correct subject');

    my $email_body = $email->{body};
    like($email_body, qr{http://localhost/verify-email.*}, 'Verification email contains verification link');

    $email_body =~ qr{\[http://localhost(/verify-email.*?)\]}ms;
    my $verify_email_path = ($1 =~ s/\R//gr);
    $mech->get_ok($verify_email_path);
    $mech->content_contains('Thank you, your email address has now been verified!');

    $mech->get('/user/new_editor');
    $mech->content_contains('new_email@example.com');
};

test 'Hide biography and website/homepage of beginners/limited users from not-logged-in users and only from them' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

    $mech->get('/login');
    $mech->submit_form( with_fields => { username => 'Alice', password => 'secret1' } );

    $mech->get('/user/new_editor');
    html_ok($mech->content);
    my $tx = test_xpath_html($mech->content);
    $tx->ok('//tr[@class="biography"]/td[count(*)=1]/p/bdi[text()="biography"]',
        'biography field of beginner/limited user is visible from logged-in user');
    $tx->ok('//tr/td[preceding-sibling::th[1][normalize-space(text())="Homepage:"]]/a[@href="http://test.website"]',
        'website field of beginner/limited user is visible from logged-in user');

    $mech->get('/logout');
    html_ok($mech->content);

    $mech->get('/user/new_editor');
    html_ok($mech->content);
    $tx = test_xpath_html($mech->content);
    $tx->ok('//tr[@class="biography"]/td[count(*)=1]/div[@class="deleted" and starts-with(text(), "This content is hidden to prevent spam.")]',
        'biography field of beginner/limited user is hidden from not-logged-in user');
    $tx->ok('//tr/td[preceding-sibling::th[1][normalize-space(text())="Homepage:"]]/div[@class="deleted" and starts-with(text(), "This content is hidden to prevent spam.")]',
        'website field of beginner/limited user is hidden from not-logged-in user');

    note('We remove the beginner flag from the editor');
    $test->c->sql->do('UPDATE editor SET privs = 0 WHERE id = 1');

    $mech->get('/user/new_editor');
    html_ok($mech->content);
    $tx = test_xpath_html($mech->content);
    $tx->ok('//tr[@class="biography"]/td[count(*)=1]/p/bdi[text()="biography"]',
        'biography field of (not beginner/limited) user is visible from everyone');
    $tx->ok('//tr/td[preceding-sibling::th[1][normalize-space(text())="Homepage:"]]/a[@href="http://test.website"]',
        'website field of (not beginner/limited) user is visible from everyone');
};

test 'After removing email address, editors cannot edit' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $c    = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
    $c->sql->do(
        'UPDATE editor SET email = ?, email_confirm_date = now()
         WHERE name = ?',
        'foo@bar.baz', 'new_editor',
    );

    $mech->get('/login');
    $mech->submit_form( with_fields => {
        username => 'new_editor',
        password => 'password',
    });

    {
        my $response = $mech->get('/artist/create');
        is($response->code, HTTP_OK);
    }

    $mech->get_ok('/account/edit');
    html_ok($mech->content);
    $mech->submit_form( with_fields => {
        'profile.email' => '',
    });
    $mech->content_contains('Your profile has been updated');

    {
        my $response = $mech->get('/artist/create');
        is($response->code, HTTP_UNAUTHORIZED);
    }
};

1;
