#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 15;

BEGIN {
    use_ok 'MusicBrainz::Server::Edit::Artist::Create';
    use_ok 'MusicBrainz::Server::Data::Edit';
}

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_CREATE );
use MusicBrainz::Server::Types qw( $STATUS_APPLIED );
use MusicBrainz::Server::Test;
use Sql;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $c);
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);

my $sql_raw = Sql->new($c->raw_dbh);
my $sql = Sql->new($c->dbh);
$sql->Begin;
$sql_raw->Begin;

my $edit = $edit_data->create(
    edit_type => $EDIT_ARTIST_CREATE,
    name => 'Junior Boys',
    gender => 1,
    comment => 'Canadian electronica duo',
    editor_id => 1
);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Create');
is_deeply($edit->entities, { artist => [ $edit->artist_id ] });
is($edit->entity_model, 'Artist');
is($edit->entity_id, $edit->artist_id);
is($edit->status, $STATUS_APPLIED);

ok(defined $edit->artist_id);
ok(defined $edit->id);
is_deeply($edit->to_hash, {
        name => 'Junior Boys',
        gender => 1,
        comment => 'Canadian electronica duo',
        artist_id => $edit->artist_id,
    });

$artist_data->load($edit);
my $artist = $edit->artist;
ok(defined $artist);
is($artist->name, 'Junior Boys');
is($artist->gender_id, 1);
is($artist->comment, 'Canadian electronica duo');
is($artist->edits_pending, 0);

$sql->Commit;
$sql_raw->Commit;
