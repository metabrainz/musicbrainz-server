package t::MusicBrainz::Server::Edit::Artist::DeleteAlias;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::DeleteAlias }

use MusicBrainz::Server::Constants qw(
    $EDIT_ARTIST_DELETE_ALIAS
    $STATUS_APPLIED
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test;

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');

my $alias = $c->model('Artist')->alias->get_by_id(1);

my $edit = _create_edit($c, $alias, privileges => $UNTRUSTED_FLAG);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::DeleteAlias');

my ($edits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
is(@$edits, 1);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
is($edit->display_data->{artist}{id}, 1);
is($edit->display_data->{alias}, 'Alias 1');
is($edit->display_data->{begin_date}{year}, 2000);
is($edit->display_data->{begin_date}{month}, 1);
is($edit->display_data->{begin_date}{day}, 2);
is($edit->display_data->{end_date}{year}, 2003);
is($edit->display_data->{end_date}{month}, 4);
is($edit->display_data->{end_date}{day}, 5);

$alias = $c->model('Artist')->alias->get_by_id(1);
is($alias->edits_pending, 1);

my $artist = $c->model('Artist')->get_by_id(1);
is($artist->edits_pending, 1);

my $alias_set = $c->model('Artist')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

MusicBrainz::Server::Test::reject_edit($c, $edit);

$alias_set = $c->model('Artist')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

$artist = $c->model('Artist')->get_by_id(1);
is($artist->edits_pending, 0);

$alias = $c->model('Artist')->alias->get_by_id(1);
ok(defined $alias);
is($alias->edits_pending, 0);

$edit = _create_edit($c, $alias);

$artist = $c->model('Artist')->get_by_id(1);
is($artist->edits_pending, 0);

$alias = $c->model('Artist')->alias->get_by_id(1);
ok(!defined $alias);

$alias_set = $c->model('Artist')->alias->find_by_entity_id(1);
is(@$alias_set, 1);

};

test 'Always an auto-edit (MBS-8388)' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');

    my $alias = $c->model('Artist')->alias->get_by_id(1);

    my $edit = _create_edit($c, $alias);

    ok(!$edit->is_open);
    is($edit->status, $STATUS_APPLIED);
};

sub _create_edit {
    my ($c, $alias, @args) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_DELETE_ALIAS,
        editor_id => 1,
        entity    => $c->model('Artist')->get_by_id(1),
        alias     => $alias,
        @args
    );
}


1;
