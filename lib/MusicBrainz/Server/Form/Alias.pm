package MusicBrainz::Server::Form::Alias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditForm';

sub profile
{
    return {
        required => {
            alias => {
                type => 'Text',
                size => 50,
            },
        },
        optional => {
            edit_note => 'TextArea',
        }
    }
}

sub init_value
{
    my ($self, $field, $item) = @_;
    $item ||= $self->item;

    return unless defined $item;

    use Switch;
    switch ($field->name)
    {
        case ('alias') { return $item->name; }
    }
}

1;
