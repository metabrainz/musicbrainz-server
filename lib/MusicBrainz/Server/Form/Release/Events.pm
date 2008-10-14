package MusicBrainz::Server::Form::Release::Events;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        required => {
            event_count => 'Hidden',
        },
        optional => {
            add_event => 'Checkbox',
            edit_note => 'TextArea',
        }
    };
}

sub init
{
    my $self = shift;

    $self->SUPER::init(@_);

    my $release = $self->item;
    my @events  = $release->ReleaseEvents(1);
    $self->{_cached_events} = \@events;


    my $event_counter = 0;
    for my $event (@events)
    {
        $event_counter++;
        $self->add_field(
            $self->make_field("event_$event_counter", '+MusicBrainz::Server::Form::Field::ReleaseEvent')
        );
    }

    $self->init_from_object;

    1;
}

sub init_value
{
    my ($self, $field) = @_;

    if ($field->name eq 'event_1')
    {
        return $self->{_cached_events}->[0];
    }
}

1;
