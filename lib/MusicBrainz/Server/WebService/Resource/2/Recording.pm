package MusicBrainz::Server::WebService::Resource::2::Recording;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::WebService::Resource::2::Recording::GET;

with 'MusicBrainz::Server::WebService::Resource';

has '+methods' => (
    default => sub { {
        GET => MusicBrainz::Server::WebService::Resource::2::Recording::GET->new
    } }
);

1;
