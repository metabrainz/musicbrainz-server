package MusicBrainz::WebService;
use Moose;
use namespace::autoclean;

extends 'Sloth';

use MusicBrainz::Server::Context;

has '+c' => (
    default => sub {
        MusicBrainz::Server::Context->create_script_context
    }
);

__PACKAGE__->meta->make_immutable;
1;
