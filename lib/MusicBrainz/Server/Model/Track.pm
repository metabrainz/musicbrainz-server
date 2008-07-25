package MusicBrainz::Server::Model::Track;

use strict;
use warnings;

use base 'Catalyst::Model';

use MusicBrainz::Server::Facade::Track;

sub ACCEPT_CONTEXT
{
    my ($self, $c) = @_;
    bless { _dbh => $c->mb->{DBH} }, ref $self;
}

sub load_from_release
{
    my ($self, $release, $relations) = @_;

    my @tracks = $release->get_release->LoadTracks;
    my $puid_counts = $release->get_release->LoadPUIDCount;

    return [ map
    {
        my $track = MusicBrainz::Server::Facade::Track->new_from_track($_);
        $track->puid_count($puid_counts->{ $track->id });

        $track;
    } @tracks ];
}

1;
