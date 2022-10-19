package t::MusicBrainz::Server::Data::Edit;
use strict;
use warnings;

use Test::Routine;
use Test::Moose;
use Test::More;
use Test::Fatal;
use Clone qw( clone );
use List::AllUtils qw( pairwise );

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
use MusicBrainz::Server::Constants qw(
    :edit_status
    $UNTRUSTED_FLAG
    $VOTE_APPROVE
);

use MusicBrainz::Server::EditRegistry;
MusicBrainz::Server::EditRegistry->register_type('t::Edit::MockEdit');

with 't::Context';

my $edit_data; # make file-level, so it can be accessed by subtests

test 'Merge entity edit history' => sub {
    my $test = shift;
    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');
    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, <<~'SQL');
        INSERT INTO edit_artist (edit, artist) VALUES (4, 3);
        SQL

    {
        my (undef, $hits) = $test->c->model('Edit')->find({ artist => 2 }, 10, 0);
        is($hits => 1, 'found 1 edit before merge');
    }

    $test->c->model('Edit')->merge_entities('artist', 1, 2);

    {
        my (undef, $hits) = $test->c->model('Edit')->find({ artist => 1 }, 10, 0);
        is($hits => 2, 'found 2 edits post merge');
    }

    {
        my (undef, $hits) = $test->c->model('Edit')->find({ artist => 3 }, 10, 0);
        is($hits => 1, 'other entity-edit links are not affected');
    }
};

