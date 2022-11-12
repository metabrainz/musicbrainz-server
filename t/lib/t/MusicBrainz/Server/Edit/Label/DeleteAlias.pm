package t::MusicBrainz::Server::Edit::Label::DeleteAlias;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Label::DeleteAlias }

use MusicBrainz::Server::Constants qw(
    $EDIT_LABEL_DELETE_ALIAS
    $UNTRUSTED_FLAG
);
use MusicBrainz::Server::Test;

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+labelalias');

my $alias = $c->model('Label')->alias->get_by_id(1);

my $edit = _create_edit($c, $alias, privileges => $UNTRUSTED_FLAG);
isa_ok($edit, 'MusicBrainz::Server::Edit::Label::DeleteAlias');

my ($edits) = $c->model('Edit')->find({ label => 1 }, 10, 0);
is(@$edits, 1);
is($edits->[0]->id, $edit->id);

my $label = $c->model('Label')->get_by_id(1);
is($label->edits_pending, 1);

$alias = $c->model('Label')->alias->get_by_id(1);
is($alias->edits_pending, 1);

$c->model('Edit')->load_all($edit);
is($edit->display_data->{label}{id}, 1);
is($edit->display_data->{alias}, 'Alias 1');

my $alias_set = $c->model('Label')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

MusicBrainz::Server::Test::reject_edit($c, $edit);

$alias_set = $c->model('Label')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

$label = $c->model('Label')->get_by_id(1);
is($label->edits_pending, 0);

$alias = $c->model('Label')->alias->get_by_id(1);
ok(defined $alias);
is($alias->edits_pending, 0);

$edit = _create_edit($c, $alias);

$label = $c->model('Label')->get_by_id(1);
is($label->edits_pending, 0);

$alias = $c->model('Label')->alias->get_by_id(1);
ok(!defined $alias);

$alias_set = $c->model('Label')->alias->find_by_entity_id(1);
is(@$alias_set, 1);

};

sub _create_edit {
    my ($c, $alias, %args) = @_;
    return $c->model('Edit')->create(
        edit_type => $EDIT_LABEL_DELETE_ALIAS,
        editor_id => 1,
        entity    => $c->model('Label')->get_by_id(1),
        alias     => $alias,
        %args,
    );
}

1;
