package t::MusicBrainz::Server::Edit::Artist::AddAlias;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Edit';
with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::Artist::AddAlias }

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_ADD_ALIAS );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+artistalias');

my $alias_set = $c->model('Artist')->alias->find_by_entity_id(1);
is(@$alias_set, 2);

my $edit = _create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::AddAlias');
ok(defined $edit->alias_id);
ok($edit->alias_id > 0);

my ($edits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
is(@$edits, 1);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
is($edit->display_data->{artist}{id}, 1);
is($edit->display_data->{alias}, 'Another alias');

my $artist = $c->model('Artist')->get_by_id(1);
is($artist->edits_pending, 0, 'Alias addition was an autoedit');

$alias_set = $c->model('Artist')->alias->find_by_entity_id(1);
is(@$alias_set, 3);

};

sub _create_edit {
    my $c = shift;
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_ADD_ALIAS,
        editor_id => 1,
        entity    => $c->model('Artist')->get_by_id(1),
        name => 'Another alias',
        sort_name => 'Another alias sort name',
        primary_for_locale => 0,
        ended => 0
    );
}

1;
