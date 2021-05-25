package t::MusicBrainz::Server::Data::Editor;
use Test::Fatal;
use Test::Routine;
use Test::Moose;
use Test::More;

use Authen::Passphrase::RejectAll;
use DateTime;
use DateTime::Format::Pg;
use MusicBrainz::Server::Constants qw(
    :edit_status
    $EDIT_ARTIST_EDIT
    $UNTRUSTED_FLAG
    :vote
);
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test qw( accept_edit );
use Set::Scalar;
use Sql;
use Digest::MD5 qw( md5_hex );
use t::Util::Moose::Attribute qw( object_attributes attribute_value_is );

BEGIN { use MusicBrainz::Server::Data::Editor; }

with 't::Context';

test 'Test summarize_ratings' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');
    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '
TRUNCATE artist_rating_raw CASCADE;
INSERT INTO artist_rating_raw (artist, editor, rating) VALUES (1, 1, 80);
');

    my $editor = $test->c->model('Editor')->get_by_id(1);
    my $ratings = $test->c->model('Editor')->summarize_ratings($editor);

    is($ratings->{artist}->[0]->id => 1, 'has artist entity');
    is($ratings->{artist}->[0]->rating, 80, 'has raw rating');
    is($ratings->{artist}->[0]->rating_count => 1, 'has rating on entity');
};

test 'Remember me tokens' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

    my $model = $test->c->model('Editor');

    my $user_name = 'alice';
    my ($normalized_name, $token) = $model->allocate_remember_me_token($user_name);

    ok($token, 'Token is returned with improper username capitalization');

    is($normalized_name, 'Alice', 'Normalized name (with proper caps) is returned from allocating remember me token');

    ok($model->consume_remember_me_token($normalized_name, $token),
       'Can consume "remember me" tokens');

    ok(!$model->consume_remember_me_token($user_name, $token),
       'Remember me tokens with improper capitalization can\'t be consumed');

    ok(!exception { $model->consume_remember_me_token('Unknown User', $token) },
       'It is not an exception to attempt to consume tokens for non-existent users');

    is($model->allocate_remember_me_token('Unknown User'), undef,
       'Allocating tokens for unknown users returns undefined');
};

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

my $editor_data = MusicBrainz::Server::Data::Editor->new(c => $test->c);

my $editor = $editor_data->get_by_id(1);
ok(defined $editor, 'no editor returned');
isa_ok($editor, 'MusicBrainz::Server::Entity::Editor', 'not a editor');
is($editor->id, 1, 'id');
is($editor->name, 'new_editor', 'name');
ok($editor->match_password('password'));
is($editor->privileges, 1+8+32+512, 'privileges');
my $edit_counts = $editor_data->various_edit_counts($editor->id);
is($edit_counts->{accepted_count}, 0, 'accepted edits');
is($edit_counts->{rejected_count}, 0, 'rejected edits');
is($edit_counts->{failed_count}, 0, 'failed edits');
is($edit_counts->{accepted_auto_count}, 0, 'auto edits');

is_deeply($editor->last_login_date, DateTime->new(year => 2013, month => 04, day => 05),
    'last login date');

is_deeply($editor->email_confirmation_date, DateTime->new(year => 2005, month => 10, day => 20),
    'email confirm');

is_deeply($editor->registration_date, DateTime->new(year => 1989, month => 07, day => 23),
    'registration date');


my $editor2 = $editor_data->get_by_name('new_editor');
is_deeply($editor, $editor2);


$editor2 = $editor_data->get_by_name('nEw_EdItOr');
is_deeply($editor, $editor2, 'fetching by name is case insensitive');

$test->c->sql->do(<<EOSQL, $editor->id);
    INSERT INTO edit (id, editor, type, status, expire_time, autoedit) VALUES
        (1, \$1, 1, $STATUS_APPLIED, now(), 0),
        (2, \$1, 1, $STATUS_APPLIED, now(), 1),
        (3, \$1, 1, $STATUS_FAILEDVOTE, now(), 0),
        (4, \$1, 1, $STATUS_FAILEDDEP, now(), 0);
    INSERT INTO edit_data (edit, data)
        SELECT x, '{}' FROM generate_series(1, 4) x;
