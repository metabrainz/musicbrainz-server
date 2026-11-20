package MusicBrainz::Server::Form::Admin::Noindex;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Data::Utils qw( is_blank type_to_model );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::CSRFToken';

has '+name' => ( default => 'noindex' );

has 'entity_type' => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has 'existing_active_gids' => (
    isa => 'HashRef',
    is => 'ro',
    default => sub { {} },
);

has 'entities_by_gid' => (
    isa => 'HashRef',
    is => 'ro',
    lazy => 1,
    builder => '_build_entities_by_gid',
);

has_field 'entity' => (
    type => 'Repeatable',
    num_extra => 1,
);
has_field 'entity.gid'        => ( type => '+MusicBrainz::Server::Form::Field::GID' );
has_field 'entity.request_id' => ( type => 'Text', not_nullable => 1 );
has_field 'entity.active'     => ( type => 'Boolean', default => 1 );
has_field 'entity.removed'    => ( type => 'Boolean' );

sub _build_entities_by_gid {
    my ($self) = @_;

    my $model = $self->ctx->model(type_to_model($self->entity_type));
    return $model->get_by_gids(
        map { $_->field('gid')->value }
            $self->field('entity')->fields,
    );
}

after validate => sub {
    my ($self) = @_;

    my $entities = $self->entities_by_gid;

    for my $entity_field ($self->field('entity')->fields) {
        my $gid_field = $entity_field->field('gid');
        my $gid = $gid_field->value;
        next unless defined $gid && !$gid_field->has_errors;

        $gid_field->add_error("Could not resolve MBID ${gid}.")
            unless exists $entities->{$gid};

        my $removed_field = $entity_field->field('removed');
        if ($removed_field->value) {
            $removed_field->add_error('Only inactive entries can be removed.')
                if $self->existing_active_gids->{$gid};
            next;
        }

        my $request_id_field = $entity_field->field('request_id');
        $request_id_field->add_error('A request ID is required.')
            if is_blank($request_id_field->value);
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
