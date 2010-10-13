package MusicBrainz::Server::Entity::Role::Linkable;
use Moose::Role;

use MusicBrainz::Server::Entity::Types;

has 'relationships' => (
    is => 'rw',
    isa => 'ArrayRef[Relationship]',
    default => sub { [] },
    lazy => 1,
    traits => [ 'Array' ],
    handles => {
        all_relationships   => 'elements',
        add_relationship    => 'push',
        clear_relationships => 'clear'
    }
);

sub grouped_relationships
{
    my ($self) = @_;

    my %groups;
    my @relationships = sort {
        $a->link->begin_date <=> $b->link->begin_date ||
        $a->link->end_date   <=> $b->link->end_date   ||
        $a->target->name     cmp $b->target->name
    } $self->all_relationships;

    for my $relationship (@relationships) {
        $groups{ $relationship->target_type } ||= {};
        $groups{ $relationship->target_type }{ $relationship->phrase } ||= [];
        push @{ $groups{ $relationship->target_type }{ $relationship->phrase} },
            $relationship;
    }

    return \%groups;
}

sub relationships_by_type
{
    my ($self, $type) = @_;

    return grep {
        defined $_->link && defined $_->link->type && $_->target_type eq $type;
    } $self->all_relationships;
}

1;

=head1 NAME

MusicBrainz::Server::Entity::Role::Linkable

=head1 ATTRIBUTES

=head2 relationships

List of relationships.

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