EOSQL

$editor = $editor_data->get_by_id($editor->id);
$edit_counts = $editor_data->various_edit_counts($editor->id);
is($edit_counts->{accepted_count}, 1, 'accepted edits');
is($edit_counts->{rejected_count}, 1, 'rejected edits');
is($edit_counts->{failed_count}, 1, 'failed edits');
is($edit_counts->{accepted_auto_count}, 1, 'auto edits');

my $alice = $editor_data->get_by_name('alice');
# Test preferences
$editor_data->load_preferences($alice);
is($alice->preferences->public_ratings, 0, 'load preferences');
is($alice->preferences->datetime_format, '%m/%d/%Y %H:%M:%S', 'datetime_format loaded');
is($alice->preferences->timezone, 'UTC', 'timezone loaded');


my $new_editor_2 = $editor_data->insert({
    name => 'new_editor_2',
    password => 'password',
});
ok($new_editor_2->id > $editor->id);
is($new_editor_2->name, 'new_editor_2', 'new editor 2 has name new_editor_2');
ok($new_editor_2->match_password('password'), 'new editor 2 has correct password');
is($editor_data->various_edit_counts($new_editor_2->id)->{accepted_count}, 0, 'new editor 2 has no accepted edits');


$editor = $editor_data->get_by_id($new_editor_2->id);
is($editor->email, undef);
is($editor->email_confirmation_date, undef);
is($editor->ha1, md5_hex(join(':', $editor->name, 'musicbrainz.org', 'password')), 'ha1 was generated correctly');

my $now = DateTime::Format::Pg->parse_datetime(
    $test->c->sql->select_single_value('SELECT now()'));
$editor_data->update_email($new_editor_2, 'editor@example.com');

$editor = $editor_data->get_by_id($new_editor_2->id);
is($editor->email, 'editor@example.com', 'editor has correct e-mail address');
ok($now <= $editor->email_confirmation_date, 'email confirmation date updated correctly');
is($new_editor_2->email_confirmation_date, $editor->email_confirmation_date);

$editor_data->update_password($new_editor_2->name, 'password2');

$editor = $editor_data->get_by_id($new_editor_2->id);
ok($editor->match_password('password2'));

my @editors = $editor_data->find_by_email('editor@example.com');
is(scalar(@editors), 1);
is($editors[0]->id, $new_editor_2->id);


@editors = $editor_data->find_by_subscribed_editor(2, 10, 0);
is($editors[1], 1, "alice is subscribed to one person ...");
is($editors[0][0]->id, 1, "          ... that person is new_editor");


@editors = $editor_data->find_subscribers(1, 10, 0);
is($editors[1], 1, "new_editor has one subscriber ...");
is($editors[0][0]->id, 2, "          ... that subscriber is alice");


@editors = $editor_data->find_by_subscribed_editor(1, 10, 0);
is($editors[1], 0, "new_editor has not subscribed to anyone");

@editors = $editor_data->find_subscribers(2, 10, 0);
is($editors[1], 0, "alice has no subscribers");

subtest 'Find editors with subscriptions' => sub {
    my @editors = $editor_data->editors_with_subscriptions(0, 1000);
    is(@editors => 1, 'found 1 editor');
    is($editors[0]->id => 2, 'is editor #2');

    @editors = $editor_data->editors_with_subscriptions(1, 1000);
    is(@editors => 1, 'found 1 editor');
    is($editors[0]->id => 2, 'is editor #2');

    @editors = $editor_data->editors_with_subscriptions(2, 1000);
    is(@editors => 0, 'found no editor');
};

};

