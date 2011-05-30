#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../../../lib";

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants
    qw( $EDIT_RELATIONSHIP_CREATE
        $EDIT_RELATIONSHIP_EDIT
        $EDIT_RELATIONSHIP_DELETE );
use MusicBrainz::Server::Data::Utils qw( type_to_model );

my $c = MusicBrainz::Server::Context->create_script_context;

$c->raw_sql->begin;

my @new_links = ();
for my $type (qw( recording release release_group )) {
    my @expand = @{
        $c->raw_sql->select_list_of_lists(
            "SELECT id, $type
               FROM edit
               JOIN edit_$type ON edit = edit.id
              WHERE type IN (?, ?, ?)",
            $EDIT_RELATIONSHIP_CREATE,
            $EDIT_RELATIONSHIP_EDIT,
            $EDIT_RELATIONSHIP_DELETE
        )
    };

    my @ids = map { $_->[1] } @expand;
    my %entities = %{ $c->model(type_to_model($type))->get_by_ids(@ids) };
    $c->model('ArtistCredit')->load(values %entities);

    for my $row (@expand) {
        my $entity = $entities{ $row->[1] } or next;
        push @new_links,
            map { [$row->[0],$_->artist_id] }
                @{ $entity->artist_credit->names }
    }
};

die "Something has gone wrong" unless @new_links;

$c->raw_sql->do(
    "INSERT INTO edit_artist (edit, artist)
         SELECT DISTINCT to_insert.edit, to_insert.entity
           FROM (VALUES " . join(', ', ('(?::int, ?::int)') x @new_links) . ") to_insert (edit, entity)
      LEFT JOIN edit_artist ON (edit_artist.edit = to_insert.edit AND edit_artist.artist = to_insert.entity)
          WHERE edit_artist.edit IS NULL",
    map { @$_ } @new_links
);

$c->raw_sql->commit;
