package t::MusicBrainz::Server::Data::Edit;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Fatal;

BEGIN { use MusicBrainz::Server::Data::Edit };

{
    package t::Edit::MockEdit;
    use Moose;
    extends 'MusicBrainz::Server::Edit';
    sub edit_type { 123 }
    sub edit_name { 'mock edit' }
}

use Sql;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Constants qw( :edit_status $VOTE_YES $VOTE_APPROVE );

use MusicBrainz::Server::EditRegistry;
MusicBrainz::Server::EditRegistry->register_type("t::Edit::MockEdit");

with 't::Context';

test 'Merge entity edit history' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');
    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, <<'EOSQL');
INSERT INTO edit_artist (edit, artist) VALUES (4, 3);
EOSQL

    {
        my ($edits, $hits) = $test->c->model('Edit')->find({ artist => 2 }, 10, 0);
        is($hits => 1, 'found 1 edit before merge');
    }

    $test->c->model('Edit')->merge_entities('artist', 1, 2);

    {
        my ($edits, $hits) = $test->c->model('Edit')->find({ artist => 1 }, 10, 0);
        is($hits => 2, 'found 2 edits post merge');
    }

    {
        my ($edits, $hits) = $test->c->model('Edit')->find({ artist => 3 }, 10, 0);
        is($hits => 1, 'other entity-edit links are not affected');
    }
};

# Test approving edits, while something (editqueue) is holding a lock on it
# Acquire an exclusive lock on the edit
test 'Test locks on edits' => sub {
    my $test = shift;

    # We have to have some data present outside transactions.
    my $foreign_connection = MusicBrainz::Server::DatabaseConnectionFactory->get_connection(
        'TEST',
        fresh => 1
    );

    $foreign_connection->dbh->do("INSERT INTO editor (id, name, password, ha1) VALUES (50, 'editor', '{CLEARTEXT}password', '3a115bc4f05ea9856bd4611b75c80bca')");
    $foreign_connection->dbh->do(
        q{INSERT INTO edit (id, editor, type, status, data, expire_time)
             VALUES (12345, 50, 123, 1, '{ "key": "value" }', NOW())}
         );

    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');
    my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $test->c);

    my $sql2 = Sql->new($foreign_connection->conn);
    $sql2->begin;
    $sql2->select_single_row_array('SELECT * FROM edit WHERE id = 12345 FOR UPDATE');

    like exception { $edit_data->get_by_id_and_lock(12345) }, qr/could not obtain lock/;

    # Release the lock
    $sql2->rollback;
    $foreign_connection->dbh->do('DELETE FROM edit WHERE id = 12345');
    $foreign_connection->dbh->do('DELETE FROM editor WHERE id = 50');
};

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $test->c);

my $sql = $test->c->sql;

# Find all edits
my ($edits, $hits) = $edit_data->find({}, 10, 0);
is($hits, 5);
is(scalar @$edits, 5, "Found all edits");

# Check we get the edits in descending ID order
is($edits->[$_]->id, 5 - $_) for (0..4);

# Find edits with a certain status
($edits, $hits) = $edit_data->find({ status => $STATUS_OPEN }, 10, 0);
is($hits, 4);
is(scalar @$edits, 4, "Found all open edits");
is($edits->[0]->id, 5);
is($edits->[1]->id, 3);
is($edits->[2]->id, 2);
is($edits->[3]->id, 1);

# Find edits by a specific editor
($edits, $hits) = $edit_data->find({ editor => 1 }, 10, 0);
is($hits, 2);
is(scalar @$edits, 2, "Found edits by a specific editor");
is($edits->[0]->id, 3);
is($edits->[1]->id, 1);

# Find edits by a specific editor with a certain status
($edits, $hits) = $edit_data->find({ editor => 1, status => $STATUS_OPEN }, 10, 0);
is($hits, 2);
is(scalar @$edits, 2, "Found all open edits by a specific editor");
is($edits->[0]->id, 3);
is($edits->[1]->id, 1);

# Find edits with 0 results
($edits, $hits) = $edit_data->find({ editor => 122 }, 10, 0);
is($hits, 0);
is(scalar @$edits, 0, "Found no edits for a specific editor");

# Find edits by a certain artist
($edits, $hits) = $edit_data->find({ artist => 1 }, 10, 0);
is($hits, 2);
is(scalar @$edits, 2, "Found edits by a certain artist");
is($edits->[0]->id, 4);
is($edits->[1]->id, 1);

($edits, $hits) = $edit_data->find({ artist => 1, status => $STATUS_APPLIED }, 10, 0);
is($hits, 1);
is(scalar @$edits, 1, "Found applied edits by a certain artist");
is($edits->[0]->id, 4);

