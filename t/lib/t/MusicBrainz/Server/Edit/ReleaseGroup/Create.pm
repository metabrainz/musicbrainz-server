package t::MusicBrainz::Server::Edit::ReleaseGroup::Create;
use Test::Routine;
use Test::More;

with 't::Context';

BEGIN { use MusicBrainz::Server::Edit::ReleaseGroup::Create }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASEGROUP_CREATE );
use MusicBrainz::Server::Constants qw( :edit_status );

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
    SET client_min_messages TO warning;
    SET CONSTRAINTS ALL IMMEDIATE;
    TRUNCATE release_group CASCADE;
    SQL

my $edit = create_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::Create');

ok(defined $edit->release_group_id);

my ($edits, undef) = $c->model('Edit')->find({ release_group => $edit->release_group_id }, 10, 0);
is($edits->[0]->id, $edit->id);

my $rg = $c->model('ReleaseGroup')->get_by_id($edit->release_group_id);
$c->model('ArtistCredit')->load($rg);
ok(defined $rg);
is($rg->name, 'Empty Release Group');
is($rg->comment => 'An empty release group!');
is($rg->artist_credit->names->[0]->name, 'Foo Foo');
is($rg->artist_credit->names->[0]->artist_id, 1);
is($rg->primary_type_id, 1);

is($edit->status, $STATUS_APPLIED, 'add release group edits should be autoedits');
is($rg->edits_pending, 0);

};

sub create_edit
{
    my $c = shift;
    return $c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_RELEASEGROUP_CREATE,
        name => 'Empty Release Group',
        artist_credit => {
            names => [
                { artist => { id => 1, name => 'Bar Bar'}, name => 'Foo Foo' }
            ],
        },
        comment => 'An empty release group!',
        primary_type_id => 1
    );
}

1;
