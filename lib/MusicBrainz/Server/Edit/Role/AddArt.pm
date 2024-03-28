package MusicBrainz::Server::Edit::Role::AddArt;
use Moose::Role;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Edit::Role::Art';

requires qw(
    art_archive_model
    edit_name
    edit_template
    edit_type
);

sub data_fields {
    my $archive = shift;
    return Dict[
        entity => Dict[
            id => Int,
            name => Str,
            mbid => Str,
        ],
        "${archive}_art_types" => ArrayRef[Int],
        "${archive}_art_position" => Int,
        "${archive}_art_id" => Int,
        "${archive}_art_comment" => Str,
        "${archive}_art_mime_type" => Str,
    ];
}

sub edit_kind { 'add' }

# The order here is significant w.r.t. `insert_art`.
our @art_field_names = qw( id position types comment mime_type );

sub entity_ids { shift->data->{entity}{id} }

sub art_ids {
    my $self = shift;

    my $archive = $self->art_archive_model->art_archive_name;
    return $self->data->{"${archive}_art_id"};
}

sub initialize {
    my ($self, %opts) = @_;

    my $entity = $opts{ $self->art_archive_model->art_archive_entity }
        or die 'Entity missing';
    my $archive = $self->art_archive_model->art_archive_name;

    $self->data({
        entity => {
            id => $entity->id,
            name => $entity->name,
            mbid => $entity->gid,
        },
        map { $_ => $opts{$_} }
        map { "${archive}_art_$_" }
        @art_field_names,
    });
}

sub accept {
    my $self = shift;

    my $art_archive_model = $self->art_archive_model;
    my $entity_type = $art_archive_model->art_archive_entity;
    $art_archive_model->entity_model->get_by_gid($self->data->{entity}{mbid})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            "This $entity_type no longer exists",
        );
}

sub post_insert {
    my $self = shift;

    my $art_archive_model = $self->art_archive_model;
    my $entity = $art_archive_model->entity_model->get_by_gid(
        $self->data->{entity}{mbid},
    );
    my $archive = $art_archive_model->art_archive_name;

    # Mark that we now have art for this entity.
    $art_archive_model->insert_art(
        $entity->id,
        $self->id,
        map { $self->data->{$_} }
        map { "${archive}_art_$_" }
        @art_field_names,
    );
}

sub reject {
    my $self = shift;

    my $archive = $self->art_archive_model->art_archive_name;

    # Remove the pending stuff
    $self->art_archive_model->delete($self->data->{"${archive}_art_id"});
}

sub foreign_keys {
    my ($self) = @_;

    my $art_archive_model = $self->art_archive_model;
    my $entity_model_name = $art_archive_model->entity_model_name;
    my $art_type_model_name = $art_archive_model->art_type_model_name;
    my $archive = $art_archive_model->art_archive_name;

    my $entity_properties =
        $ENTITIES{ $art_archive_model->art_archive_entity };
    return {
        $entity_model_name => {
            $self->data->{entity}{id} => [
                $entity_properties->{artist_credits}
                    ? 'ArtistCredit'
                    : (),
            ],
        },
        $art_type_model_name => $self->data->{"${archive}_art_types"},
    };
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $data = $self->data;
    my $art_archive_model = $self->art_archive_model;
    my $entity_type = $art_archive_model->art_archive_entity;
    my $entity_class = $art_archive_model->entity_model->_entity_class;
    my $entity_id = $data->{entity}{id};
    my $loaded_entity =
        $loaded->{ $art_archive_model->entity_model_name }{$entity_id};
    my $archive = $art_archive_model->art_archive_name;
    my $mime_type_field = "${archive}_art_mime_type";
    my $suffix = $data->{$mime_type_field}
        ? $art_archive_model->image_type_suffix($data->{$mime_type_field})
        : 'jpg';

    return {
        $entity_type => to_json_object($loaded_entity || $entity_class->new(
            id => $entity_id,
            name => $data->{entity}{name},
        )),
        artwork => to_json_object(
            $art_archive_model->art_model->_entity_class->new(
                $entity_type => ($loaded_entity || $entity_class->new(
                    gid => $data->{entity}{mbid},
                    id => $entity_id,
                    name => $data->{entity}{name},
                )),
                id => $data->{"${archive}_art_id"},
                comment => $data->{"${archive}_art_comment"},
                mime_type => $data->{$mime_type_field},
                suffix => $suffix,
                types => [map {
                    $loaded->{ $art_archive_model->art_type_model_name }{$_}
                } @{ $data->{"${archive}_art_types"} }],
            ),
        ),
        position => $data->{"${archive}_art_position"},
    };
}

sub restore {
    my ($self, $data) = @_;

    my $archive = $self->art_archive_model->art_archive_name;
    my $mime_type_field = "${archive}_art_mime_type";

    $data->{$mime_type_field} = 'image/jpeg'
        unless exists $data->{$mime_type_field};

    $self->data($data);
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
