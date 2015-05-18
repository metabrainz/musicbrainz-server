package MusicBrainz::Server::Form::Collection;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Constants qw( entities_with );

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

sub options_type_id { select_options_tree(shift->ctx, 'CollectionType') }

sub validate_type_id {
    my $self = shift;

    my $request = $self->ctx->request;

    my $type = $self->ctx->model('CollectionType')->get_by_id($self->field('type_id')->value);

    for my $entity_type (entities_with('collections')) {
        if ($request->params->{$entity_type} && $type->entity_type ne $entity_type) {
            return $self->field('type_id')->add_error(l('The collection type does not apply to the given entity.'));
        }
    }
}
1;
