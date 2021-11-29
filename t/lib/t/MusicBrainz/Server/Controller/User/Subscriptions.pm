package t::MusicBrainz::Server::Controller::User::Subscriptions;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
    INSERT INTO editor (
                  id, name, password, privs,
                  email, website, bio,
                  member_since, email_confirm_date, last_login_date,
                  ha1
                )
         VALUES (
                  5, 'adminymcadmin', '{CLEARTEXT}password', 128,
                  'test@email.com', 'http://test.website', 'biography',
                  '1989-07-23', '2005-10-20', '2013-04-05',
                  'aa550c5b01407ef1f3f0d16daf9ec3c8'
                );

    INSERT INTO artist (
                  id, gid,
                  name, sort_name
                )
         VALUES (
                  7, 'b9d99e40-72d7-11de-8a39-0800200c9a66',
                  'Kate Bush', 'Kate Bush'
                );

    INSERT INTO edit (id, editor, type, status, expire_time)
         VALUES (1, 1, 1, 1, now());

    INSERT INTO edit_data (edit, data)
         VALUES (1, '{}');

    INSERT INTO editor_subscribe_artist (artist, editor, last_edit_sent)
         VALUES (7, 2, 1);
    SQL

$mech->get('/user/alice/subscriptions');
$mech->content_contains(
  'You need to be logged in to view this page',
  'viewing subscriptions requires login',
);

$mech->get('/login');
$mech->submit_form(
  with_fields => { username => 'new_editor', password => 'password' }
);

$mech->get('/user/alice/subscriptions');
$mech->content_contains(
  'Artist Subscriptions',
  'directs to artist subscriptions',
);
$mech->content_contains('Kate Bush', 'subscription to Kate Bush is listed');

$mech->get('/user/new_editor/subscriptions/editor');
$mech->content_contains('new_editor', 'subscription to new_editor is listed');

MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
    INSERT INTO editor_preference (editor, name, value)
         VALUES (2, 'public_subscriptions', '0')
    SQL

$mech->get('/user/alice/subscriptions');
is ($mech->status(), 403, q(alice's subs are now private));

$mech->get('/logout');
$mech->get('/login');
$mech->submit_form(
  with_fields => { username => 'alice', password => 'secret1' }
);

$mech->get('/user/alice/subscriptions');
is ($mech->status(), 200, 'alice can still view their own subs');
$mech->content_contains(
  'Artist Subscriptions',
  'directs to artist subscriptions',
);
$mech->content_contains('Kate Bush', 'subscription to Kate Bush is listed');

$mech->get('/logout');
$mech->get('/login');
$mech->submit_form(
  with_fields => { username => 'adminymcadmin', password => 'password' }
);

$mech->get('/user/alice/subscriptions');
is ($mech->status(), 200, q(account admins can view alice's subs));
$mech->content_contains(
  'Editor Subscriptions',
  'directs to editor subscriptions',
);
$mech->content_contains('new_editor', 'subscription to new_editor is listed');

$mech->get('/user/alice/subscriptions/artist');
is ($mech->status(), 403, q(alice's artist subs are private to admin));
};

1;
