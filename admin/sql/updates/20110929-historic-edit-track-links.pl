#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use List::MoreUtils qw( uniq );
use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_EDIT_TRACKNAME
    $EDIT_HISTORIC_EDIT_TRACK_LENGTH
    $EDIT_HISTORIC_EDIT_TRACKNUM
);

my $c = MusicBrainz::Server::Context->create_script_context;

printf STDERR "Finding edits to relink...\n";
my @to_fix = @{
    $c->sql->select_list_of_hashes(
        q{SELECT id, data, type FROM edit
           WHERE type = any(?)
             AND open_time < '2011-05-16'},
        [ $EDIT_HISTORIC_EDIT_TRACKNAME,
          $EDIT_HISTORIC_EDIT_TRACK_LENGTH,
          $EDIT_HISTORIC_EDIT_TRACKNUM ]
    )
};

my $json = JSON::Any->new( utf8 => 1 );

my $i = 0;
printf STDERR "Relinking...\n";
for my $edit (@to_fix) {
    $c->sql->begin;
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    my $recording = $c->model('Recording')->get_by_id(
        $data->{recording_id}
    ) or next;

    my @releases = $c->model('Release')->find_by_recording(
        [ $recording->id ]
    );

    $c->model('ReleaseGroup')->load(@releases);
    my @release_groups = map { $_->release_group } @releases;
    $c->model('ArtistCredit')->load($recording, @releases,
                                    map { $_->release_group } @releases);

    for my $artist_id (uniq map { $_->artist_id } map { $_->artist_credit->all_names }
                           @releases, @release_groups, $recording) {
        $c->sql->do('INSERT INTO edit_artist (edit, artist) VALUES (?, ?)', $edit->{id}, $artist_id);
    }

    # EditTrackNum already does this
    unless ($edit->{type} == $EDIT_HISTORIC_EDIT_TRACKNUM) {
        for my $release_id (uniq map { $_->id } @releases) {
            $c->sql->do('INSERT INTO edit_release (edit, release) VALUES (?, ?)', $edit->{id}, $release_id);
        }
    }

    for my $release_group_id (uniq map { $_->release_group_id } @releases) {
        $c->sql->do('INSERT INTO edit_release_group (edit, release_group) VALUES (?, ?)',
                    $edit->{id}, $release_group_id);
    }

    # Everything *but* EditTrackNum already does this
    if ($edit->{type} == $EDIT_HISTORIC_EDIT_TRACKNUM) {
        $c->sql->do('INSERT INTO edit_recording (edit, recording) VALUES (?, ?)',
                    $edit->{id}, $recording->id);
    }

    printf STDERR "\r%d/%d", $i++, scalar(@to_fix);
    $c->sql->commit;
}

