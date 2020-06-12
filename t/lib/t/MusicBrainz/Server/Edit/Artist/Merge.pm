package t::MusicBrainz::Server::Edit::Artist::Merge;
use utf8;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::Merge }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Constants qw( :edit_status );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

test 'Non-existent merge target' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');

    my $edit = create_edit($c);
    $c->model('Artist')->delete(4);

    accept_edit($c, $edit);

    is($edit->status, $STATUS_FAILEDDEP);
    ok(defined $c->model('Artist')->get_by_id(3));
};

test 'Merging a person with a gender into a group' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');
    $c->sql->do(<<'EOSQL');
UPDATE artist SET type = 2, gender = NULL WHERE id = 4;
UPDATE artist SET type = 1, gender = 2 WHERE id = 3;
EOSQL

    # merge 3 -> 4
    my $edit = create_edit($c);

    ok(!exception { accept_edit($c, $edit) },
       'Edit merging a person with a gender into a group does not cause an exception');

    my $row = $c->sql->select_single_row_hash('SELECT * FROM artist WHERE id = 4');
    is($row->{type}, 2, 'The resulting type is a group');
    is($row->{gender}, undef, 'The resulting gender is null');

    $c->model('EditNote')->load_for_edits($edit);
    is(scalar $edit->all_edit_notes, 1);

    my $note = scalar($edit->all_edit_notes) ? $edit->edit_notes->[0] : undef;
    is(
        defined $note && $note->localize,
        'The “Female” gender has not been added to the ' .
        'destination artist because it conflicted with the ' .
        'group type of one of the artists here. Group artists ' .
        'cannot have a gender.',
    );
};

test 'Merging an artist with no type and a gender into a group' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');
    $c->sql->do(<<'EOSQL');
UPDATE artist SET type = 2, gender = NULL WHERE id = 4;
UPDATE artist SET type = NULL, gender = 2 WHERE id = 3;
EOSQL

    # merge 3 -> 4
    my $edit = create_edit($c);

    ok(!exception { accept_edit($c, $edit) },
       'Edit merging a person with no type and a gender into a group does not cause an exception');

    my $row = $c->sql->select_single_row_hash('SELECT * FROM artist WHERE id = 4');
    is($row->{type}, 2, 'The resulting type is a group');
    is($row->{gender}, undef, 'The resulting gender is null');

    $c->model('EditNote')->load_for_edits($edit);
    is(scalar $edit->all_edit_notes, 1);

    my $note = scalar($edit->all_edit_notes) ? $edit->edit_notes->[0] : undef;
    is(
        defined $note && $note->localize,
        'The “Female” gender has not been added to the ' .
        'destination artist because it conflicted with the ' .
        'group type of one of the artists here. Group artists ' .
        'cannot have a gender.',
    );
};

test 'Merging a group into an artist with no type and a gender' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');
    $c->sql->do(<<'EOSQL');
UPDATE artist SET type = NULL, gender = 2 WHERE id = 4;
UPDATE artist SET type = 2, gender = NULL WHERE id = 3;
EOSQL

    # merge 3 -> 4
    my $edit = create_edit($c);

    ok(!exception { accept_edit($c, $edit) },
       'Edit merging a group into an artist with no type and a gender does not cause an exception');

    my $row = $c->sql->select_single_row_hash('SELECT * FROM artist WHERE id = 4');
    is($row->{type}, undef, 'The resulting type is null');
    is($row->{gender}, 2, 'The resulting gender is female');

    $c->model('EditNote')->load_for_edits($edit);
    is(scalar $edit->all_edit_notes, 1);

    my $note = scalar($edit->all_edit_notes) ? $edit->edit_notes->[0] : undef;
    is(
        defined $note && $note->localize,
        'The “Group” type has not been added to the ' .
        'destination artist because it conflicted with the ' .
        'gender setting of one of the artists here. Group ' .
        'artists cannot have a gender.',
    );
};

test 'Merging a group into a person with a gender' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');
    $c->sql->do(<<'EOSQL');
UPDATE artist SET type = 1, gender = 2 WHERE id = 4;
UPDATE artist SET type = 2, gender = NULL WHERE id = 3;
EOSQL

    # merge 3 -> 4
    my $edit = create_edit($c);

    ok(!exception { accept_edit($c, $edit) },
       'Edit merging a group into a person with a gender does not cause an exception');

    my $row = $c->sql->select_single_row_hash('SELECT * FROM artist WHERE id = 4');
    is($row->{type}, 1, 'The resulting type is person');
    is($row->{gender}, 2, 'The resulting gender is female');

    $c->model('EditNote')->load_for_edits($edit);
    is(scalar $edit->all_edit_notes, 0);
};

test 'Merging a group, and an artist with no type and a gender, into an artist with no type or gender' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');
    $c->sql->do(<<'EOSQL');
