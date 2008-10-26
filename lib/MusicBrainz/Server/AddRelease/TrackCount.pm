package MusicBrainz::Server::AddRelease::TrackCount;

use strict;
use warnings;

use base 'MusicBrainz::Server::AddRelease::State';

sub init
{
    my ($self) = @_;

    $self->{form} = $self->{c}->form(undef, 'AddRelease::TrackCount');
}

sub execute
{
    my $self = shift;

    my $c = $self->{c};
    my $s = $self->{system};

    return unless $c->form_posted &&
                  $self->{form}->validate($c->req->params);

    $s->{track_count} = $self->{form}->value('track_count');

    require MusicBrainz::Server::AddRelease::ReleaseInformation;

    return new MusicBrainz::Server::AddRelease::ReleaseInformation($c, $s);
}

sub template { 'track_count.tt' }

1;
