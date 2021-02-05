package MusicBrainz::Server::Entity::IPI;

use Moose;

with 'MusicBrainz::Server::Entity::Role::Editable';

has 'ipi' => (
    is => 'rw',
    isa => 'Str'
);

sub TO_JSON {
    my ($self) = @_;

    return {
        ipi => $self->ipi,
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
