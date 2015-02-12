package t::MusicBrainz::Server::Edit::Relationship::Delete;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Relationship::Delete }

use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_DELETE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );
use MusicBrainz::Server::Constants qw( $AUTO_EDITOR_FLAG );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+edit_relationship_delete');

subtest 'Test edit creation/rejection' => sub {
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    is($rel->edits_pending, 0);

    my $edit = _create_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Relationship::Delete');

    my ($edits, $hits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
    is($hits, 1);
    is($edits->[0]->id, $edit->id);

    ($edits, $hits) = $c->model('Edit')->find({ artist => 2 }, 10, 0);
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
    my $edit = _create_edit($c, privileges => $AUTO_EDITOR_FLAG);
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    ok(defined $rel, 'relationship should still exist');
    is($rel->edits_pending, 1, 'relationship should have an edit pending');
};

subtest 'Test edit acception' => sub {
    # Test accepting the edit
    my $edit = _create_edit($c);
    accept_edit($c, $edit);
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    ok(!defined $rel);
};

};

sub _create_edit {
    my $c = shift;
    my $rel = $c->model('Relationship')->get_by_id('artist', 'artist', 1);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);

    return $c->model('Edit')->create(
        edit_type => $EDIT_RELATIONSHIP_DELETE,
        editor_id => 1,
        type0 => 'artist',
        type1 => 'artist',
        relationship => $rel,
        @_
    );
}

1;
