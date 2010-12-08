package MusicBrainz::Server::Entity::EditorWatchArtist;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

has [qw( artist_id editor_id )] => (
    isa => 'Int',
    is => 'ro',
);

has 'artist' => (
    isa => 'Artist',
    is => 'rw',
);

has 'editor' => (
    isa => 'Editor',
    is => 'rw',
);

__PACKAGE__->meta->make_immutable;
1;