test 'Deleting editors without data fully deletes them' => sub {
    my $test = shift;
    my $c = $test->c;
    my $model = $c->model('Editor');

    $c->sql->do(<<'EOSQL');
INSERT INTO area (id, gid, name, type) VALUES
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1);
INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB');
INSERT INTO editor (id, name, password, email, website, bio, member_since, email_confirm_date, last_login_date, privs, birth_date, area, gender, ha1) VALUES (1, 'Bob', '{CLEARTEXT}bob', 'bob@bob.bob', 'http://bob.bob/', 'Bobography', now(), now(), now(), 1, now(), 221, 1, '026299da47965340ef66ca485a57975d');
INSERT INTO editor_language (editor, language, fluency) VALUES (1, 120, 'native');
EOSQL
    $model->delete(1);
    is($model->get_by_id(1), undef, 'Editor without references in DB is deleted fully.');
};

test 'Deleting editors removes most information' => sub {
    my $test = shift;
    my $c = $test->c;
    my $model = $c->model('Editor');

    $c->sql->do(<<EOSQL);
INSERT INTO area (id, gid, name, type) VALUES
  (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1);
INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB');
INSERT INTO editor (id, name, password, email, website, bio, member_since, email_confirm_date, last_login_date, privs, birth_date, area, gender, ha1) VALUES (1, 'Bob', '{CLEARTEXT}bob', 'bob\@bob.bob', 'http://bob.bob/', 'Bobography', now(), now(), now(), 1, now(), 221, 1, '026299da47965340ef66ca485a57975d');
INSERT INTO edit (id, editor, type, status, expire_time) VALUES
    (1, 1, 1, $STATUS_APPLIED, now()),
    (3, 1, 1, $STATUS_FAILEDVOTE, now()),
    (4, 1, 1, $STATUS_FAILEDDEP, now());
INSERT INTO edit_data (edit, data) VALUES (1, '{}'), (3, '{}'), (4, '{}');
INSERT INTO editor_language (editor, language, fluency) VALUES (1, 120, 'native');
INSERT INTO annotation (editor) VALUES (1); -- added to ensure editor won't be deleted
INSERT INTO tag (id, name, ref_count) VALUES (1, 'foo', 1);
INSERT INTO area_tag (area, count, tag) VALUES (221, 1, 1);
INSERT INTO area_tag_raw (area, editor, tag, is_upvote) VALUES (221, 1, 1, TRUE);
EOSQL

    # Test deleting editors
    $model->delete(1);
    my $bob = $model->get_by_id(1);

    is($bob->name, 'Deleted Editor #' . $bob->id);
    is($bob->password, Authen::Passphrase::RejectAll->new->as_rfc2307);
    is($bob->privileges, 0);
    my $edit_counts = $model->various_edit_counts($bob->id);
    is($edit_counts->{accepted_count}, 1);
    is($edit_counts->{rejected_count}, 1);
    is($edit_counts->{accepted_auto_count}, 0);
    is($edit_counts->{failed_count}, 1);
    is($bob->deleted, 1);

    # The name should be prevented from being reused by default (MBS-9271).
    ok($c->sql->select_single_value(
        'SELECT 1 FROM old_editor_name WHERE name = ?', 'Bob'
    ));

    # Ensure all other attributes are cleared
    my $exclusions = Set::Scalar->new(
        qw( id name password privileges last_login_date languages
            registration_date preferences ha1 deleted has_ten_accepted_edits
      ));

    for my $attribute (grep { !$exclusions->contains($_->name) }
                           object_attributes($bob)) {
        attribute_value_is($attribute, $bob, undef,
                           $attribute->name . " is now undef");
    }

    # Ensure all languages have been cleared
    $c->model('EditorLanguage')->load_for_editor($bob);
    is(@{ $bob->languages }, 0);

    # Ensure all preferences are cleared
    my $prefs = $bob->preferences;
    for my $attribute (object_attributes($prefs)) {
        if (!$attribute->has_default) {
            diag("Editor preference " . attribute->name . " has no default");
        }
        else {
            attribute_value_is(
                $attribute, $prefs, $attribute->default($prefs),
                "Preference " . $attribute->name . " was cleared");
        }
    }

    # Ensure all tags are cleared
    my $tags = $c->sql->select_single_column_array(
        'SELECT tag FROM area_tag_raw WHERE editor = ?', 1
    );
    is(@$tags, 0);
};

