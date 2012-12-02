#!/usr/bin/perl
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_REMOVE_COVER_ART $EDITOR_MODBOT );
use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->create_script_context;

for my $row (@{
    $c->sql->select_list_of_hashes(
        'SELECT * FROM cover_art_archive.cover_art
         WHERE round(id/10000000) > 300'
    )
}) {
    Sql::run_in_transaction(sub {
        my ($artwork) = grep { $_->id == $row->{id} }
            $c->model('CoverArtArchive')->find_available_artwork($row->{release});

        my $release = $c->model('Release')->get_by_id( $row->{release} );

        if ($artwork && $release) {
            my $edit = $c->model('Edit')->create(
                edit_type => $EDIT_RELEASE_REMOVE_COVER_ART,
                editor_id => $EDITOR_MODBOT,

                release => $release,
                to_delete => $artwork
            );

            $c->model('EditNote')->add_note(
                $edit->id,
                {
                    editor_id => $EDITOR_MODBOT,
                    text => 'This cover art uses an image ID outside the expected range and must be deleted'
                }
            );

            $c->model('Edit')->accept($edit);
        }
        else {
            warn sprintf('Could not delete image %d\n', $row->{id});
        }
    }, $c->sql);
}
