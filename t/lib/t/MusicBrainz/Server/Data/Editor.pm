package t::MusicBrainz::Server::Data::Editor;
use strict;
use warnings;
use utf8;

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
    $EDITING_DISABLED_FLAG
    $UNTRUSTED_FLAG
    :vote
);
use MusicBrainz::Server::Context;
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

    is(
        $ratings->{artist}->[0]->{id},
        1,
        'The results include the rated artist entity',
    );
    is(
        $ratings->{artist}->[0]->{rating},
        80,
        'The inserted raw rating is present',
    );
    is(
        $ratings->{artist}->[0]->{rating_count},
        1,
        'The amount of ratings for the entity is correct',
    );
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
       q(Remember me tokens with improper capitalization can't be consumed));

    ok(!exception { $model->consume_remember_me_token('Unknown User', $token) },
       'It is not an exception to attempt to consume tokens for non-existent users');

    is($model->allocate_remember_me_token('Unknown User'), undef,
       'Allocating tokens for unknown users returns undefined');
};

test 'Creating a new editor' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');
    my $editor_data = MusicBrainz::Server::Data::Editor->new(c => $test->c);

    note('We create a new editor with just name / password');
    my $new_editor_2 = $editor_data->insert({
        name => 'new_editor_2',
        password => 'password',
    });
    is(
        $new_editor_2->name,
        'new_editor_2',
        'The new editor has the expected name',
    );
    ok(
        $new_editor_2->match_password('password'),
        'The new editor has the expected password',
    );
    is(
        $editor_data->various_edit_counts($new_editor_2->id)->{accepted_count},
        0,
        'The new editor has no accepted edits',
    );

    my $editor = $editor_data->get_by_id($new_editor_2->id);
    is($editor->email, undef, 'The new editor has no stored email');
    is(
        $editor->email_confirmation_date,
        undef,
        'The new editor has no email confirmation date',
    );
    is(
        $editor->ha1,
        md5_hex(join(':', $editor->name, 'musicbrainz.org', 'password')),
        'The ha1 for the new editor was generated correctly',
    );

    my $now = DateTime::Format::Pg->parse_datetime(
        $test->c->sql->select_single_value('SELECT now()'));
    note('We set an email for the new editor with update_email');
    $editor_data->update_email($new_editor_2, 'editor@example.com');

    $editor = $editor_data->get_by_id($new_editor_2->id);
    is(
        $editor->email,
        'editor@example.com',
        'The new editor has the correct e-mail address',
    );
    ok(
        $now <= $editor->email_confirmation_date,
        'The email confirmation date was updated correctly',
    );

    note('We set a new password for the new editor with update_password');
    $editor_data->update_password($new_editor_2->name, 'password2');

    $editor = $editor_data->get_by_id($new_editor_2->id);
    ok(
        $editor->match_password('password2'),
        'The new editor has the expected new password',
    );
};

test 'find_by_email and is_email_used_elsewhere' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');
    my $editor_data = MusicBrainz::Server::Data::Editor->new(c => $test->c);

    note('We create a new editor with just name / password');
    my $new_editor_2 = $editor_data->insert({
        name => 'new_editor_2',
        password => 'password',
    });
    # For testing is_email_used_elsewhere
    my $future_editor_id = $new_editor_2->id + 1;

    note('We set an email for the new editor with update_email');
    $editor_data->update_email($new_editor_2, 'editor@example.com');

    note('We search for the new editor email with find_by_email');
    my @editors = $editor_data->find_by_email('editor@example.com');
    is(scalar(@editors), 1, 'An editor was found with the exact email');
    is($editors[0]->id, $new_editor_2->id, 'The right editor was found');

    @editors = $editor_data->find_by_email('EDITOR@EXAMPLE.COM');
    is(scalar(@editors), 1, 'An editor was found searching with all caps');
    is($editors[0]->id, $new_editor_2->id, 'The right editor was found');

    note('We check is_email_used_elsewhere shows the email as being in use');
    ok(
        $editor_data->is_email_used_elsewhere(
            'editor@example.com',
            $future_editor_id,
        ),
        'The exact email is shown to be in use if another editor wants it',
    );
    ok(
        $editor_data->is_email_used_elsewhere(
            'EDITOR@EXAMPLE.COM',
            $future_editor_id,
        ),
        'The email is shown to be in use even if searching with all caps',
    );

    note('We set an all caps email for the new editor with update_email');
    $editor_data->update_email($new_editor_2, 'EDITOR@EXAMPLE.COM');

    note('We search for the new editor email with find_by_email');
    my @editors = $editor_data->find_by_email('EDITOR@EXAMPLE.COM');
    is(scalar(@editors), 1, 'An editor was found with the exact email');
    is($editors[0]->id, $new_editor_2->id, 'The right editor was found');

    @editors = $editor_data->find_by_email('editor@example.com');
    is(scalar(@editors), 1, 'An editor was found searching with normal caps');
    is($editors[0]->id, $new_editor_2->id, 'The right editor was found');

    note('We check is_email_used_elsewhere shows the email as being in use');
    ok(
        $editor_data->is_email_used_elsewhere(
            'EDITOR@EXAMPLE.COM',
            $future_editor_id,
        ),
        'The exact email is shown to be in use if another editor wants it',
    );
    ok(
        $editor_data->is_email_used_elsewhere(
            'editor@example.com',
            $future_editor_id,
        ),
        'The email is shown to be in use even if searching with normal caps',
    );
};

