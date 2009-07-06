#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 11;

BEGIN {
    use_ok 'MusicBrainz::Server::Edit::Artist::Merge';
    use_ok 'MusicBrainz::Server::Data::Edit';
}

use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);

my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $c);
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);

my $edit = $edit_data->create(
    edit_type => $EDIT_ARTIST_MERGE,
    editor_id => 1,
    old_artist_id => 4,
    new_artist_id => 3,
);
isa_ok($edit, 'MusicBrainz::Server::Edit::Artist::Merge');
is_deeply($edit->entities, { artist => [ 4, 3 ]});
is_deeply($edit->entity_id, [ 4, 3 ]);
is($edit->entity_model, 'Artist');

my $artist = $artist_data->get_by_id(4);
is($artist->edits_pending, 1);

$artist = $artist_data->get_by_id(3);
is($artist->edits_pending, 1);

$edit_data->accept($edit);

$artist = $artist_data->get_by_id(4);
ok(!defined $artist);

$artist = $artist_data->get_by_id(3);
ok(defined $artist);
is($artist->edits_pending, 0);
