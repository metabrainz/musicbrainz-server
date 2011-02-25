package MusicBrainz::Server::WebService;
use Moose;
use MusicBrainz::Server::Context;

extends 'Sloth';

has '+c' => (
    default => sub {
        MusicBrainz::Server::Context->create_script_context;
    }
);

1;
