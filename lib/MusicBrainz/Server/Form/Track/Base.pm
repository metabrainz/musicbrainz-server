package MusicBrainz::Server::Form::Track::Base;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use MusicBrainz::Server::Track;

sub name { 'track' }

sub profile
{
    shift->with_mod_fields({
        required => {
            track => '+MusicBrainz::Server::Form::Field::Track',
        },
    });
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
