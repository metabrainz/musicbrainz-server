package MusicBrainz::Server::Form::Field::Comment;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Data::Utils qw( trim_comment );

extends 'HTML::FormHandler::Field::Text';

has '+maxlength' => ( default => 255 );
has '+not_nullable' => ( default => 1 );
has '+validate_when_empty' => (
    default => 1
);

sub validate {
    my $self = shift;

    if ($self->has_input) {
        $self->_set_value(trim_comment($self->value));
        return $self->SUPER::validate;
    } else {
        # validate_when_empty causes the $field value to become set even
        # if there was no input. We'd like to keep the field unset if it
        # was omitted so that existing comments aren't blanked, while still
        # trimming submitted blank values like '  '.
        $self->_clear_value;
    }
}

1;
