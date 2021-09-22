package MusicBrainz::Server::Entity::ISNI;

use Moose;

with 'MusicBrainz::Server::Entity::Role::Editable';

has 'isni' => (
    is => 'rw',
    isa => 'Str'
);

sub url {
    my ($self) = @_;
    return 'http://www.isni.org/' . $self->isni;
}

sub TO_JSON {
    my ($self) = @_;

    return {
        isni => $self->isni,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