UPDATE artist SET type = NULL, gender = NULL WHERE id = 4;
UPDATE artist SET type = 2, gender = NULL WHERE id = 3;
UPDATE artist SET type = NULL, gender = 1 WHERE id = 5;
EOSQL

    # merge 3 & 5 -> 4
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_MERGE,
        editor_id => 1,
        old_entities => [
            { id => 3, name => 'Old Artist' },
            { id => 5, name => 'Another Old Artist' },
        ],
        new_entity => { id => 4, name => 'New Artist' },
        rename => 0,
    );

    ok(!exception { accept_edit($c, $edit) },
       'Edit merging a group, and an artist with no type and a gender, into an artist with no type or gender does not cause an exception');

    my $row = $c->sql->select_single_row_hash('SELECT * FROM artist WHERE id = 4');
    # In this case we drop both columns, since it's not clear which to use.
    is($row->{type}, undef, 'The resulting type is null');
    is($row->{gender}, undef, 'The resulting gender is null');

    $c->model('EditNote')->load_for_edits($edit);
    is(scalar $edit->all_edit_notes, 2);

    my $note = scalar($edit->all_edit_notes) ? $edit->edit_notes->[0] : undef;
    is(
        defined $note && $note->localize,
        'The “Group” type has not been added to the ' .
        'destination artist because it conflicted with the ' .
        'gender setting of one of the artists here. Group ' .
        'artists cannot have a gender.',
    );
    $note = scalar($edit->all_edit_notes) > 1 ? $edit->edit_notes->[1] : undef;
    is(
        defined $note && $note->localize,
        'The “Male” gender has not been added to the ' .
        'destination artist because it conflicted with the ' .
        'group type of one of the artists here. Group artists ' .
        'cannot have a gender.',
    );
};

# The name of this test may be confusing, since the code should do the opposite
# of what is understood to happen in the UI. By "renaming" the credits, the code
# should do nothing and leave them empty, so that they take on the new artist
# name. By "not renaming" the credits, the code should rename them to have the
# old artist name, making them appear to be the same as before the merge.

test 'Merge, renaming relationship credits' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');

    my $edit = create_edit($c, 1);
    accept_edit($c, $edit);

    my $relationship = $c->model('Relationship')->get_by_id('artist', 'recording', 1);
    is($relationship->entity0_credit, '', 'entity0_credit is empty, so it shows the new artist name');
};

test 'Merge, without renaming relationship credits' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');

    my $edit = create_edit($c, 0);
    accept_edit($c, $edit);

    my $relationship = $c->model('Relationship')->get_by_id('artist', 'recording', 1);
    is($relationship->entity0_credit, 'Old Artist', 'entity0_credit has the old artist name');
};

test all => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');

    my $edit = create_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Merge');

    my ($edits, $hits) = $c->model('Edit')->find({ artist => [3, 4] }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    my $a1 = $c->model('Artist')->get_by_id(3);
    my $a2 = $c->model('Artist')->get_by_id(4);
    is($a1->edits_pending, 1);
    is($a2->edits_pending, 1);

    reject_edit($c, $edit);

    $a1 = $c->model('Artist')->get_by_id(3);
    $a2 = $c->model('Artist')->get_by_id(4);
    is($a1->edits_pending, 0);
    is($a2->edits_pending, 0);

    $edit = create_edit($c);
    accept_edit($c, $edit);

    $a1 = $c->model('Artist')->get_by_id(3);
    $a2 = $c->model('Artist')->get_by_id(4);
    ok(!defined $a1);
    ok(defined $a2);

    is($a2->edits_pending, 0);

    my $ipi_codes = $c->model('Artist')->ipi->find_by_entity_id($a2->id);
    is(scalar @$ipi_codes, 3, "Merged Artist has all ipi codes after accepting edit");

    my $isni_codes = $c->model('Artist')->isni->find_by_entity_id($a2->id);
    is(scalar @$isni_codes, 4, "Merged Artist has all isni codes after accepting edit");
};

test 'Downvoted tags are preserved post-merge (MBS-8524)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_merge');

    $c->sql->do(<<'EOSQL');
INSERT INTO tag (id, name, ref_count) VALUES (1, 'electronic', 0);
INSERT INTO artist_tag_raw (artist, editor, tag, is_upvote) VALUES (3, 1, 1, FALSE);
INSERT INTO artist_tag (artist, count, tag) VALUES (3, -1, 1);
EOSQL

    my $edit = create_edit($c);
    accept_edit($c, $edit);

    my @tags = $c->model('Artist')->tags->find_user_tags(1, 4);
    is($tags[0]->tag->name, 'electronic');
    is($tags[0]->is_upvote, 0);
};

sub create_edit {
    my ($c, $rename) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_MERGE,
        editor_id => 1,
        old_entities => [ { id => 3, name => 'Old Artist' } ],
        new_entity => { id => 4, name => 'New Artist' },
        rename => $rename // 0
    );
}

1;
