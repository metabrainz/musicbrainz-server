package MusicBrainz::Server::Edit::Role::EditArt;
use Moose::Role;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Util::JSON qw(
    to_json_array
    to_json_object
);
use MusicBrainz::Server::Validation qw( normalise_strings );

with 'MusicBrainz::Server::Edit::Role::Art',
     'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

requires qw(
    _change_data
    art_archive_model
    edit_name
    edit_template
    edit_type
);

sub edit_kind { 'edit' }

sub entity_ids { shift->data->{entity}{id} }

sub art_ids { shift->data->{id} }

sub change_fields {
    Dict[
        types => Optional[ArrayRef[Int]],
        comment => Optional[Str],
    ];
}

sub data_fields {
    Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str,
        ],
        id => Int,
        old => change_fields(),
        new => change_fields(),
    ];
}

sub initialize {
    my ($self, %opts) = @_;

    my $entity = $opts{ $self->art_archive_model->art_archive_entity }
        or die 'Entity missing';

    my %old = (
        types => $opts{old_types},
        comment => $opts{old_comment},
    );

    my %new = (
        types => $opts{new_types},
        comment => $opts{new_comment},
    );

    $self->data({
        entity => {
            id => $entity->id,
            name => $entity->name,
            mbid => $entity->gid,
        },
        id => $opts{artwork_id},
        $self->_change_data(\%old, %new),
    });
}

sub accept {
    my $self = shift;

    my $data = $self->data;
    my $art_archive_model = $self->art_archive_model;

    my $entity =
        $art_archive_model->entity_model->get_by_gid($data->{entity}{mbid});
    if (!$entity) {
        my $entity_type = $art_archive_model->art_archive_entity;
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            "This $entity_type no longer exists",
        );
    }

    $art_archive_model->exists($data->{id})
        or MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This artwork no longer exists',
        );

    $art_archive_model->update_art(
        $entity->id,
        $data->{id},
        $data->{new}{types},
        $data->{new}{comment},
    );
}

sub allow_auto_edit {
    my $self = shift;

    my $data = $self->data;

    return 0 if @{ $data->{old}{types} // [] };

    my ($old_comment, $new_comment) = normalise_strings(
        $data->{old}{comment}, $data->{new}{comment});
    return 0 if $old_comment ne $new_comment;

    return 1;
}

sub foreign_keys {
    my ($self) = @_;

    my $data = $self->data;
    my $art_archive_model = $self->art_archive_model;
    my $entity_model_name = $art_archive_model->entity_model_name;
    my $entity_type = $art_archive_model->art_archive_entity;

    return {
        $entity_model_name => {
            $data->{entity}{id} => [
                $ENTITIES{$entity_type}{artist_credits}
                    ? 'ArtistCredit'
                    : (),
            ],
        },
        $art_archive_model->art_model_name => {
            $data->{id} => [$entity_model_name],
        },
        (defined $data->{new}{types} ? (
            $art_archive_model->art_type_model_name => [
                @{ $data->{new}{types} },
                @{ $data->{old}{types} },
            ]) : ()),
    };
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $data = $self->data;
    my $art_archive_model = $self->art_archive_model;
    my $entity_type = $art_archive_model->art_archive_entity;
    my $art_type_model_name = $art_archive_model->art_type_model_name;
    my %display_data;

    my $entity = (
        $loaded->{
            $art_archive_model->entity_model_name
        }{ $data->{entity}{id} } ||
        $art_archive_model->entity_model->_entity_class->new(
            name => $data->{entity}{name},
        )
    );
    my $new_types = [ map {
        $loaded->{$art_type_model_name}{$_}
    } @{ $data->{new}{types} // [] }];

    $display_data{$entity_type} = to_json_object($entity);

    $display_data{artwork} = to_json_object(
        $loaded->{ $art_archive_model->art_model_name }{ $data->{id} } ||
        $art_archive_model->art_model->_entity_class->new(
            $entity_type => $entity,
            id => $data->{id},
            comment => $data->{new}{comment} // '',
            types => $new_types,
        ),
    );

    if ($data->{old}{types}) {
        $display_data{types} = {
            old => [ map {
                to_json_object($loaded->{$art_type_model_name}{$_})
            } @{ $data->{old}{types} // [] } ],
            new => to_json_array($new_types),
        };
    }

    if (exists $data->{old}{comment}) {
        $display_data{comment} = {
            old => $data->{old}{comment},
            new => $data->{new}{comment},
        };
    }

    return \%display_data;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
