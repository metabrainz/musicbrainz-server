#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use JSON::Any;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MOVE_DISCID );
use Try::Tiny;

my $c = MusicBrainz::Server::Context->create_script_context;

my @to_fix = @{
    $c->sql->select_list_of_hashes(
        q{SELECT edit.id, data, prevvalue AS album_id
            FROM edit
            JOIN public.moderation_closed mod ON (mod.id = edit.id)
           WHERE edit.type = ?},
        $EDIT_HISTORIC_MOVE_DISCID
    )
};

$c->sql->begin;

my $json = JSON::Any->new( utf8 => 1 );

for my $edit (@to_fix) {
    my $data = $edit->{data} = $json->jsonToObj($edit->{data});

    $data->{release_ids} = $c->model('EditMigration')->album_release_ids($edit->{album_id});

    # Relink edits. Keep all existing links, and try and compliment that set with the old
    # release links. The old releases might have been merged, and sadly in this case we will
    # have lost a link.
    for my $release_id (@{ $data->{release_ids} }) {
        try {
            $c->sql->do('SAVEPOINT release_link');
            $c->sql->do('INSERT INTO edit_release (edit, release) VALUES (?, ?)',
                        $edit->{id}, $release_id);
        }
        catch {
            $c->sql->do('ROLLBACK TO SAVEPOINT release_link');
        }
        finally {
            $c->sql->do('RELEASE SAVEPOINT release_link');
        };
    }

    $c->sql->do(
        'UPDATE edit SET data = ? WHERE id = ?',
        $json->objToJson($data), $edit->{id}
    );
}

$c->sql->commit;