test 'Getting/loading existing editors' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

    my $editor_data = MusicBrainz::Server::Data::Editor->new(c => $test->c);

    note('We get the editor with id 1 using get_by_id');
    my $editor = $editor_data->get_by_id(1);
    ok(defined $editor, 'An editor was returned');
    isa_ok($editor, 'MusicBrainz::Server::Entity::Editor');
    is($editor->id, 1, 'The editor has the expected id');
    is($editor->name, 'new_editor', 'The editor has the expected name');
    ok(
        $editor->match_password('password'),
        'The editor has the expected password',
    );
    is(
        $editor->privileges,
        1+8+32+512,
        'The editor has the expected privileges',
    );

    is_deeply(
        $editor->last_login_date,
        DateTime->new(year => 2013, month => 4, day => 5),
        'The editor has the expected last login date',
    );

    is_deeply(
        $editor->email_confirmation_date,
        DateTime->new(year => 2005, month => 10, day => 20),
        'The editor has the expected email confirmation date',
    );

    is_deeply(
        $editor->registration_date,
        DateTime->new(year => 1989, month => 7, day => 23),
        'The editor has the expected registration date',
    );

    my $editor2 = $editor_data->get_by_name('new_editor');
    is_deeply(
        $editor,
        $editor2,
        'Fetching the editor by name with get_by_name returns the same data',
    );

    $editor2 = $editor_data->get_by_name('nEw_EdItOr');
    is_deeply(
        $editor,
        $editor2,
        'Fetching the editor by name with get_by_name is case-insensitive',
    );

    note('We load editor "alice" and their preferences');
    my $alice = $editor_data->get_by_name('alice');
    $editor_data->load_preferences($alice);
    is(
        $alice->preferences->public_ratings,
        0,
        'The preference to make ratings private is loaded',
    );
    is(
        $alice->preferences->datetime_format,
        '%m/%d/%Y %H:%M:%S',
        'The datetime_format preference is loaded');
    is(
        $alice->preferences->timezone,
        'UTC',
        'The preferred timezone is loaded',
    );
};

test 'various_edit_counts' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');
    my $editor_data = MusicBrainz::Server::Data::Editor->new(c => $test->c);

    my $editor = $editor_data->get_by_id(1);
    note('We load various_edit_counts for editor 1 (should be empty)');
    my $edit_counts = $editor_data->various_edit_counts(1);
    is($edit_counts->{accepted_count}, 0, 'There are no accepted edits');
    is($edit_counts->{rejected_count}, 0, 'There are no rejected edits');
    is($edit_counts->{failed_count}, 0, 'There are no failed edits');
    is($edit_counts->{accepted_auto_count}, 0, 'There are no auto edits');

    note('We insert a bunch of edits for editor 1');
    $test->c->sql->do(<<~"SQL", $editor->id);
        INSERT INTO edit (id, editor, type, status, expire_time, autoedit)
            VALUES (1, \$1, 1, $STATUS_APPLIED, now(), 0),
                (2, \$1, 1, $STATUS_APPLIED, now(), 1),
                (3, \$1, 1, $STATUS_FAILEDVOTE, now(), 0),
                (4, \$1, 1, $STATUS_FAILEDDEP, now(), 0);
        INSERT INTO edit_data (edit, data)
            SELECT x, '{}' FROM generate_series(1, 4) x;
        SQL

    $editor = $editor_data->get_by_id(1);
    note('We load various_edit_counts for editor 1 again');
    $edit_counts = $editor_data->various_edit_counts($editor->id);
    is($edit_counts->{accepted_count}, 1, 'There is 1 accepted edit');
    is($edit_counts->{rejected_count}, 1, 'There is 1 rejected edit');
    is($edit_counts->{failed_count}, 1, 'There is 1 failed edit');
    is($edit_counts->{accepted_auto_count}, 1, 'There is 1 auto edit');
};

