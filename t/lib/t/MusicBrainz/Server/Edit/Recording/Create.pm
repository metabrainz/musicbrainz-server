package t::MusicBrainz::Server::Edit::Recording::Create;

use utf8;

use Test::Deep qw( cmp_set );
use Test::Routine;
use Test::More;

use MusicBrainz::Server::Constants qw(
    $EDITOR_MODBOT
    $EDIT_RECORDING_CREATE
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test qw( accept_edit reject_edit );
use MusicBrainz::Server::Constants qw( :edit_status );

around run_test => sub {
    my ($orig, $test, @args) = @_;

    MusicBrainz::Server::Test->prepare_test_database($test->c, <<~'SQL');
        INSERT INTO artist (id, gid, name, sort_name)
            VALUES (1, 'a9d99e40-72d7-11de-8a39-0800200c9a66', 'Name', 'Name');
        INSERT INTO artist_credit (id, name, artist_count) VALUES (1, 'Name', 1);

        INSERT INTO release_group (id, name, type, artist_credit, gid)
            VALUES (22, 'エアリアル', 1, 1, '6169f5bc-b5ff-3348-b806-1b0f2a414217');
        INSERT INTO release (id, name, release_group, artist_credit, gid)
            VALUES (22, 'エアリアル', 22, 1, '888695fa-8acf-4ddb-8726-23edf32e48c5');
        INSERT INTO medium (id, release, position) VALUES (22, 22, 1);
        ALTER SEQUENCE artist_id_seq RESTART 2;
        SQL

    $test->$orig(@args);
};

with 't::Edit';
with 't::Context';

test 'Accept edit' => sub {
    my $test = shift;

    # Edit should be accepted automatically.
    my $edit = create_edit($test->c);

    my $recording = created_recording_ok($test->c, $edit->entity_id);
    is($recording->edits_pending, 0, 'has no edits pending');

    is($edit->status => $STATUS_APPLIED);
};

test 'Reject edit' => sub {
    my $test = shift;

    my $edit = create_edit($test->c, privileges => $UNTRUSTED_FLAG);
    reject_edit($test->c, $edit);

    ok(!defined $test->c->model('Recording')->get_by_id($edit->entity_id),
       'recording has been deleted');

    is($edit->status => $STATUS_FAILEDVOTE);
};

test 'Reject when in use' => sub {
    my $test = shift;

    my $edit = create_edit($test->c, privileges => $UNTRUSTED_FLAG);
    my $entity_id = $edit->entity_id;

    $test->c->sql->do(<<~"SQL");
        INSERT INTO track (id, gid, medium, artist_credit, name, recording, position, number)
        VALUES (1, '32b10778-137d-46bd-957d-2bef4435882f', 22,
                (SELECT id FROM artist_credit LIMIT 1),
                (SELECT name FROM recording LIMIT 1), $entity_id, 1, 1);
        SQL


    reject_edit($test->c, $edit);

    ok(defined $test->c->model('Recording')->get_by_id($edit->entity_id),
       'recording has not been deleted');

    is($edit->status => $STATUS_APPLIED,
       'has to apply add recording edits when the recording is in use');

    $test->c->model('EditNote')->load_for_edits($edit);
    is(scalar($edit->all_edit_notes), 1, 'has an edit note');
    is($edit->edit_notes->[0]->editor_id, $EDITOR_MODBOT, 'ModBot left an edit note');
};

test 'Edit properties' => sub {
    my $test = shift;

    my $edit = create_edit($test->c, privileges => $UNTRUSTED_FLAG);
    isa_ok($edit => 'MusicBrainz::Server::Edit::Recording::Create');

    cmp_set($edit->related_entities->{artist},
            [ 1 ],
            'Is related to artist #1');

    cmp_set($edit->related_entities->{recording},
            [ $edit->entity_id ],
            'Is related to the recording it created');

    my $recording = created_recording_ok($test->c, $edit->entity_id);
    is($recording->edits_pending, 1, 'has an edit pending');
};

sub create_edit {
    my ($c, %args) = @_;

    $c->model('Edit')->create(
        edit_type => $EDIT_RECORDING_CREATE,
        editor_id => 1,
        name => 'Standalone recording',
        artist_credit => {
            names => [{ artist => { id => 1 }, name => 'Test artist' }]
        },
        length => 12345,
        comment => 'Recording comment',
        %args,
    );
}

sub created_recording_ok {
    my ($c, $recording_id) = @_;

    my $recording = $c->model('Recording')->get_by_id($recording_id);
    $c->model('ArtistCredit')->load($recording);

    ok(defined $recording, 'created a recording');
    is($recording->name, 'Standalone recording', 'name');
    is($recording->artist_credit->name, 'Test artist');
    is($recording->artist_credit->names->[0]->artist_id, 1);
    is($recording->length, 12345);
    is($recording->comment, 'Recording comment');

    return $recording;
}

1;
