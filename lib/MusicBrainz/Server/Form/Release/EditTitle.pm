package MusicBrainz::Server::Form::Release::EditTitle;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        required => {
            title => 'Text',
        },
        optional => {
            edit_note => 'TextArea',
        },
    }
}

sub init_value
{
    my ($self, $field, $item) = @_;
    
    use Switch;
    switch ($field->name)
    {
        case ('title') { return $item->name; }
    }
}

sub edit_title
{
    my ($self) = @_;

    $self->context->model('Release')->edit_title(
        $self->item,
        $self->value('title'),
        $self->value('edit_note')
    );
}

1;
