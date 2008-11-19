package MusicBrainz::Server::Controller::CdToc;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

sub cdtoc : Chained CaptureArgs(1)
{
    my ($self, $c, $discid) = @_;

    $c->stash->{cdtoc} = $c->model('CdToc')->load($discid);
}

sub show : Chained("cdtoc") PathPart('')
{
    my ($self, $c) = @_;

    my $cdtoc = $c->stash->{cdtoc};

    $c->stash->{releases} = [ map {
        my $release = $c->model('Release')->load($_);
    
        {
            release => $c->model('Release')->load($_),
            tracks  => $c->model('Track')->load_from_release($release),
        }
    } @{ $c->model('CdToc')->get_attached_release_ids($cdtoc) } ];

    $c->stash->{template} = 'toc/details.tt';
}

1;
