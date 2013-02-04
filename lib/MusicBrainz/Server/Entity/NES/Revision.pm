package MusicBrainz::Server::Entity::NES::Revision;
use Moose;
use namespace::autoclean;

has created_at => (
    is => 'ro',
);

no Moose;
1;