test 'Editor subscription methods' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

    my $editor_data = MusicBrainz::Server::Data::Editor->new(c => $test->c);

    subtest 'find_by_subscribed_editor' => sub {
        my @editors = $editor_data->find_by_subscribed_editor(2, 10, 0);
        is($editors[1], 1, 'alice is subscribed to one person ...');
        is($editors[0][0]->id, 1, '          ... that person is new_editor');

        @editors = $editor_data->find_by_subscribed_editor(1, 10, 0);
        is($editors[1], 0, 'new_editor has not subscribed to anyone');
    };

    subtest 'find_subscribers' => sub {
        my @editors = $editor_data->find_subscribers(1, 10, 0);
        is($editors[1], 1, 'new_editor has one subscriber ...');
        is($editors[0][0]->id, 2, '          ... that subscriber is alice');


        @editors = $editor_data->find_subscribers(2, 10, 0);
        is($editors[1], 0, 'alice has no subscribers');
    };

    subtest 'editors_with_subscriptions' => sub {
        my @editors = $editor_data->editors_with_subscriptions(0, 1000);
        is(@editors => 1, 'Found 1 editor searching with no offset');
        is($editors[0]->id => 2, 'The editor is editor #2');

        @editors = $editor_data->editors_with_subscriptions(1, 1000);
        is(@editors => 1, 'Found 1 editor searching with offset 1');
        is($editors[0]->id => 2, 'The editor is editor #2');

        @editors = $editor_data->editors_with_subscriptions(2, 1000);
        is(@editors => 0, 'Found no editors searching with offset 2');

        note('We mark editor #2 as a spammer (+ block edit & notes privs)');
        $test->c->sql->do(<<~'SQL');
            UPDATE editor
            SET privs = 7168
            WHERE id = 2
            SQL

        @editors = $editor_data->editors_with_subscriptions(0, 1000);
        is(@editors => 0, 'Found no editors since spammer is not returned');
    };
};

test 'Deleting editors without data fully deletes them' => sub {
    my $test = shift;
    my $c = $test->c;
    my $model = $c->model('Editor');

    $c->sql->do(<<~'SQL');
        INSERT INTO area (id, gid, name, type)
            VALUES (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1);
        INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB');
        INSERT INTO editor (
            id, name, password, email,
            website, bio, member_since, email_confirm_date,
            last_login_date, privs, birth_date, area, gender, ha1)
            VALUES (
                1, 'Bob', '{CLEARTEXT}bob', 'bob@bob.bob',
                'http://bob.bob/', 'Bobography', now(), now(),
                now(), 1, now(), 221, 1, '026299da47965340ef66ca485a57975d');
        INSERT INTO editor_language (editor, language, fluency)
            VALUES (1, 120, 'native');
        SQL
    $model->delete(1);
    is($model->get_by_id(1), undef, 'Editor without references in DB is deleted fully.');
};

