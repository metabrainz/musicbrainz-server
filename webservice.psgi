use strict;
use warnings;
use Plack::Builder;
use MusicBrainz::Server::WebService::2;

builder {
    mount '/ws/2/' => MusicBrainz::Server::WebService::2->new
};
