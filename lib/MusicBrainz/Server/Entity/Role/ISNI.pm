package MusicBrainz::Server::Entity::Role::ISNI;
use Moose::Role;

has isni_codes => (
    isa => 'ArrayRef',
    is => 'ro',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        add_isni_code => 'push',
        all_isni_codes => 'elements',
    }
);

1;