test 'Deleting editors removes most information' => sub {
    my $test = shift;
    my $c = $test->c;
    my $model = $c->model('Editor');

    $c->sql->do(<<~"SQL");
        INSERT INTO area (id, gid, name, type)
            VALUES (221, '8a754a16-0027-3a29-b6d7-2b40ea0481ed', 'United Kingdom', 1);
        INSERT INTO iso_3166_1 (area, code) VALUES (221, 'GB');
        INSERT INTO editor (id, name, password, email, website, bio, member_since, email_confirm_date, last_login_date, privs, birth_date, area, gender, ha1)
            VALUES (1, 'Bob', '{CLEARTEXT}bob', 'bob\@bob.bob', 'http://bob.bob/', 'Bobography', now(), now(), now(), 1, now(), 221, 1, '026299da47965340ef66ca485a57975d');
        INSERT INTO edit (id, editor, type, status, expire_time)
            VALUES (1, 1, 1, $STATUS_APPLIED, now()),
                   (3, 1, 1, $STATUS_FAILEDVOTE, now()),
                   (4, 1, 1, $STATUS_FAILEDDEP, now());
        INSERT INTO edit_data (edit, data) VALUES (1, '{}'), (3, '{}'), (4, '{}');
        INSERT INTO editor_language (editor, language, fluency) VALUES (1, 120, 'native');
        INSERT INTO annotation (editor) VALUES (1); -- added to ensure editor won't be deleted
        INSERT INTO tag (id, name, ref_count) VALUES (1, 'foo', 1);
        INSERT INTO area_tag (area, count, tag) VALUES (221, 1, 1);
        INSERT INTO area_tag_raw (area, editor, tag, is_upvote) VALUES (221, 1, 1, TRUE);
        SQL

    # Test deleting editors
    $model->delete(1);
    my $bob = $model->get_by_id(1);

    is(
        $bob->name,
        'Deleted Editor #' . $bob->id,
        'The editor name is now "Deleted Editor" plus an ID',
    );
    is(
        $bob->password,
        Authen::Passphrase::RejectAll->new->as_rfc2307,
        'The password has been deleted',
    );
    is($bob->privileges, 0, 'The editor privileges have been blanked');
    my $edit_counts = $model->various_edit_counts($bob->id);
    is(
        $edit_counts->{accepted_count},
        1,
        'The editor’s accepted edit count is unchanged',
    );
    is(
        $edit_counts->{rejected_count},
        1,
        'The editor’s rejected edit count is unchanged',
    );
    is(
        $edit_counts->{accepted_auto_count},
        0,
        'The editor’s auto-accepted edit count is unchanged',
    );
    is(
        $edit_counts->{failed_count},
        1,
        'The editor’s failed edit count is unchanged',
    );
    is($bob->deleted, 1, 'The editor is marked as deleted');

    # The name should be prevented from being reused by default (MBS-9271).
    ok(
        $c->sql->select_single_value(
            'SELECT 1 FROM old_editor_name WHERE name = ?', 'Bob',
        ),
        'The editor name is listed in old_editor_name as not reusable',
    );

    # Ensure all other attributes are cleared
    my $exclusions = Set::Scalar->new(
        qw( id name password privileges last_login_date languages
            registration_date preferences ha1 deleted has_ten_accepted_edits
      ));

    for my $attribute (grep { !$exclusions->contains($_->name) }
                           object_attributes($bob)) {
        attribute_value_is($attribute, $bob, undef,
                           $attribute->name . ' has been blanked');
    }

    # Ensure all languages have been cleared
    $c->model('EditorLanguage')->load_for_editor($bob);
    is(@{ $bob->languages }, 0, 'The editor languages have been blanked');

    # Ensure all preferences are cleared
    my $prefs = $bob->preferences;
    for my $attribute (object_attributes($prefs)) {
        if (!$attribute->has_default) {
            diag('Editor preference ' . attribute->name . ' has no default');
        }
        else {
            attribute_value_is(
                $attribute, $prefs, $attribute->default($prefs),
                'Preference ' . $attribute->name . ' has been blanked');
        }
    }

    # Ensure all tags are cleared
    my $tags = $c->sql->select_single_column_array(
        'SELECT tag FROM area_tag_raw WHERE editor = ?', 1,
    );
    is(@$tags, 0, 'All tags by the editor have been blanked');
};

test 'Deleting an editor cancels all open edits' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

    note('We enter an autoedit for the editor');
    my $applied_edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'An additional comment',
        ipi_codes => [],
        isni_codes => [],
    );

    is(
        $applied_edit->status,
        $STATUS_APPLIED,
        'The edit is marked as applied',
    );

    note('We enter a normal edit for the editor');
    my $open_edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'A Comment',
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    is($open_edit->status, $STATUS_OPEN, 'The edit is marked as open');

    note('We delete the editor');
    $c->model('Editor')->delete(1);

    is(
        $c->model('Edit')->get_by_id($applied_edit->id)->status,
        $STATUS_APPLIED,
        'The autoedit is still marked as applied',
    );
    is(
        $c->model('Edit')->get_by_id($open_edit->id)->status,
        $STATUS_DELETED,
        'The open edit is now marked as cancelled',
    );
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
        [{
            vote    => $VOTE_NO,
            edit_id => $edit->id,
        }],
    );

    $c->model('Vote')->load_for_edits($edit);
    is(scalar @{ $edit->votes }, 1, 'There is one vote');
    is($edit->votes->[0]->vote, $VOTE_NO, 'Vote is No');
    is($edit->votes->[0]->editor_id, 2, 'Vote is by editor 2');

    note('We delete editor 2');
    $c->model('Editor')->delete(2);

    # Clear the votes to load again
    $edit->votes([]);

    $c->model('Vote')->load_for_edits($edit);
    is(scalar @{ $edit->votes }, 2, 'There is two votes');
    is($edit->votes->[1]->vote, $VOTE_ABSTAIN, 'New vote is Abstain');
    is($edit->votes->[1]->editor_id, 2, 'New vote is by editor 2');
};