# Test approving edits, while something (editqueue) is holding a lock on it
# Acquire an exclusive lock on the edit
test 'Test locks on edits' => sub {
    my $test = shift;

    # We have to have some data present outside transactions.
    my $foreign_connection = MusicBrainz::Server::DatabaseConnectionFactory->get_connection('TEST', fresh => 1);

    $foreign_connection->dbh->do('INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
             VALUES (50, $$editor$$, $${CLEARTEXT}password$$, $$3a115bc4f05ea9856bd4611b75c80bca$$, $$foo@example.com$$, now())');
    $foreign_connection->dbh->do(q{INSERT INTO edit (id, editor, type, status, expire_time)
             VALUES (12345, 50, 123, 1, NOW())});
    $foreign_connection->dbh->do(q{INSERT INTO edit_data (edit, data)
             VALUES (12345, '{ "key": "value" }')});

    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');
    $edit_data = MusicBrainz::Server::Data::Edit->new(c => $test->c);

    my $sql2 = Sql->new($foreign_connection->conn);
    $sql2->begin;
    $sql2->select_single_row_array('SELECT * FROM edit WHERE id = 12345 FOR UPDATE');

    like exception { $edit_data->get_by_id_and_lock(12345) }, qr/could not obtain lock/, 'Lock found';

    # Release the lock
    $sql2->rollback;
    $foreign_connection->dbh->do('DELETE FROM edit_data WHERE edit = 12345');
    $foreign_connection->dbh->do('DELETE FROM edit WHERE id = 12345');
    $foreign_connection->dbh->do('DELETE FROM editor WHERE id = 50');
};

sub is_expected_edit_ids {
    my ($expected_edit_ids, $edits) = @_;
    pairwise { is($a->id, $b, 'Found edit #'.$a->id) } @$edits, @$expected_edit_ids;
}

test all => sub {

    sub test_find_edits {
        my ($query, $expected_edit_ids, $test_name) = @_;
        subtest $test_name => sub {
            is_expected_edit_ids($expected_edit_ids, $edit_data->find($query, 10, 0));
        };
    };

    sub test_number_of_results_returned {
        my ($query, $expected_hits, $expected_array_size, $test_name) = @_;
        subtest $test_name => sub {
            my ($edits, $hits) = $edit_data->find($query, 2, 0);
            is($hits, $expected_hits, "Got expected number of hits: $expected_hits");
            is(scalar @$edits, $expected_array_size, "Got expected array size: $expected_array_size");
        };
    };

    my $test = shift;
    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');
    $edit_data = MusicBrainz::Server::Data::Edit->new(c => $test->c);
    my $sql = $test->c->sql;
    my $editor_model = $test->c->model('Editor');

    # Verify that hits will differ from the length
    # of the returned array if there are more results than
    # is given in the 2nd parameter to find()
    test_number_of_results_returned({}, 5, 2, 'Max results vs. hits');

    test_find_edits({}, [5, 4, 3, 2, 1], 'Every edit');
    test_find_edits({ status => $STATUS_OPEN }, [5, 3, 2, 1], 'Open edits', $edit_data);
    test_find_edits({ editor => 1 }, [3, 1], 'Edits by editor', $edit_data);
    test_number_of_results_returned({ editor => 122 }, 0, 0, 'No results');
    test_find_edits({ editor => 1, status => $STATUS_OPEN }, [3, 1], 'Open edits by editor', $edit_data);
    test_find_edits({ artist => 1 }, [4,1], 'Edits by an artist', $edit_data);
    test_find_edits({ status => $STATUS_APPLIED, artist => 1 }, [4], 'Applied edits by an artist', $edit_data);
    test_find_edits({ status => $STATUS_APPLIED, artist => [1,2] }, [4], 'Applied edits by either of two artists', $edit_data);

    subtest 'Accepting an edit' => sub {
        my $edit = $edit_data->get_by_id(1);

        my $edit_counts = $editor_model->various_edit_counts($edit->editor_id);
        is($edit_counts->{accepted_count}, 0, 'Edit not yet accepted');

        $sql->begin;
        $edit_data->accept($edit);
        $sql->commit;

        $edit_counts = $editor_model->various_edit_counts($edit->editor_id);
        is($edit_counts->{accepted_count}, 1, 'Edit accepted');
    };

    subtest 'Rejecting an edit' => sub {
        my $edit = $edit_data->get_by_id(3);

        my $edit_counts = $editor_model->various_edit_counts($edit->editor_id);
        is($edit_counts->{rejected_count}, 0, 'Edit not yet rejected');

        $sql->begin;
        $edit_data->reject($edit, $STATUS_FAILEDVOTE);
        $sql->commit;

        $edit_counts = $editor_model->various_edit_counts($edit->editor_id);
        is($edit_counts->{rejected_count}, 1, 'Edit rejected');
    };

    subtest 'Approving an edit' => sub {
        my $editor = $test->c->model('Editor')->get_by_id(1);
        my $edit = $edit_data->get_by_id_and_lock(5);
        is($edit->status, $STATUS_OPEN, 'Edit open');
        $edit_data->approve($edit, $editor);

        $edit = $edit_data->get_by_id(5);
        is($edit->status, $STATUS_APPLIED, 'Edit now applied');

        $test->c->model('Vote')->load_for_edits($edit);
        is($edit->votes->[0]->vote, $VOTE_APPROVE, 'First vote is approval');
        is($edit->votes->[0]->editor_id, 1, 'First vote by editor-1');
    };

    subtest 'Canceling an edit'=> sub {
        my $edit = $edit_data->get_by_id(2);
        is($edit->status, $STATUS_OPEN, 'Edit open');

        my $edit_counts = $editor_model->various_edit_counts($edit->editor_id);
        my $original_accepted_edits = $edit_counts->{accepted_count};
        my $original_rejected_edits = $edit_counts->{rejected_count};
        my $original_failed_edits = $edit_counts->{failed_count};
        my $original_accepted_auto_edits = $edit_counts->{accepted_auto_count};

        $edit_data->cancel($edit);
        $edit = $edit_data->get_by_id(2);
        is($edit->status, $STATUS_DELETED, 'Edit now canceled');

        $edit_counts = $editor_model->various_edit_counts($edit->editor_id);
        my $cancelled_accepted_edits = $edit_counts->{accepted_count};
        my $cancelled_rejected_edits = $edit_counts->{rejected_count};
        my $cancelled_failed_edits = $edit_counts->{failed_count};
        my $cancelled_accepted_auto_edits = $edit_counts->{accepted_auto_count};

        is($original_accepted_edits, $cancelled_accepted_edits, 'accepted_count has not changed');
        is($original_rejected_edits, $cancelled_rejected_edits, 'rejected_count has not changed');
        is($original_failed_edits, $cancelled_failed_edits, 'failed_count has not changed');
        is($original_accepted_auto_edits, $cancelled_accepted_auto_edits, 'accepted_auto_count has not changed');
    };
};

test 'Collections' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+collection');
    $edit_data = MusicBrainz::Server::Data::Edit->new(c => $test->c);

    is_expected_edit_ids([3], $edit_data->find_by_collection(1, 10, 0));
};

