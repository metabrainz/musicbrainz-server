use strict;
use warnings;
use Plack::Builder;
use MusicBrainz::Server::WebService::2;

builder {
    MusicBrainz::Server::WebService::2->new
};
