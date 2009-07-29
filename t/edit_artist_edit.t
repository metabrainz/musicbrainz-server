#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 12;

BEGIN { use_ok 'MusicBrainz::Server::Edit::Artist::Edit' }
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_EDIT );
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Test;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_raw_test_database($c);

my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $c);
my $edit_data = MusicBrainz::Server::Data::Edit->new(c => $c);

my $artist = $artist_data->get_by_id(3);
my $edit = $edit_data->create(
    edit_type => $EDIT_ARTIST_EDIT,
    artist => $artist,
    name => 'New Test Artist',
    comment => 'Amazing comment',
    editor_id => 2
);

is_deeply($edit->artist, $artist);
is_deeply($edit->data, {
    artist => $artist->id,
    new => {
        name => 'New Test Artist',
        comment => 'Amazing comment',
    },
    old => {
        name => $artist->name,
        comment => $artist->comment,
    }
});

is($edit->entity_model, 'Artist');
is($edit->entity_id, $artist->id);
is_deeply($edit->entities, { artist => [ $artist->id ] });

$artist = $artist_data->get_by_id($artist->id);
is($artist->edits_pending, 1);

$edit_data->accept($edit);
my $artist2 = $artist_data->get_by_id($artist->id);
is($artist2->name, 'New Test Artist');
is($artist2->comment, 'Amazing comment');
is($artist2->country, $artist->country);
is($artist2->sort_name, $artist->sort_name);
is($artist2->edits_pending, 0);