test 'Deleting an editor changes all Yes/No votes on open edits to Abstain, even if they have no vote privileges (MBS-12026)' => sub {
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
        [{
            vote    => $VOTE_NO,
            edit_id => $edit->id,
        }],
    );

    $c->model('Vote')->load_for_edits($edit);
    is(scalar @{ $edit->votes }, 1, 'There is one vote');
    is($edit->votes->[0]->vote, $VOTE_NO, 'Vote is No');
    is($edit->votes->[0]->editor_id, 2, 'Vote is by editor 2');

    note('We revoke the editing/voting privileges for editor 2');
    $test->c->sql->do(
        "UPDATE editor SET privs = $EDITING_DISABLED_FLAG WHERE id = 2",
    );

    note('We delete editor 2');
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

    $c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, ha1)
            VALUES (1, 'Subject', '{CLEARTEXT}', '46182940755cef2bdcc0a03b6c1a3580'),
                   (2, 'Subscriber', '{CLEARTEXT}', '37d4b8c8bd88e53c69068830c9e34efc');
        INSERT INTO editor_subscribe_editor (editor, subscribed_editor, last_edit_sent)
            VALUES (2, 1, 1);
        SQL

    $c->model('Editor')->delete(1);
    is(
        scalar($c->model('Editor')->subscription->get_subscriptions(2)),
        0,
        'The editor has no subscribers anymore',
    );
};

test 'Open edit and last-24-hour counts' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

    note('We enter an autoedit for the editor');
    $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'An additional comment',
        ipi_codes => [],
        isni_codes => [],
    );

    note('We enter a normal for the editor');
    $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'A Comment',
        ipi_codes => [],
        isni_codes => [],
        privileges => $UNTRUSTED_FLAG,
    );

    is(
        $c->model('Editor')->various_edit_counts(1)->{open_count},
        1,
        'The editor’s open edit count is 1',
    );
    is(
        $c->model('Editor')->last_24h_edit_count(1),
        2,
        'The editor’s last 24h edit count is 2',
    );
};

test 'subscription_summary' => sub {
    my $test = shift;
    $test->c->sql->do(<<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, 'dd448d65-d7c5-4eef-8e13-12e1bfdacdc6', 'artist', 'artist');
        INSERT INTO label (id, gid, name)
            VALUES (1, 'dd448d65-d7c5-4eef-8e13-12e1bfdacdc6', 'label');

        INSERT INTO series (id, gid, name, comment, type, ordering_type)
            VALUES (1, 'a8749d0c-4a5a-4403-97c5-f6cd018f8e6d', 'Test Recording Series', 'test comment 1', 3, 1);

        INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
            VALUES (1, 'Alice', '{CLEARTEXT}al1c3', 'd61b477a6269ddd11dbd70644335a943', '', now()),
                   (2, 'Bob', '{CLEARTEXT}b0b', '47ac7eb9fe940581057e46994840a4ae', '', now());

        INSERT INTO edit (id, editor, type, status, expire_time) VALUES (1, 1, 1, 1, now());
        INSERT INTO edit_data (edit, data) VALUES (1, '{}');

        INSERT INTO editor_collection (id, gid, editor, name, type)
            VALUES (1, 'dd448d65-d7c5-4eef-8e13-12e1bfdacdc6', 1, 'Stuff', 1);

        INSERT INTO editor_subscribe_artist (id, editor, artist, last_edit_sent)
            VALUES (1, 1, 1, 1);
        INSERT INTO editor_subscribe_collection (id, editor, collection, last_edit_sent)
            VALUES (1, 1, 1, 0);
        INSERT INTO editor_subscribe_label (id, editor, label, last_edit_sent)
            VALUES (1, 1, 1, 1), (2, 2, 1, 1);
        INSERT INTO editor_subscribe_editor (id, editor, subscribed_editor, last_edit_sent)
            VALUES (1, 1, 1, 1);

        INSERT INTO editor_subscribe_series (id, editor, series, last_edit_sent) VALUES (1, 1, 1, 1);
        SQL

    is_deeply(
        $test->c->model('Editor')->subscription_summary(1),
        {
            artist => 1,
            collection => 1,
            label => 1,
            editor => 1,
            series => 1,
        },
        'The subscription summary for editor 1 has the expected counts',
    );

    is_deeply(
        $test->c->model('Editor')->subscription_summary(2),
        {
            artist => 0,
            collection => 0,
            label => 1,
            editor => 0,
            series => 0,
        },
        'The subscription summary for editor 2 has the expected counts',
    );
};


