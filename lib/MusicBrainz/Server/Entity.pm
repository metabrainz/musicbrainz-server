package MusicBrainz::Server::Entity;

use Moose;
use MusicBrainz::Server::Data::Utils qw( ref_to_type );
use MusicBrainz::Server::Entity::Util::JSON qw( add_linked_entity );

has 'id' => (
    is => 'rw',
    isa => 'Int'
);

sub link_entity {
    shift;
    add_linked_entity(@_);
}

sub TO_JSON {
    my ($self) = @_;

    my $entity_type = ref_to_type($self);
    my $id = $self->id;

    return {
        entityType => $entity_type,
        id => defined $id ? (0 + $id) : undef,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
