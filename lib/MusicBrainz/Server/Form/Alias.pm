package MusicBrainz::Server::Form::Alias;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-alias' );

has_field 'name' => (
    type => 'Text',
    required => 1
);

has 'parent_id' => (
    isa => 'Int',
    is  => 'ro',
    required => 1,
);

has 'alias_model' => (
    isa => 'MusicBrainz::Server::Data::Alias',
    is  => 'ro',
    required => 1
);

sub edit_field_names { qw(name) }

sub validate_name {
    my ($self, $field) = @_;
    $field->add_error('This alias has already been added')
        if $self->alias_model->has_alias( $self->parent_id, $field->value );
}

1;
