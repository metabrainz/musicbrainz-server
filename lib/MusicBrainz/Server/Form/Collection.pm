package MusicBrainz::Server::Form::Collection;
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
    required => 0,
    not_nullable => 1,
);

has_field 'public' => (
    type => 'Boolean',
);

sub edit_field_names
{
    return qw( name description public type_id );
}

sub options_type_id {
    my $self = shift;

    my $types = select_options_tree($self->ctx, 'CollectionType');
    my $collection = $self->init_object;

    if ($collection && blessed $collection) {
        my $entity_type = $collection->type->entity_type;
        my %valid_types =
            map { $_->id => 1 }
            $self->ctx->model('CollectionType')->find_by_entity_type($entity_type);
        $types = [grep { $valid_types{$_->{value}} } @$types];
    }

    return $types;
}

sub validate_type_id {
    my $self = shift;

    my $collection = $self->init_object;
    return unless $collection && blessed $collection;

    my $entity_type = $collection->type->entity_type;
    if (!$self->ctx->model('Collection')->is_empty($entity_type, $collection->id)) {
        my $new_type = $self->ctx->model('CollectionType')->get_by_id(
            $self->field('type_id')->value
        );
        if ($entity_type ne $new_type->entity_type) {
            return $self->field('type_id')->add_error(
                l('The collection type must match the type of entities it contains.')
            );
        }
    }
}

1;
