#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Artist::Delete' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_DELETE );
use MusicBrainz::Server::Types ':edit_status';
use MusicBrainz::Server::Test qw( accept_edit reject_edit );

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+edit_artist_delete');
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = _create_edit();
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Delete');

my ($edits, $hits) = $c->model('Edit')->find({ artist => 1 }, 10, 0);
is($hits, 1);
is($edits->[0]->id, $edit->id);

my $artist = $c->model('Artist')->get_by_id(1);
is($artist->edits_pending, 1);

# Test rejecting the edit
reject_edit($c, $edit);
$artist = $c->model('Artist')->get_by_id(1);
ok(defined $artist);
is($artist->edits_pending, 0);

# Test accepting the edit
# This should fail as the artist has a recording linked
$edit = _create_edit();
accept_edit($c, $edit);
$artist = $c->model('Artist')->get_by_id(1);
is($edit->status, $STATUS_FAILEDDEP);
ok(defined $artist);

# Delete the recording and enter the edit
my $sql = Sql->new($c->dbh);
my $sql_raw = Sql->new($c->raw_dbh);
Sql::run_in_transaction(
    sub {
        my $recording = $c->model('Recording')->get_by_id(1);
        $c->model('Recording')->delete($recording);
    }, $sql, $sql_raw);

$edit = _create_edit();
accept_edit($c, $edit);
$artist = $c->model('Artist')->get_by_id(1);
ok(!defined $artist);

done_testing;

sub _create_edit {
    return $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_DELETE,
        artist_id => 1,
        editor_id => 1
    );
}

