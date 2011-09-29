#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use List::MoreUtils qw( uniq );
use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_ISRCS );

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->sql->select_list_of_hashes(
        q{SELECT id, data FROM edit
           WHERE type = ?
             AND open_time < '2011-05-16'},
        $EDIT_RECORDING_ADD_ISRCS
    )
};

$c->sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    my @recordings = values %{ $c->model('Recording')->get_by_ids(
        map { $_->{recording}{id} } @{ $data->{isrcs} }
    ) } or next;

    my @releases = $c->model('Release')->find_by_recording(
        [ map { $_->id } @recordings ]
    );

    $c->model('ReleaseGroup')->load(@releases);
    my @release_groups = map { $_->release_group } @releases;
    $c->model('ArtistCredit')->load(@recordings, @releases,
                                    map { $_->release_group } @releases);

    for my $artist_id (uniq map { $_->artist_id } map { $_->artist_credit->all_names }
                           @releases, @release_groups, @recordings) {
        $c->sql->do('INSERT INTO edit_artist (edit, artist) VALUES (?, ?)', $edit->{id}, $artist_id);
    }

    for my $release_id (uniq map { $_->id } @releases) {
        $c->sql->do('INSERT INTO edit_release (edit, release) VALUES (?, ?)', $edit->{id}, $release_id);
    }

    for my $release_group_id (uniq map { $_->release_group_id } @releases) {
        $c->sql->do('INSERT INTO edit_release_group (edit, release_group) VALUES (?, ?)',
                    $edit->{id}, $release_group_id);
    }
}

$c->sql->commit;