test 'Find edits by subscription' => sub {
    use aliased 'MusicBrainz::Server::Entity::Subscription::Artist' => 'ArtistSubscription';
    use aliased 'MusicBrainz::Server::Entity::Subscription::Label' => 'LabelSubscription';
    use aliased 'MusicBrainz::Server::Entity::EditorSubscription';

    my $test = shift;
    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');
    $edit_data = MusicBrainz::Server::Data::Edit->new(c => $test->c);

    my $sql = $test->c->sql;

    sub test_find_subscription_edits {
        my ($sub, $expected_edit_ids, $test_name) = @_;
        subtest $test_name => sub {
            my @edits = $edit_data->find_for_subscription($sub);
            is_expected_edit_ids($expected_edit_ids, \@edits);
        };
    };
    test_find_subscription_edits(ArtistSubscription->new(artist_id => 1, last_edit_sent => 0), [1, 4], 'Artist subscription');
    test_find_subscription_edits(ArtistSubscription->new(artist_id => 1, last_edit_sent => 1), [4], 'Artist subscription with offset');
    test_find_subscription_edits(EditorSubscription->new(subscribed_editor_id => 2, last_edit_sent => 0), [2, 4], 'Editor subscription');
    test_find_subscription_edits(LabelSubscription->new(label_id => 1, last_edit_sent => 0), [2], 'Label subscription');

    $sql->do('UPDATE edit SET status = ? WHERE id = ?', $STATUS_ERROR, 1);
    my $edit = $edit_data->get_by_id(1);
    is($edit->status, $STATUS_ERROR, 'Edit now in error');
    test_find_subscription_edits(ArtistSubscription->new(artist_id => 1, last_edit_sent => 0), [4], 'Artist subscription after an edit marked as error');
};

test 'Accepting auto-edits should credit editor auto-edits column' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_raw_test_database($test->c, '+edit');

    my $edit_counts = $c->model('Editor')->various_edit_counts(1);
    my $old_ae_count = $edit_counts->{accepted_auto_count};
    my $old_e_count = $edit_counts->{accepted_count};

    $c->model('Edit')->create(
        edit_type => 123,
        editor_id => 1,
        privileges => 1
    );

    $edit_counts = $c->model('Editor')->various_edit_counts(1);
    my $new_ae_count = $edit_counts->{accepted_auto_count};
    my $new_e_count = $edit_counts->{accepted_count};

    is $new_ae_count, $old_ae_count + 1, 'One more accepted auto-edit';
    is $new_e_count, $old_e_count, 'Same number of accepted edits';
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

test 'Open edits expire in 7 days (MBS-8681)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_raw_test_database($c, '+edit');

    my $edit = $c->model('Edit')->create(
        edit_type => 123,
        editor_id => 1,
        privileges => $UNTRUSTED_FLAG,
    );

    is($edit->edit_conditions->{duration}, 7);

    my ($expire_time) = @{ $c->sql->select_list_of_hashes(<<~'SQL', $edit->id) };
        SELECT expire_time AS got,
               (open_time + interval '@ 7 days') AS expected
        FROM edit WHERE id = ?
        SQL

    is($expire_time->{got}, $expire_time->{expected});
};

1;
