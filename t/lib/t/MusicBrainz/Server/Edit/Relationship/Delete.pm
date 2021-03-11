package t::MusicBrainz::Server::Edit::Relationship::Delete;
use Test::Routine;
use Test::More;
use Test::Fatal;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Relationship::Delete }

use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_CREATE $EDIT_RELATIONSHIP_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );
use MusicBrainz::Server::Constants qw( $AUTO_EDITOR_FLAG $STATUS_APPLIED );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_delete');

subtest 'Test edit creation/rejection' => sub {
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    is($rel->edits_pending, 0);

    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'artist',
        relationship => _get_relationship($c, 'artist', 'artist', 1),
    );

    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Delete');

    my ($edits, $hits) = $c->model('Edit')->find({ artist => 3 }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    ($edits, $hits) = $c->model('Edit')->find({ artist => 4 }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    is($rel->edits_pending, 1);

    # Test rejecting the edit
    reject_edit($c, $edit);

    $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    ok(defined $rel);
    is($rel->edits_pending, 0);
};

subtest 'Creating as an auto-editor still requires voting' => sub {
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'artist',
        relationship => _get_relationship($c, 'artist', 'artist', 1),
        privileges => $AUTO_EDITOR_FLAG,
    );
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    ok(defined $rel, 'relationship should still exist');
    is($rel->edits_pending, 1, 'relationship should have an edit pending');
};

subtest 'Test edit acception' => sub {
    # Test accepting the edit
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'artist',
        relationship => _get_relationship($c, 'artist', 'artist', 1),
    );
    accept_edit($c, $edit);
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    ok(!defined $rel);
};

};

test 'Removing URLs is an auto-edit for auto-editors (MBS-8332)' => sub {
    my ($test) = @_;

    my $c = $test->c;
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_delete');

    my $editor = $c->model('Editor')->get_by_id(1);

    my $relationship = _get_relationship($c, 'artist', 'url', 1);
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor => $editor,
        type0 => 'artist',
        type1 => 'url',
        relationship => $relationship,
        privileges => $editor->privileges,
    );

    ok($edit->is_open);
    reject_edit($c, $edit);

    $c->model('Editor')->update_privileges($editor, {auto_editor => 1});
    $editor = $c->model('Editor')->get_by_id(1);

    $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor => $editor,
        type0 => 'artist',
        type1 => 'url',
        relationship => $relationship,
        privileges => $editor->privileges,
    );

    is($edit->status, $STATUS_APPLIED);
};

test 'Entities load correctly after being merged (MBS-2477)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_delete');

    my $relationship = _get_relationship($c, 'artist', 'url', 1);
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor => $c->model('Editor')->get_by_id(1),
        type0 => 'artist',
        type1 => 'url',
        relationship => $relationship,
    );

    $c->model('Artist')->merge(4, [3]);
    $c->model('Edit')->load_all($edit);

    is($edit->display_data->{relationship}{entity0_id}, 4);
};

test 'Deleting a release-url relationship' => sub {
    my $test = shift;
    my $c = $test->c;

    # Release-url relationships have special logic for caching cover artwork.
    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_delete');

    my $relationship = _get_relationship($c, 'release', 'url', 1);
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor => $c->model('Editor')->get_by_id(1),
        type0 => 'release',
        type1 => 'url',
        relationship => $relationship,
    );

    $c->model('Edit')->accept($edit);
    is($edit->status, $STATUS_APPLIED);
};

test 'Deleting an example relationship fails' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_delete');

    my $relationship = _get_relationship($c, 'artist', 'url', 2);
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor => $c->model('Editor')->get_by_id(1),
        type0 => 'artist',
        type1 => 'url',
        relationship => $relationship,
    );

    my $exception = exception { $edit->accept };

    isa_ok $exception, 'MusicBrainz::Server::Edit::Exceptions::GeneralError';
    like $exception->message, qr{would remove a relationship that is set as an example},
        'Error message mentions removing an example';
};

sub _get_relationship {
    my ($c, $type0, $type1, $id) = @_;

    my $rel = $c->model('Relationship')->get_by_id($type0, $type1, $id);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);
    return $rel;
}

1;
