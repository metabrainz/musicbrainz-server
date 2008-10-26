package MusicBrainz::Server::Controller::AddRelease::ReleaseInformation;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller::AddRelease';

sub init
{
    my $self = shift;

    my $c = $self->context;
    my $s = $self->system;

    $self->{form} = $c->form(undef, 'AddRelease::Tracks');

    $c->stash->{track_count} = $s->{track_count};
    $self->{form}->add_tracks($s->{track_count});
}

sub template { 'tracks.tt' }

sub execute
{
    return;
}

1;
