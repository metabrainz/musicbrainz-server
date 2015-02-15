package t::MusicBrainz::Server::Data::Edit;
use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Fatal;
use Clone qw( clone );
use List::MoreUtils qw( pairwise );

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

    $foreign_connection->dbh->do('INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (50, $$editor$$, $${CLEARTEXT}password$$, $$3a115bc4f05ea9856bd4611b75c80bca$$, $$foo@example.com$$, now())');
    $foreign_connection->dbh->do(
        q{INSERT INTO edit (id, editor, type, status, data, expire_time)
             VALUES (12345, 50, 123, 1, '{ "key": "value" }', NOW())}
         );

    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');
    my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $test->c);

    my $sql2 = Sql->new($foreign_connection->conn);
    $sql2->begin;
    $sql2->select_single_row_array('SELECT * FROM edit WHERE id = 12345 FOR UPDATE');

    like exception { $edit_data->get_by_id_and_lock(12345) }, qr/could not obtain lock/, 'Lock found';

    # Release the lock
    $sql2->rollback;
    $foreign_connection->dbh->do('DELETE FROM edit WHERE id = 12345');
    $foreign_connection->dbh->do('DELETE FROM editor WHERE id = 50');
};

sub are_edits_as_expected {
  my ($expected_edit_ids, $prefix, $edits, $hits) = @_;
  is($hits, scalar @$expected_edit_ids, "Found expected number for ${prefix} edits");
  is(scalar @$edits, scalar @$expected_edit_ids, "Found expected size of ${prefix} edits array");
  pairwise { is($a->id, $b, "Found ${prefix} edit #".$a->id) } @$edits, @$expected_edit_ids;
}

sub check_edits {
  my ($find_hash, $expected_edit_ids, $prefix, $edit_data) = @_;
  are_edits_as_expected($expected_edit_ids, $prefix, $edit_data->find($find_hash, 10, 0));
}

test all => sub {

my $test = shift;
MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $test->c);

my $sql = $test->c->sql;

# Find all edits
check_edits({}, [5, 4, 3, 2, 1], "every", $edit_data);

# Find edits with a certain status
check_edits({ status => $STATUS_OPEN }, [5, 3, 2, 1], "open", $edit_data);

# Find edits by a specific editor
check_edits({ editor => 1 }, [3, 1], "editor-1", $edit_data);

# Find edits by a specific editor with a certain status
check_edits({ editor => 1, status => $STATUS_OPEN }, [3, 1], "open-editor-1", $edit_data);

# Find edits with 0 results
check_edits({ editor => 122 }, [], "none-found", $edit_data);

# Find edits by a certain artist
check_edits({ artist => 1 }, [4,1], "artist-1", $edit_data);

check_edits({ status => $STATUS_APPLIED, artist => 1 }, [4], "applied-artist-1", $edit_data);

# Find edits over multiple entities
check_edits({ status => $STATUS_APPLIED, artist => [1,2] }, [4], "artists-1-and-2", $edit_data);

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
my $editor1 = $test->c->model('Editor')->get_by_id(1);
$edit = $edit_data->get_by_id_and_lock(5);
$edit_data->approve($edit, $editor1);

$edit = $edit_data->get_by_id(5);
is($edit->status, $STATUS_APPLIED, "Edit applied");

$test->c->model('Vote')->load_for_edits($edit);
is($edit->votes->[0]->vote, $VOTE_APPROVE, "First vote is approval");
is($edit->votes->[0]->editor_id, 1, "First vote by editor-1");

# Test canceling
$edit = $edit_data->get_by_id(2);
$editor = $test->c->model('Editor')->get_by_id($edit->editor_id);

$edit_data->cancel($edit);

my $editor_cancelled = $test->c->model('Editor')->get_by_id($edit->editor_id);

$edit = $edit_data->get_by_id(2);
is($edit->status, $STATUS_DELETED, "Edit canceled");

is ($editor_cancelled->$_, $editor->$_,
    "$_ has not changed")
    for qw( accepted_edits rejected_edits failed_edits accepted_auto_edits );

};

test 'Collections' => sub {
  my $test = shift;

  MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+collection');
  my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $test->c);

  #Find edits by collection
  are_edits_as_expected([3], "collection", $edit_data->find_by_collection(1, 10, 0));
};

test 'Find edits by subscription' => sub {
    use aliased 'MusicBrainz::Server::Entity::Subscription::Artist' => 'ArtistSubscription';
    use aliased 'MusicBrainz::Server::Entity::Subscription::Label' => 'LabelSubscription';
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
    is $editor->accepted_auto_edits, $old_ae_count + 1, "One more accepted auto-edit";
    is $editor->accepted_edits, $old_e_count, "Same number of accepted edits";
};

test 'default_includes function' => sub {
    my $test = shift;

    my $objects_to_load = {
        Area    => [ 3, 14, 159, 265 ],
        Artist  => [ 3, 5, 8, 9, 79 ],
        Place   => [ 3, 23, 84, 626, 4338 ],
    };
    my $post_load_models = {
        Area => {
              14 => [],
             159 => [ 'ModelOne', 'AreaContainment' ],
             265 => [ 'ModelOne', 'AreaContainment ModelTwo' ],
        },
        Artist => {
               5 => [ 'Place' ],
               9 => [ 'ModelThree' ],
              79 => [ 'Area' ],
        },
        Place => {
               3 => [ 'Area AreaContainment' ],
              84 => [ 'Area' ],
             626 => [ 'ModelFour AreaContainment' ],
            4338 => [ 'ModelFive' ],
        },
    };

    my $expected_objects_to_load = clone($objects_to_load);
    my $expected_post_load_models = {
        Area => {
               3 => [ 'AreaContainment' ],
              14 => [ 'AreaContainment' ],
             159 => [ 'ModelOne', 'AreaContainment' ],
             265 => [ 'ModelOne', 'AreaContainment ModelTwo' ],
        },
        Artist => {
               5 => [ 'Place Area AreaContainment' ],
               9 => [ 'ModelThree' ],
              79 => [ 'Area AreaContainment' ],
        },
        Place => {
               3 => [ 'Area AreaContainment' ],
              23 => [ 'Area AreaContainment' ],
              84 => [ 'Area AreaContainment' ],
             626 => [ 'ModelFour AreaContainment', 'Area AreaContainment' ],
            4338 => [ 'ModelFive', 'Area AreaContainment' ],
        },
    };

    MusicBrainz::Server::Data::Edit::default_includes($objects_to_load, $post_load_models);

    is_deeply($objects_to_load, $expected_objects_to_load, 'objects_to_load unchanged');
    is_deeply($post_load_models, $expected_post_load_models, 'post_load_models correctly modified');
};

1;