# Find edits over multiple entities
($edits, $hits) = $edit_data->find({ artist => [1,2] }, 10, 0);
is($hits, 1);
is(scalar @$edits, 1, "Found edits over multiple entities");
is($edits->[0]->id, 4);

# Test accepting edits
my $edit = $edit_data->get_by_id(1);

my $editor = $test->c->model('Editor')->get_by_id($edit->editor_id);
is($editor->accepted_edits, 12, "Edit not yet accepted");

$sql->begin;
$edit_data->accept($edit);
$sql->commit;

$editor = $test->c->model('Editor')->get_by_id($edit->editor_id);
is($editor->accepted_edits, 13, "Edit accepted");

# Test rejecting edits
$edit = $edit_data->get_by_id(3);

$editor = $test->c->model('Editor')->get_by_id($edit->editor_id);
is($editor->rejected_edits, 2, "Edit not yet rejected");

$sql->begin;
$edit_data->reject($edit, $STATUS_FAILEDVOTE);
$sql->commit;

$editor = $test->c->model('Editor')->get_by_id($edit->editor_id);
is($editor->rejected_edits, 3, "Edit rejected");

# Test approving edits, successfully this time
$edit = $edit_data->get_by_id_and_lock(5);
$edit_data->approve($edit, 1);

$edit = $edit_data->get_by_id(5);
is($edit->status, $STATUS_APPLIED);

$test->c->model('Vote')->load_for_edits($edit);
is($edit->votes->[0]->vote, $VOTE_APPROVE);
is($edit->votes->[0]->editor_id, 1);

# Test canceling
$edit = $edit_data->get_by_id(2);
$editor = $test->c->model('Editor')->get_by_id($edit->editor_id);

$edit_data->cancel($edit);

my $editor_cancelled = $test->c->model('Editor')->get_by_id($edit->editor_id);

$edit = $edit_data->get_by_id(2);
is($edit->status, $STATUS_DELETED);

is ($editor_cancelled->$_, $editor->$_,
    "$_ has not changed")
    for qw( accepted_edits rejected_edits failed_edits accepted_auto_edits );

};

test 'Find edits by subscription' => sub {
    use aliased 'MusicBrainz::Server::Entity::ArtistSubscription';
    use aliased 'MusicBrainz::Server::Entity::LabelSubscription';
    use aliased 'MusicBrainz::Server::Entity::EditorSubscription';

    my $test = shift;
    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');
    my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $test->c);

    my $sql = $test->c->sql;

    my $sub = ArtistSubscription->new( artist_id => 1, last_edit_sent => 0 );
    my @edits = $edit_data->find_for_subscription($sub);
    is(@edits => 2, 'found 2 edits');
    ok((grep { $_->id == 1 } @edits), 'has edit #1');
    ok((grep { $_->id == 4 } @edits), 'has edit #4');

    $sub = ArtistSubscription->new( artist_id => 1, last_edit_sent => 1 );
    @edits = $edit_data->find_for_subscription($sub);
    is(@edits => 1, 'found 1 edits');
    ok(!(grep { $_->id == 1 } @edits), 'does not have edit #1');
    ok((grep { $_->id == 4 } @edits), 'has edit #4');

    $sub = EditorSubscription->new( subscribed_editor_id => 2, last_edit_sent => 0 );
    @edits = $edit_data->find_for_subscription($sub);
    is(@edits => 2, 'found 1 edits');
    ok((grep { $_->id == 2 } @edits), 'has edit #2');
    ok((grep { $_->id == 4 } @edits), 'has edit #4');

    $sub = LabelSubscription->new( label_id => 1, last_edit_sent => 0 );
    @edits = $edit_data->find_for_subscription($sub);
    is(@edits => 1, 'found 1 edits');
    ok((grep { $_->id == 2 } @edits), 'has edit #2');

    $sql->do('UPDATE edit SET status = ? WHERE id = ?',
             $STATUS_ERROR, 1);
    $sub = ArtistSubscription->new( artist_id => 1, last_edit_sent => 0 );
    @edits = $edit_data->find_for_subscription($sub);
    is(@edits => 1, 'found 1 edit');
    ok(!(grep { $_->id == 1 } @edits), 'doesnt have edit #1');
    ok((grep { $_->id == 4 } @edits), 'has edit #4');
};

test 'Accepting auto-edits should credit editor auto-edits column' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');

    my $editor = $c->model('Editor')->get_by_id(1);
    my $old_ae_count = $editor->accepted_auto_edits;
    my $old_e_count = $editor->accepted_edits;

    my $edit = $c->model('Edit')->create(
        edit_type => 123,
        editor_id => 1,
        privileges => 1
    );

    $editor = $c->model('Editor')->get_by_id(1);
    is $editor->accepted_auto_edits, $old_ae_count + 1;
    is $editor->accepted_edits, $old_e_count;
};

1;
