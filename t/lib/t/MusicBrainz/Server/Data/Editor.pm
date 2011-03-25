package t::MusicBrainz::Server::Data::Editor;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Memory::Cycle;

use DateTime;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Types qw( $STATUS_FAILEDVOTE $STATUS_APPLIED $STATUS_ERROR );
use Sql;

BEGIN { use MusicBrainz::Server::Data::Editor; }

with 't::Context';

test get_ratings => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');
    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '
TRUNCATE artist_rating_raw CASCADE;
INSERT INTO artist_rating_raw (artist, editor, rating) VALUES (1, 1, 80);
');

    my $editor = $test->c->model('Editor')->get_by_id(1);
    my $ratings = $test->c->model('Editor')->get_ratings($editor);

    is($ratings->{artist}->[0]->{artist}->id => 1, 'has artist entity');
    is($ratings->{artist}->[0]->{rating} => 80, 'has raw rating');
    is($ratings->{artist}->[0]->{artist}->rating => 80, 'has rating on entity');
    is($ratings->{artist}->[0]->{artist}->rating_count => 1, 'has rating on entity');
};

test all => sub {

my $test = shift;

MusicBrainz::Server::Test->prepare_test_database($test->c, '+editor');

my $editor_data = MusicBrainz::Server::Data::Editor->new(c => $test->c);
memory_cycle_ok($editor_data);

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

memory_cycle_ok($editor_data);
memory_cycle_ok($editor);

my $editor2 = $editor_data->get_by_name('new_editor');
is_deeply($editor, $editor2);

memory_cycle_ok($editor_data);
memory_cycle_ok($editor);

$editor2 = $editor_data->get_by_name('nEw_EdItOr');
is_deeply($editor, $editor2, 'fetching by name is case insensitive');

memory_cycle_ok($editor_data);
memory_cycle_ok($editor);

# Test crediting
Sql::run_in_transaction(sub {
        $editor_data->credit($editor->id, $STATUS_APPLIED);
        $editor_data->credit($editor->id, $STATUS_APPLIED, 1);
        $editor_data->credit($editor->id, $STATUS_FAILEDVOTE);
        $editor_data->credit($editor->id, $STATUS_ERROR);
    }, $test->c->sql);

memory_cycle_ok($editor);

$editor = $editor_data->get_by_id($editor->id);
is($editor->accepted_edits, 13);
is($editor->rejected_edits, 3);
is($editor->failed_edits, 10);
is($editor->accepted_auto_edits, 60);

my $alice = $editor_data->get_by_name('alice');
# Test preferences
is($alice->preferences->public_ratings, 1, 'use default preference');
$editor_data->load_preferences($alice);
is($alice->preferences->public_ratings, 0, 'load preferences');
is($alice->preferences->datetime_format, '%m/%d/%Y %H:%M:%S', 'datetime_format loaded');
is($alice->preferences->timezone, 'UTC', 'timezone loaded');

memory_cycle_ok($editor_data);
memory_cycle_ok($alice);

my $new_editor_2 = $editor_data->insert({
    name => 'new_editor_2',
    password => 'password',
});
ok($new_editor_2->id > $editor->id);
is($new_editor_2->name, 'new_editor_2');
is($new_editor_2->password, 'password');
is($new_editor_2->accepted_edits, 0);

memory_cycle_ok($editor_data);
memory_cycle_ok($new_editor_2);

$editor = $editor_data->get_by_id($new_editor_2->id);
is($editor->email, undef);
is($editor->email_confirmation_date, undef);

my $now = DateTime->now;
$editor_data->update_email($new_editor_2, 'editor@example.com');
memory_cycle_ok($editor_data);

$editor = $editor_data->get_by_id($new_editor_2->id);
is($editor->email, 'editor@example.com');
ok($now <= $editor->email_confirmation_date);
is($new_editor_2->email_confirmation_date, $editor->email_confirmation_date);

$editor_data->update_password($new_editor_2, 'password2');
memory_cycle_ok($editor_data);

$editor = $editor_data->get_by_id($new_editor_2->id);
is($editor->password, 'password2');

my @editors = $editor_data->find_by_email('editor@example.com');
is(scalar(@editors), 1);
is($editors[0]->id, $new_editor_2->id);

memory_cycle_ok($editor_data);
memory_cycle_ok(\@editors);

@editors = $editor_data->find_by_subscribed_editor (2, 10, 0);
is($editors[1], 1, "alice is subscribed to one person ...");
is($editors[0][0]->id, 1, "          ... that person is new_editor");

memory_cycle_ok($editor_data);
memory_cycle_ok(\@editors);

@editors = $editor_data->find_subscribers (1, 10, 0);
is($editors[1], 1, "new_editor has one subscriber ...");
is($editors[0][0]->id, 2, "          ... that subscriber is alice");

memory_cycle_ok($editor_data);
memory_cycle_ok(\@editors);

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

1;
