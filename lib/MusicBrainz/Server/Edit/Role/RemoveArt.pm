package MusicBrainz::Server::Edit::Role::RemoveArt;
use Moose::Role;
use namespace::autoclean;

use MooseX::Types::Moose qw( Str Int ArrayRef );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

with 'MusicBrainz::Server::Edit::Role::Art',
     'MusicBrainz::Server::Edit::Role::NeverAutoEdit';

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
        "${archive}_art_id" => Int,
        "${archive}_art_types" => ArrayRef[Int],
        "${archive}_art_comment" => Str,
        "${archive}_art_mime_type" => Optional[Str],
        "${archive}_art_suffix" => Optional[Str],
    ];
}

sub edit_kind { 'remove' }

sub entity_ids { shift->data->{entity}{id} }

sub art_ids {
    my $self = shift;

    my $archive = $self->art_archive_model->art_archive_name;
    return $self->data->{"${archive}_art_id"};
}

sub initialize {
    my ($self, %opts) = @_;

    my $art_archive_model = $self->art_archive_model;
    my $entity_type = $art_archive_model->art_archive_entity;

    my $entity = $opts{$entity_type} or die 'Entity missing';
    my $artwork = $opts{to_delete} or die q(Required 'to_delete' object);

    my $archive = $art_archive_model->art_archive_name;

    my %type_map = map {
        $_->name => $_
    } $art_archive_model->art_type_model->get_by_name(
        @{ $artwork->type_names },
    );

    $self->data({
        entity => {
            id => $entity->id,
            name => $entity->name,
            mbid => $entity->gid,
        },
        "${archive}_art_id" => $artwork->id,
        "${archive}_art_comment" => $artwork->comment,
        "${archive}_art_types" => [
            grep { defined }
             map { $type_map{$_}->id }
                @{ $artwork->type_names },
        ],
        "${archive}_art_mime_type" => $artwork->mime_type,
        "${archive}_art_suffix" => $artwork->suffix,
    });
}

sub accept {
    my $self = shift;

    my $data = $self->data;
    my $art_archive_model = $self->art_archive_model;

    my $entity =
        $art_archive_model->entity_model->get_by_id($data->{entity}{id});
    if (!$entity) {
        my $entity_type = $art_archive_model->art_archive_entity;
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            "This $entity_type no longer exists",
        );
    }

    my $archive = $art_archive_model->art_archive_name;
    $art_archive_model->delete($data->{"${archive}_art_id"});
}

sub foreign_keys {
    my ($self) = @_;

    my $data = $self->data;
    my $art_archive_model = $self->art_archive_model;
    my $entity_type = $art_archive_model->art_archive_entity;
    my $entity_model_name = $art_archive_model->entity_model_name;
    my $archive = $art_archive_model->art_archive_name;

    return {
        $entity_model_name => {
            $data->{entity}{id} => [
                $ENTITIES{$entity_type}{artist_credits}
                    ? 'ArtistCredit'
                    : (),
            ],
        },
        $art_archive_model->art_model_name => {
            $data->{"${archive}_art_id"} => [$entity_model_name],
        },
        $art_archive_model->art_type_model_name => (
            $data->{"${archive}_art_types"}
        ),
    };
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $data = $self->data;
    my $entity_id = $data->{entity}{id};
    my $art_archive_model = $self->art_archive_model;
    my $entity_type = $art_archive_model->art_archive_entity;
    my $archive = $art_archive_model->art_archive_name;
    my $id_field = "${archive}_art_id";
    my $mime_type_field = "${archive}_art_mime_type";
    my $suffix_field = "${archive}_art_suffix";

    my $entity =
        $loaded->{ $art_archive_model->entity_model_name }{$entity_id} ||
        $self->entity_model->_entity_class->new(
            id => $entity_id,
            name => $data->{entity}{name},
        );

    my $artwork = $loaded->{
        $art_archive_model->art_model_name
    }{ $data->{$id_field} } ||
        $art_archive_model->art_model->_entity_class->new(
            $entity_type => $entity,
            id => $data->{$id_field},
            comment => $data->{"${archive}_art_comment"},
            exists $data->{$mime_type_field} ? (
                mime_type => $data->{$mime_type_field},
            ) : (),
            exists $data->{$suffix_field} ? (
                suffix => $data->{$suffix_field},
            ) : (),
        );

    $artwork->types([
        map {
            $loaded->{ $art_archive_model->art_type_model_name }{$_}
        } @{ $data->{"${archive}_art_types"} },
    ]);

    return {
        $entity_type => to_json_object($entity),
        artwork => to_json_object($artwork),
    };
}


1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
