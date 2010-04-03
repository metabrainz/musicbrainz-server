package MusicBrainz::Server::Data::CoreFeyEntity;
use Moose;
use MooseX::ABC;

extends 'MusicBrainz::Server::Data::FeyEntity',
    'MusicBrainz::Server::Data::CoreEntity';

__PACKAGE__->meta->make_immutable;