test 'Deleting an editor cancels all open edits' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

    my $applied_edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'An additional comment',
        ipi_codes => [],
        isni_codes => [],
    );

    is($applied_edit->status, $STATUS_APPLIED);

    my $open_edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'A Comment',
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    is($open_edit->status, $STATUS_OPEN);

    $c->model('Editor')->delete(1);

    is($c->model('Edit')->get_by_id($applied_edit->id)->status, $STATUS_APPLIED);
    is($c->model('Edit')->get_by_id($open_edit->id)->status, $STATUS_DELETED);
};

test 'Deleting an editor changes all Yes/No votes on open edits to Abstain' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+vote');

    my $editor = $c->model('Editor')->get_by_id(2);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'A Comment',
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    $c->model('Vote')->enter_votes(
        $editor,
        {
            vote    => $VOTE_NO,
            edit_id => $edit->id,
        }
    );

    $c->model('Vote')->load_for_edits($edit);
    is(scalar @{ $edit->votes }, 1, 'There is one vote');
    is($edit->votes->[0]->vote, $VOTE_NO, 'Vote is No');
    is($edit->votes->[0]->editor_id, 2, 'Vote is by editor 2');


    $c->model('Editor')->delete(2);
    
    # Clear the votes to load again
    $edit->votes([]);

    $c->model('Vote')->load_for_edits($edit);
    is(scalar @{ $edit->votes }, 2, 'There is two votes');
    is($edit->votes->[1]->vote, $VOTE_ABSTAIN, 'New vote is Abstain');
    is($edit->votes->[1]->editor_id, 2, 'New vote is by editor 2');
};

test 'Deleting an editor unsubscribes anyone who was subscribed to them' => sub {
    my $test = shift;
    my $c = $test->c;

    $c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'Subject', '{CLEARTEXT}', '46182940755cef2bdcc0a03b6c1a3580'), (2, 'Subscriber', '{CLEARTEXT}', '37d4b8c8bd88e53c69068830c9e34efc');
INSERT INTO editor_subscribe_editor (editor, subscribed_editor, last_edit_sent)
  VALUES (2, 1, 1);
EOSQL

    $c->model('Editor')->delete(1);
    is(scalar($c->model('Editor')->subscription->get_subscriptions(2)), 0);
};

test 'Open edit and last-24-hour counts' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

    my $applied_edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'An additional comment',
        ipi_codes => [],
        isni_codes => []
    );

    my $open_edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'A Comment',
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    is($open_edit->status, $STATUS_OPEN);

    is($c->model('Editor')->various_edit_counts(1)->{open_count}, 1, "Open edit count is 1");
    is($c->model('Editor')->last_24h_edit_count(1), 2, "Last 24h count is 2");
};

