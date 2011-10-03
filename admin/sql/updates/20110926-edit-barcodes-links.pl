#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use List::MoreUtils qw( uniq );
use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT_BARCODES );
use Try::Tiny;

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->sql->select_list_of_hashes(
        q{SELECT id, data
            FROM edit
           WHERE type = ?},
        $EDIT_RELEASE_EDIT_BARCODES
    )
};

$c->sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    my @releases = values %{
        $c->model('Release')->get_by_ids(
            map { $_->{release}{id} } @{ $data->{submissions} }
        )
    };

    $c->model('ReleaseGroup')->load(@releases);
    $c->model('ArtistCredit')->load(@releases, map { $_->release_group } @releases);

    for my $artist_id (
        uniq map { $_->artist_id } map { $_->all_names }
            map {
                $_->release_group->artist_credit,
                $_->artist_credit
            } @releases)
    {
        $c->sql->do('INSERT INTO edit_artist (edit, artist) VALUES (?, ?)',
                    $edit->{id}, $artist_id);
    }

    for my $release_group_id (uniq map { $_->release_group_id } @releases) {
        $c->sql->do('INSERT INTO edit_release_group (edit, release_group) VALUES (?, ?)',
                    $edit->{id}, $release_group_id);
    }
}

$c->sql->commit;
