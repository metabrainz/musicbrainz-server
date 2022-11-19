package MusicBrainz::Server::Form::Role::Edit;
use strict;
use warnings;

use HTML::FormHandler::Moose::Role;

with 'MusicBrainz::Server::Form::Role::EditNote';

requires 'edit_field_names';

sub edit_fields
{
    my ($self) = @_;
    return grep {
        $_->has_input || $_->has_value
    } map {
        $self->field($_)
    } $self->edit_field_names;
}

1;
