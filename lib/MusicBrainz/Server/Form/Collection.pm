package MusicBrainz::Server::Form::Collection;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'edit-list' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'type_id' => (
    type => 'Select',
    required => 1,
);

has_field 'description' => (
    type => 'TextArea',
    trim => { transform => sub {
        my $string = shift;
        # Not trimming starting spaces to avoid breaking list formatting,
        # consider trimming again once this uses Markdown 
        $string =~ s/\s+$//;
        return $string;
    } },
    required => 0,
    not_nullable => 1,
);

has_field 'public' => (
    type => 'Boolean',
);

has_field 'collaborators' => (
    type => 'Repeatable',
);

has_field 'collaborators.contains' => (
    type => '+MusicBrainz::Server::Form::Field::Editor',
);

sub edit_field_names
{
    return qw( name description public type_id collaborators );
}

sub options_type_id {
    my $self = shift;

    my $types = select_options_tree($self->ctx, 'CollectionType');
    my $collection = $self->init_object;
    my $type_filter;

    if ($collection && blessed $collection) {
        my $entity_type = $collection->type->item_entity_type;
        unless ($self->ctx->model('Collection')->is_empty($entity_type, $collection->{id})) {
            $type_filter = $entity_type;
        }
    } elsif ($collection && $collection->{allowed_entity_type}) {
        $type_filter = $collection->{allowed_entity_type};
    }

    if (defined $type_filter) {
        my %valid_types =
            map { $_->id => 1 }
                $self->ctx->model('CollectionType')->find_by_entity_type($type_filter);
        $types = [grep {$valid_types{$_->{value}}} @$types];
    }

    return $types;
}

sub validate_type_id {
    my $self = shift;

    my $collection = $self->init_object;
    return unless $collection && blessed $collection;

    my $entity_type = $collection->type->item_entity_type;
    if (!$self->ctx->model('Collection')->is_empty($entity_type, $collection->id)) {
        my $new_type = $self->ctx->model('CollectionType')->get_by_id(
            $self->field('type_id')->value
        );
        if ($entity_type ne $new_type->item_entity_type) {
            return $self->field('type_id')->add_error(
                l('The collection type must match the type of entities it contains.')
            );
        }
    }
}

sub validate_collaborators {
    my $self = shift;

    my @collaborators = $self->field('collaborators')->fields;
    my $is_valid = 1;
    for my $collaborator (@collaborators) {
        my $id_field = $collaborator->field('id');
        my $name_field = $collaborator->field('name');
        if (defined $name_field->value && !(defined $id_field->value)) {
            my $editor = $self->ctx->model('Editor')->get_by_name($name_field->value);
            if (defined $editor) {
                $id_field->add_error(
                    l('To add “{editor}” as a collaborator, please select them from the dropdown.',
                      {editor => $name_field->value})
                );
            } else {
                $id_field->add_error(
                    l('Editor “{editor}” does not exist.',
                      {editor => $name_field->value})
                );
            }
            $is_valid = 0;
        }
    }

    return $is_valid;
}

1;
