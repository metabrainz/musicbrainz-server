package MusicBrainz::Server::Form::Track::Base;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use MusicBrainz::Server::Track;

sub profile
{
    return {
        required => {
            track => '+MusicBrainz::Server::Form::Field::Track',
        },
        optional => {
            edit_note => 'TextArea',
        }
    }
}

sub init_value
{
    my ($self, $field) = @_;

    my $track = $self->item;

    return unless $track;

    use Switch;
    switch ($field->name)
    {
        case ('track') { return $self->item; }
    }
}

1;
