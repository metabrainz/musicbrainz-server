package MusicBrainz::Server::Controller::CdToc;

use strict;
use warnings;

use base 'Catalyst::Controller';

sub cdtoc : Chained CaptureArgs(1)
{
    my ($self, $c, $discid) = @_;

    $c->stash->{cdtoc} = $c->model('CdToc')->load($discid);
}

sub show : Chained("cdtoc") PathPart('')
{
    my ($self, $c) = @_;
}

1;
