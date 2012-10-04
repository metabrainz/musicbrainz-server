package t::MusicBrainz::Server::Data::Editor;
use Test::Routine;
use Test::Moose;
use Test::More;

use DateTime;
use DateTime::Format::Pg;
use MusicBrainz::Server::Constants qw( :edit_status $EDIT_ARTIST_EDIT );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test qw( accept_edit );
use Set::Scalar;
use Sql;
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

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

my $editor_data = MusicBrainz::Server::Data::Editor->new(c => $test->c);

my $editor = $editor_data->get_by_id(1);
ok(defined $editor, 'no editor returned');
isa_ok($editor, 'MusicBrainz::Server::Entity::Editor', 'not a editor');
is($editor->id, 1, 'id');
is($editor->name, 'new_editor', 'name');
is($editor->password, 'password', 'password');
is($editor->privileges, 1+8+32, 'privileges');
is($editor->accepted_edits, 12, 'accepted edits');
is($editor->rejected_edits, 2, 'rejected edits');
is($editor->failed_edits, 9, 'failed edits');
is($editor->accepted_auto_edits, 59, 'auto edits');

is_deeply($editor->last_login_date, DateTime->new(year => 2009, month => 01, day => 01),
    'last login date');

is_deeply($editor->email_confirmation_date, DateTime->new(year => 2005, month => 10, day => 20),
    'email confirm');

is_deeply($editor->registration_date, DateTime->new(year => 1989, month => 07, day => 23),
    'registration date');


my $editor2 = $editor_data->get_by_name('new_editor');
is_deeply($editor, $editor2);


$editor2 = $editor_data->get_by_name('nEw_EdItOr');
is_deeply($editor, $editor2, 'fetching by name is case insensitive');


# Test crediting
Sql::run_in_transaction(sub {
        $editor_data->credit($editor->id, $STATUS_APPLIED);
        $editor_data->credit($editor->id, $STATUS_APPLIED, auto_edit => 1);
        $editor_data->credit($editor->id, $STATUS_FAILEDVOTE);
        $editor_data->credit($editor->id, $STATUS_ERROR);
    }, $test->c->sql);


$editor = $editor_data->get_by_id($editor->id);
is($editor->accepted_edits, 13, "editor has 13 accepted edits");
is($editor->rejected_edits, 3, "editor has 3 rejected edits");
is($editor->failed_edits, 10, "editor has 10 failed edits");
is($editor->accepted_auto_edits, 60, "editor has 60 accepted auto edits");

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
is($new_editor_2->password, 'password', 'new editor 2 has correct password');
is($new_editor_2->accepted_edits, 0, 'new editor 2 has no accepted edits');


$editor = $editor_data->get_by_id($new_editor_2->id);
is($editor->email, undef);
is($editor->email_confirmation_date, undef);

my $now = DateTime::Format::Pg->parse_datetime(
    $test->c->sql->select_single_value('SELECT now()'));
$editor_data->update_email($new_editor_2, 'editor@example.com');

$editor = $editor_data->get_by_id($new_editor_2->id);
is($editor->email, 'editor@example.com', 'editor has correct e-mail address');
ok($now <= $editor->email_confirmation_date, 'email confirmation date updated correctly');
is($new_editor_2->email_confirmation_date, $editor->email_confirmation_date);

$editor_data->update_password($new_editor_2, 'password2');

$editor = $editor_data->get_by_id($new_editor_2->id);
is($editor->password, 'password2');

my @editors = $editor_data->find_by_email('editor@example.com');
is(scalar(@editors), 1);
is($editors[0]->id, $new_editor_2->id);


@editors = $editor_data->find_by_subscribed_editor (2, 10, 0);
is($editors[1], 1, "alice is subscribed to one person ...");
is($editors[0][0]->id, 1, "          ... that person is new_editor");


@editors = $editor_data->find_subscribers (1, 10, 0);
is($editors[1], 1, "new_editor has one subscriber ...");
is($editors[0][0]->id, 2, "          ... that subscriber is alice");


@editors = $editor_data->find_by_subscribed_editor (1, 10, 0);
is($editors[1], 0, "new_editor has not subscribed to anyone");

@editors = $editor_data->find_subscribers (2, 10, 0);
is($editors[1], 0, "alice has no subscribers");

