package MusicBrainz::Server::WebService::Resource::2::Recording::GET::Params;
use Moose;
use namespace::clean;

has gid => (
    required => 1,
    is => 'ro'
);

1;
