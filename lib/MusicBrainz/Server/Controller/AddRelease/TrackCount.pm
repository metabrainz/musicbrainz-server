package MusicBrainz::Server::Controller::AddRelease::TrackCount;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller::AddRelease';

sub init
{
    my ($self) = @_;

    $self->{form} = $self->context->form(undef, 'AddRelease::TrackCount');
}

sub execute
{
    my ($self) = @_;

    my $c = $self->context;
    my $s = $self->system;

    return unless $c->form_posted &&
                  $self->{form}->validate($c->req->params);

    $s->{track_count} = $self->{form}->value('track_count');

    return 'ReleaseInformation';
}

sub template { 'track_count.tt' }

1;