subtest 'Find editors with subscriptions' => sub {
    my @editors = $editor_data->editors_with_subscriptions;
    is(@editors => 1, 'found 1 editor');
    is($editors[0]->id => 2, 'is editor #2');
};

};

test 'Deleting editors removes most information' => sub {
    my $test = shift;
    my $c = $test->c;
    my $model = $c->model('Editor');

    $c->sql->do(<<'EOSQL');
INSERT INTO country (id, iso_code, name) VALUES (1, 'bb', 'Bobland');
INSERT INTO language (id, iso_code_3, name) VALUES (1, 'bob', 'Bobch');
INSERT INTO gender (id, name) VALUES (1, 'Male');
INSERT INTO editor (id, name, password, email, website, bio, member_since,
    email_confirm_date, last_login_date, edits_accepted, edits_rejected,
    auto_edits_accepted, edits_failed, privs, birth_date, country, gender)
  VALUES (1, 'Bob', 'bob', 'bob@bob.bob', 'http://bob.bob/', 'Bobography', now(),
    now(), now(), 100, 101, 102, 103, 1, '1980-02-03', 1, 1);
INSERT INTO editor_language (editor, language, fluency) VALUES (1, 1, 'native');
EOSQL

    # Test deleting editors
    $model->delete(1);
    my $bob = $model->get_by_id(1);

    is($bob->name, 'Deleted Editor #' . $bob->id);
    is($bob->password, '');
    is($bob->privileges, 0);
    is($bob->accepted_edits, 100);
    is($bob->rejected_edits, 101);
    is($bob->accepted_auto_edits, 102);

    # Ensure all other attributes are cleared
    my $exclusions = Set::Scalar->new(
        qw( id name password privileges accepted_edits rejected_edits
            accepted_auto_edits last_login_date failed_edits languages
            registration_date preferences
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
        ipi_codes => []
    );

    accept_edit($c, $applied_edit);

    my $open_edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'A Comment',
        ipi_codes => []
    );

    is ($open_edit->status, $STATUS_OPEN);

    $c->model('Editor')->delete(1);

    is($c->model('Edit')->get_by_id($applied_edit->id)->status, $STATUS_APPLIED);
    is($c->model('Edit')->get_by_id($open_edit->id)->status, $STATUS_DELETED);
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
        ipi_codes => []
    );

    accept_edit($c, $applied_edit);

    my $open_edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_EDIT,
        editor_id => 1,
        to_edit => $c->model('Artist')->get_by_id(1),
        comment => 'A Comment',
        ipi_codes => []
    );

    is ($open_edit->status, $STATUS_OPEN);

    is($c->model('Editor')->open_edit_count(1), 1, "Open edit count is 1");
    is($c->model('Editor')->last_24h_edit_count(1), 2, "Last 24h count is 2");
};

test 'subscription_summary' => sub {
    my $test = shift;
    $test->c->sql->do(<<EOSQL);
INSERT INTO artist_name VALUES (1, 'artist');
INSERT INTO label_name VALUES (1, 'label');

INSERT INTO artist (id, gid, name, sort_name)
  VALUES (1, 'dd448d65-d7c5-4eef-8e13-12e1bfdacdc6', 1, 1);
INSERT INTO label (id, gid, name, sort_name)
  VALUES (1, 'dd448d65-d7c5-4eef-8e13-12e1bfdacdc6', 1, 1);

INSERT INTO editor (id, name, password)
  VALUES (1, 'Alice', 'al1c3'), (2, 'Bob', 'b0b');
INSERT INTO editor_subscribe_artist (id, editor, artist, last_edit_sent) VALUES
  (1, 1, 1, 1);
INSERT INTO editor_subscribe_label (id, editor, label, last_edit_sent) VALUES
  (1, 1, 1, 1), (2, 2, 1, 1);
INSERT INTO editor_subscribe_editor
  (id, editor, subscribed_editor, last_edit_sent) VALUES (1, 1, 1, 1);
EOSQL

    is_deeply($test->c->model('Editor')->subscription_summary(1),
              { artist => 1,
                label => 1,
                editor => 1 });

    is_deeply($test->c->model('Editor')->subscription_summary(2),
              { artist => 0,
                label => 1,
                editor => 0 });
};

1;
