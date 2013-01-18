package MusicBrainz::Server::Data::NES::Edit;
use Moose;

use MusicBrainz::Server::Entity::NES::Edit;

with 'MusicBrainz::Server::Data::Role::NES';

sub open {
    my $self = shift;
    return MusicBrainz::Server::Entity::NES::Edit->new(
        id => $self->request('/edit/open', {})->{ref}
    );
}

__PACKAGE__->meta->make_immutable;
1;