test 'Searching editor by email (for admin only)' => sub {
    my $test = shift;

    $test->c->sql->do(<<~'SQL');
        INSERT INTO editor (id, name, password, ha1, email, member_since)
            VALUES (1, 'z', '{CLEARTEXT}password', '12345678901234567890123456789012', 'abc@f.g.h', '2021-05-31 16:31:36.901272+00'),
                   (2, 'y', '{CLEARTEXT}password', '12345678901234567890123456789012', 'a.b.c+d.e@f.g.h', '2021-05-31 15:32:05.674592+00'),
                   (3, 'x', '{CLEARTEXT}password', '12345678901234567890123456789012', 'a.b.c+d.e@f-g.h', '2021-05-31 14:32:15.079918+00'),
                   -- Reminder: Editor #4 is ModBot
                   (5, 'w', '{CLEARTEXT}password', '12345678901234567890123456789012', 'a.b.c+d@e.f.g.h', '2021-05-31 13:32:28.205096+00');
        SQL

    my $editor_data = MusicBrainz::Server::Data::Editor->new(c => $test->c);

    diag('Bounded search with trimmed user info and escaped host name (recommended)');
    my ($editors, $hits) = $editor_data->search_by_email('^abc@f\.g\.h$');
    is($hits => 2, 'Found 2 editors');
    is(@$editors[0]->id => 1, 'First is editor #1');
    is(@$editors[1]->id => 2, 'Second is editor #2');

    diag('Bounded search with trimmed user info and escaped host name (ALL CAPS)');
    ($editors, $hits) = $editor_data->search_by_email('^ABC@F\.G\.H$');
    is($hits => 2, 'Found 2 editors');
    is(@$editors[0]->id => 1, 'First is editor #1');
    is(@$editors[1]->id => 2, 'Second is editor #2');

    diag('Search with trimmed user info suffix and escaped host name prefix');
    ($editors, $hits) = $editor_data->search_by_email('bc@f\.g');
    is($hits => 2, 'Found 2 editors');
    is(@$editors[0]->id => 1, 'First is editor #1');
    is(@$editors[1]->id => 2, 'Second is editor #2');

    diag('Search with trimmed user info and unescaped host name');
    ($editors, $hits) = $editor_data->search_by_email('abc@f.g.h');
    is($hits => 3, 'Found 3 editors');
    is(@$editors[0]->id => 1, 'First is editor #1');
    is(@$editors[1]->id => 2, 'Second is editor #2');
    # Special character '.' matches '-'
    is(@$editors[2]->id => 3, 'Third is editor #3');

    diag('Search with trimmed user info only');
    ($editors, $hits) = $editor_data->search_by_email('abc@');
    is($hits => 4, 'Found 4 editors');
    is(@$editors[0]->id => 1, 'First is editor #1');
    is(@$editors[1]->id => 2, 'Second is editor #2');
    is(@$editors[2]->id => 3, 'Third is editor #3');
    is(@$editors[3]->id => 5, 'Fourth is editor #5');

    diag('Search with untrimmed unescaped user info only');
    ($editors, $hits) = $editor_data->search_by_email('a.b.c+d.e@');
    is($hits => 0, 'Found 0 editors');

    diag('Search with untrimmed escaped user info only');
    ($editors, $hits) = $editor_data->search_by_email('a\.b\.c\+d\.e@');
    is($hits => 0, 'Found 0 editors');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
