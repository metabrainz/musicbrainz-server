package MusicBrainz::Server::WebService::2::Resource::Recording;
use Moose;
use namespace::autoclean;
with 'MusicBrainz::Server::WebService::Resource';

sub path {
    'recording/:gid'
}

1;
