package MusicBrainz::Server::Data::Role::Art;

use Moose::Role;
use MusicBrainz::Server::Entity::Release;
use MusicBrainz::Server::Data::Utils qw( object_to_ids );
use MusicBrainz::Server::Validation qw( is_database_bigint_id );
use namespace::autoclean;

requires qw( art_archive_model );

sub _table {
    my $self = shift;

    return $self->art_archive_model->art_table . ' ' .
        'JOIN cover_art_archive.image_type USING (mime_type)';
}

sub _columns {
    my $self = shift;

    my $art_archive_model = $self->art_archive_model;
    my $art_table = $art_archive_model->art_table;

    return join(q(, ), (map {
            "$art_table.$_"
        } (
            'id',
            $art_archive_model->art_archive_entity,
            qw( comment edit ordering edits_pending mime_type ),
        )),
        'cover_art_archive.image_type.suffix',
    );
}

sub _id_column {
    my $self = shift;
    return $self->art_archive_model->art_table . '.id';
}

sub is_valid_id {
    (undef, my $id) = @_;
    is_database_bigint_id($id);
}

sub _column_mapping {
    my $self = shift;

    my $art_archive_model = $self->art_archive_model;
    my $entity_type = $art_archive_model->art_archive_entity;

    return {
        id => 'id',
        comment => 'comment',
        edit_id => 'edit',
        ordering => 'ordering',
        edits_pending => 'edits_pending',
        approved => 'approved',
        suffix => 'suffix',
        mime_type => 'mime_type',
        "${entity_type}_id" => $entity_type,
        map {
            $_ => $_
        } $art_archive_model->art_archive_type_booleans,
    };
}

sub find_by_entity {
    my ($self, $entities, %opts) = @_;

    my %id_to_entity = object_to_ids(@$entities);
    my @ids = keys %id_to_entity;

    return unless @ids; # nothing to do

    my $art_archive_model = $self->art_archive_model;
    my $archive = $art_archive_model->art_archive_name;
    my $art_schema = "${archive}_art_archive";
    my $art_table = "${archive}_art";
    my $entity_type = $art_archive_model->art_archive_entity;

    my $type_booleans = join(q(, ), map {
        "$art_schema.index_listing.$_"
    } $art_archive_model->art_archive_type_booleans);

    my $extra_conditions = '';
    if ($opts{is_front}) {
        $extra_conditions .= 'AND is_front = TRUE';
    }

    my $query = <<~"SQL";
          SELECT $art_schema.index_listing.id,
                 $art_schema.index_listing.$entity_type,
                 $art_schema.index_listing.comment,
                 $art_schema.index_listing.edit,
                 $art_schema.index_listing.ordering,
                 $art_schema.$art_table.edits_pending,
                 $art_schema.index_listing.approved,
                 $type_booleans,
                 cover_art_archive.image_type.mime_type,
                 cover_art_archive.image_type.suffix
            FROM $art_schema.index_listing
            JOIN $art_schema.$art_table
              ON $art_schema.$art_table.id = $art_schema.index_listing.id
            JOIN cover_art_archive.image_type
              ON $art_schema.index_listing.mime_type =
                    cover_art_archive.image_type.mime_type
           WHERE $art_schema.index_listing.$entity_type = any(?)
        $extra_conditions
        ORDER BY $art_schema.index_listing.ordering
        SQL

    my @artwork = $self->query_to_list($query, [\@ids]);
    my $entity_id_attribute = "${entity_type}_id";
    for my $image (@artwork) {
        $image->$entity_type($id_to_entity{ $image->$entity_id_attribute }[0]);
    }

    return \@artwork;
}

sub find_front_artwork_by_entity {
    my ($self, $entities) = @_;

    return $self->find_by_entity($entities, is_front => 1);
}

sub find_count_by_entity {
    my ($self, $entity_id) = @_;

    return unless $entity_id; # nothing to do

    my $art_archive_model = $self->art_archive_model;
    my $archive = $art_archive_model->art_archive_name;
    my $art_schema = "${archive}_art_archive";
    my $entity_type = $art_archive_model->art_archive_entity;

    my $query = <<~"SQL";
        SELECT count(*)
          FROM $art_schema.index_listing
         WHERE $art_schema.index_listing.$entity_type = ?
        SQL

    return $self->sql->select_single_value($query, $entity_id);
}

sub mime_types {
    my $self = shift;

    return $self->c->sql->select_list_of_hashes(<<~'SQL');
        SELECT mime_type, suffix FROM cover_art_archive.image_type
        SQL
}

sub image_type_suffix {
    my ($self, $mime_type) = @_;

    return $self->c->sql->select_single_value(<<~'SQL', $mime_type);
        SELECT suffix FROM cover_art_archive.image_type WHERE mime_type = ?
        SQL
}

no Moose::Role;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
