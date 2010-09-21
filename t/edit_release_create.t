use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Release::Create' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_CREATE );
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_database($c, '+releasestatus');
MusicBrainz::Server::Test->prepare_test_database($c, <<'SQL');
    SET client_min_messages TO warning;
    TRUNCATE release CASCADE;
SQL
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Release::Create');

ok(defined $edit->release_id);

my ($edits, $hits) = $c->model('Edit')->find({ release => $edit->release_id }, 10, 0);
is($edits->[0]->id, $edit->id);

my $release = $c->model('Release')->get_by_id($edit->release_id);
$c->model('ArtistCredit')->load($release);
ok(defined $release, 'Created Release');
is($release->name, 'Empty Release', '... with name');
is($release->comment => 'An empty release!', '... with comment');
is($release->artist_credit->names->[0]->name, 'Foo Foo', '... with artist name');
is($release->artist_credit->names->[0]->artist_id, 1, '... with artist id');
is($release->status_id, 1, '... with status');
is($release->edits_pending, 1, '... edit pending');

reject_edit($c, $edit);

$release = $c->model('Release')->get_by_id($edit->release_id);
ok(!defined $release);

$edit = create_edit();
accept_edit($c, $edit);

$release = $c->model('Release')->get_by_id($edit->release_id);
ok(defined $release);
is($release->edits_pending, 0);

done_testing;

sub create_edit
{
    return $c->model('Edit')->create(
        editor_id => 1,
        edit_type => $EDIT_RELEASE_CREATE,
        name => 'Empty Release',
        artist_credit => [
            { artist => 1, name => 'Foo Foo' }
        ],
        comment => 'An empty release!',
        status_id => 1,
        release_group_id => 1,
    );
}

