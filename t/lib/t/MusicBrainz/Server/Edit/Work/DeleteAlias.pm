package t::MusicBrainz::Server::Edit::Work::DeleteAlias;
use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Work::DeleteAlias }

use MusicBrainz::Server::Constants qw(
    $EDIT_WORK_DELETE_ALIAS
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test;

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+workalias');

my $alias = $c->model('Work')->alias->get_by_id(1);

my $edit = _create_edit($c, $alias, privileges => $UNTRUSTED_FLAG);
isa_ok($edit, 'MusicBrainz::Server::Edit::Work::DeleteAlias');

my ($edits) = $c->model('Edit')->find({ work => 1 }, 10, 0);
is(@$edits, 1);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
is($edit->display_data->{work}{id}, 1);
is($edit->display_data->{alias}, 'Alias 1');

$alias = $c->model('Work')->alias->get_by_id(1);
is($alias->edits_pending, 1);

my $work = $c->model('Work')->get_by_id(1);
is($work->edits_pending, 1);

my $alias_set = $c->model('Work')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

MusicBrainz::Server::Test::reject_edit($c, $edit);

$alias_set = $c->model('Work')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

$work = $c->model('Work')->get_by_id(1);
is($work->edits_pending, 0);

$alias = $c->model('Work')->alias->get_by_id(1);
ok(defined $alias);
is($alias->edits_pending, 0);

$edit = _create_edit($c, $alias);

$work = $c->model('Work')->get_by_id(1);
is($work->edits_pending, 0);

$alias = $c->model('Work')->alias->get_by_id(1);
ok(!defined $alias);

$alias_set = $c->model('Work')->alias->find_by_entity_id(1);
is(@$alias_set, 1);

};

sub _create_edit {
    my ($c, $alias, %args) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_WORK_DELETE_ALIAS,
        editor_id => 1,
        entity    => $c->model('Work')->get_by_id(1),
        alias     => $alias,
        %args,
    );
}

1;
