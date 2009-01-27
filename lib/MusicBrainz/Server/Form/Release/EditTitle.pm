package MusicBrainz::Server::Form::Release::EditTitle;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub name { 'edit-release-title' }

sub profile
{
    shift->with_mod_fields({
        required => {
            title => 'Text',
        },
    });
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
