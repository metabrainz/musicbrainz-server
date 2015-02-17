package MusicBrainz::Server::Entity::Subscription::Deleted;
use Moose::Role;
use namespace::autoclean;
use Moose::Util::TypeConstraints;

with 'MusicBrainz::Server::Entity::Subscription';

has 'last_known_name' => (
    isa => 'Str',
    is => 'ro',
    required => 1
);

has 'last_known_comment' => (
    isa => 'Str',
    is => 'ro',
    required => 1
);

has 'edit_id' => (
    isa => 'Int',
    is => 'ro',
    required => 1
);

has 'reason' => (
    isa => enum([qw( merged deleted )]),
    is => 'ro',
    required => 1
);

1;
