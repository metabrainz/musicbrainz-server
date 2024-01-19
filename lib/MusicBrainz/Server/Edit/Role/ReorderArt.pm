package MusicBrainz::Server::Edit::Role::ReorderArt;
use Moose::Role;
use namespace::autoclean;

use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use List::AllUtils qw( nsort_by );
use Data::Compare;

with 'MusicBrainz::Server::Edit::Role::Art',
     'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

requires qw(
    art_archive_model
    edit_name
    edit_template
    edit_type
);

sub edit_kind { 'other' }

sub entity_ids { shift->data->{entity}{id} }

sub art_ids { }

sub data_fields {
    Dict[
        entity => Dict[
            id   => Int,
            name => Str,
            mbid => Str,
        ],
        old => ArrayRef[Dict[ id => Int, position => Int ]],
        new => ArrayRef[Dict[ id => Int, position => Int ]],
    ];
}

sub initialize {
    my ($self, %opts) = @_;

    my $art_archive_model = $self->art_archive_model;
    my $entity_type = $art_archive_model->art_archive_entity;
    my $entity = $opts{$entity_type} or die 'Entity missing';

    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
        if Compare( [ nsort_by { $_->{position} } @{ $opts{old} } ],
                    [ nsort_by { $_->{position} } @{ $opts{new} } ] );

    $self->data({
        entity => {
            id => $entity->id,
            name => $entity->name,
            mbid => $entity->gid,
        },
        old => $opts{old},
        new => $opts{new},
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

    my $current = $art_archive_model->art_model->find_by_entity([$entity]);
    my @current_ids = sort(map { $_->id } @$current);
    my @edit_ids = sort(map { $_->{id} } @{ $data->{old} });

    if (join(q(,), @current_ids) ne join (q(,), @edit_ids)) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'Artwork has been added or removed since this edit was ' .
            'entered, which conflicts with changes made in this edit.',
        );
    }

    my %position = map { $_->{id} => $_->{position} } @{ $data->{new} };

    $art_archive_model->reorder_art($entity->id, \%position);
}

sub foreign_keys {
    my ($self) = @_;

    my $data = $self->data;
    my $art_archive_model = $self->art_archive_model;
    my $entity_type = $art_archive_model->art_archive_entity;
    my $entity_model_name = $art_archive_model->entity_model_name;

    return {
        $entity_model_name => {
            $data->{entity}{id} => [
                $ENTITIES{$entity_type}{artist_credits}
                    ? 'ArtistCredit'
                    : (),
            ],
        },
    };
}

sub build_display_data {
    my ($self, $loaded) = @_;

    my $data = $self->data;
    my $entity_id = $data->{entity}{id};
    my $art_archive_model = $self->art_archive_model;
    my $entity_type = $art_archive_model->art_archive_entity;
    my $entity_model_name = $art_archive_model->entity_model_name;

    my $entity = $loaded->{$entity_model_name}{$entity_id};
    if (!$entity) {
        $entity = $art_archive_model->entity_model->get_by_gid(
            $data->{entity}{mbid},
        );
        if ($entity && $ENTITIES{$entity_type}{artist_credits}) {
            $self->c->model('ArtistCredit')->load($entity);
        }
    }

    my $artwork;
    if ($entity) {
        $artwork = $art_archive_model->art_model->find_by_entity([$entity]);
        $art_archive_model->art_type_model->load_for(@$artwork);
    } else {
        $entity = $art_archive_model->entity_model->_entity_class->new(
            name => $data->{entity}{name},
            id => $data->{entity}{id},
            gid => $data->{entity}{mbid},
        );
        $artwork = [];
    }
    my %artwork_by_id = map { $_->id => $_ } @$artwork;

    for my $undef_artwork (
        grep { !defined $artwork_by_id{ $_->{id} } } @{ $data->{old} }
    ) {
        my $fake_artwork = $art_archive_model->art_model->_entity_class->new(
            $entity_type => $entity,
            id => $undef_artwork->{id},
        );
        push @$artwork, $fake_artwork;
        $artwork_by_id{ $undef_artwork->{id} } = $fake_artwork;
    }

    my @old = nsort_by { $_->{position} } @{ $data->{old} };
    my @new = nsort_by { $_->{position} } @{ $data->{new} };

    return {
        $entity_type => to_json_object($entity),
        old => [ map { to_json_object($artwork_by_id{ $_->{id} }) } @old ],
        new => [ map { to_json_object($artwork_by_id{ $_->{id} }) } @new ],
    };
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
