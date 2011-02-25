package MusicBrainz::Server::WebService::Resource::2::Recording;
use Moose;
use namespace::autoclean;
with 'MusicBrainz::Server::WebService::Resource';

sub path {
    'recording/:gid'
}

1;
