#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Artist::Create' }

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_CREATE );
use MusicBrainz::Server::Types qw( $STATUS_APPLIED );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+gender');
MusicBrainz::Server::Test->prepare_test_database($c, <<'SQL');
    SET client_min_messages TO warning;
    TRUNCATE artist CASCADE;
SQL
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $edit = $c->model('Edit')->create(
    edit_type => $EDIT_ARTIST_CREATE,
    name => 'Junior Boys',
    gender_id => 1,
    comment => 'Canadian electronica duo',
    editor_id => 1
);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Create');
is($edit->status, $STATUS_APPLIED, 'edit should automatically be applied');

ok(defined $edit->artist_id, 'edit should store the artist id');

my ($edits, $hits) = $c->model('Edit')->find({ artist => $edit->artist_id }, 0, 10);
is($edits->[0]->id, $edit->id);

$c->model('Edit')->load_all($edit);
my $artist = $edit->artist;
ok(defined $artist);
is($artist->name, 'Junior Boys');
is($artist->gender_id, 1);
is($artist->comment, 'Canadian electronica duo');
is($artist->edits_pending, 0);

done_testing;
