package MusicBrainz::Server::View::Xslate;
use Moose;

extends 'Catalyst::View::Xslate';

has '+function' => (
    default => sub { +{
        l => sub { shift }
    }}
);

1;
