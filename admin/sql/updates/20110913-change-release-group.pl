#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";


use JSON::Any;
use List::UtilsBy qw( uniq_by );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MOVE );
use Try::Tiny;

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->sql->select_list_of_hashes(
        q{SELECT id, data, release
            FROM edit
            JOIN edit_release ON edit = id
           WHERE type = ?
             AND open_time >= '2011-05-16'},
        $EDIT_RELEASE_MOVE
    )
};

$c->sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    my $release = $c->model('Release')->get_by_id($edit->{release});
    my @groups = values %{ $c->model('Release')->get_by_ids($data->{old_release_group}{id},
                                                            $data->{new_release_group}{id}) };

    $c->model('ArtistCredit')->load($release, @groups);

    for my $artist (uniq_by { $_->artist_id } map { $_->artist_credit->all_names } $release, @groups) {
        $c->sql->do('INSERT INTO edit_artist (edit, artist) VALUES (?, ?)', $edit->{id}, $artist->artist_id);
    }

    # Try catch these because the release group might no longer exist (but if so, we don't really mind)
    try {
        $c->sql->do('SAVEPOINT old_release_group');
        $c->sql->do('INSERT INTO edit_release_group (edit, release_group) VALUES (?, ?)',
                    $edit->{id}, $data->{old_release_group}{id});
    }
    catch {
        $c->sql->do('ROLLBACK TO SAVEPOINT old_release_group');
    }
    finally {
        $c->sql->do('RELEASE SAVEPOINT old_release_group');
    };

    try {
        $c->sql->do('SAVEPOINT new_release_group');
        $c->sql->do('INSERT INTO edit_release_group (edit, release_group) VALUES (?, ?)',
                    $edit->{id}, $data->{new_release_group}{id});
    }
    catch {
        $c->sql->do('ROLLBACK TO SAVEPOINT new_release_group');
    }
    finally {
        $c->sql->do('RELEASE SAVEPOINT new_release_group');
    };
}

$c->sql->commit;