test 'subscription_summary' => sub {
    my $test = shift;
    $test->c->sql->do(<<EOSQL);
INSERT INTO artist (id, gid, name, sort_name)
  VALUES (1, 'dd448d65-d7c5-4eef-8e13-12e1bfdacdc6', 'artist', 'artist');
INSERT INTO label (id, gid, name)
  VALUES (1, 'dd448d65-d7c5-4eef-8e13-12e1bfdacdc6', 'label');

INSERT INTO series (id, gid, name, comment, type, ordering_attribute, ordering_type)
    VALUES (1, 'a8749d0c-4a5a-4403-97c5-f6cd018f8e6d', 'Test Recording Series', 'test comment 1', 3, 788, 1);

INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES
(1, 'Alice', '{CLEARTEXT}al1c3', 'd61b477a6269ddd11dbd70644335a943', '', now()),
(2, 'Bob', '{CLEARTEXT}b0b', '47ac7eb9fe940581057e46994840a4ae', '', now());

INSERT INTO edit (id, editor, type, status, expire_time) VALUES (1, 1, 1, 1, now());
INSERT INTO edit_data (edit, data) VALUES (1, '{}');

INSERT INTO editor_collection (id, gid, editor, name, type)
  VALUES (1, 'dd448d65-d7c5-4eef-8e13-12e1bfdacdc6', 1, 'Stuff', 1);

INSERT INTO editor_subscribe_artist (id, editor, artist, last_edit_sent) VALUES
  (1, 1, 1, 1);
INSERT INTO editor_subscribe_collection (id, editor, collection, last_edit_sent)
  VALUES (1, 1, 1, 0);
INSERT INTO editor_subscribe_label (id, editor, label, last_edit_sent) VALUES
  (1, 1, 1, 1), (2, 2, 1, 1);
INSERT INTO editor_subscribe_editor
  (id, editor, subscribed_editor, last_edit_sent) VALUES (1, 1, 1, 1);

INSERT INTO editor_subscribe_series (id, editor, series, last_edit_sent) VALUES (1, 1, 1, 1);
EOSQL

    is_deeply($test->c->model('Editor')->subscription_summary(1),
              { artist => 1,
                collection => 1,
                label => 1,
                editor => 1,
                series => 1 });

    is_deeply($test->c->model('Editor')->subscription_summary(2),
              { artist => 0,
                collection => 0,
                label => 1,
                editor => 0,
                series => 0 });
};


test 'Searching editor by email (for admin only)' => sub {
    my $test = shift;

    $test->c->sql->do(<<'EOSQL');
INSERT INTO editor (id, name, password, ha1, email) VALUES
  (1, 'z', '{CLEARTEXT}password', '12345678901234567890123456789012', 'abc@f.g.h'),
  (2, 'y', '{CLEARTEXT}password', '12345678901234567890123456789012', 'a.b.c+d.e@f.g.h'),
  (3, 'x', '{CLEARTEXT}password', '12345678901234567890123456789012', 'a.b.c+d.e@f-g.h'),
  -- Reminder: Editor #4 is ModBot
  (5, 'w', '{CLEARTEXT}password', '12345678901234567890123456789012', 'a.b.c+d@e.f.g.h');
EOSQL

    my $editor_data = MusicBrainz::Server::Data::Editor->new(c => $test->c);

    my @editors;

    # Bounded search with trimmed user info and escaped host name (recommended)
    @editors = $editor_data->search_by_email('^abc@f\.g\.h$');
    is(@editors => 2, 'found 2 editors');
    is($editors[0]->id => 1, 'is editor #1');
    is($editors[1]->id => 2, 'is editor #2');

    # Search with trimmed user info suffix and escaped host name prefix
    @editors = $editor_data->search_by_email('bc@f\.g');
    is(@editors => 2, 'found 2 editors');
    is($editors[0]->id => 1, 'is editor #1');
    is($editors[1]->id => 2, 'is editor #2');

    # Search with trimmed user info and unescaped host name
    @editors = $editor_data->search_by_email('abc@f.g.h');
    is(@editors => 3, 'found 3 editors');
    is($editors[0]->id => 1, 'is editor #1');
    is($editors[1]->id => 2, 'is editor #2');
    # Special character '.' matches '-'
    is($editors[2]->id => 3, 'is editor #3');

    # Search with trimmed user info only
    @editors = $editor_data->search_by_email('abc@');
    is(@editors => 4, 'found 4 editors');
    is($editors[0]->id => 1, 'is editor #1');
    is($editors[1]->id => 2, 'is editor #2');
    is($editors[2]->id => 3, 'is editor #3');
    is($editors[3]->id => 5, 'is editor #5');

    # Search with untrimmed unescaped user info only
    @editors = $editor_data->search_by_email('a.b.c+d.e@');
    is(@editors => 0, 'found 0 editor');

    # Search with untrimmed escaped user info only
    @editors = $editor_data->search_by_email('a\.b\.c\+d\.e@');
    is(@editors => 0, 'found 0 editor');
};

1;
