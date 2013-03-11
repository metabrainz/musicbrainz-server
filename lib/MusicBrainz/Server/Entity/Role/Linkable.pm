package MusicBrainz::Server::Entity::Role::Linkable;
use Moose::Role;

use MusicBrainz::Server::Entity::Types;
use List::UtilsBy qw( sort_by );

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
    my ($self, @types) = @_;
    my %filter = map { $_ => 1 } @types;
    my $filter_present = @types > 0;

    my %groups;
    my @relationships = sort { $a <=> $b } $self->all_relationships;

    for my $relationship (@relationships) {
        next if ($filter_present && !$filter{ $relationship->target_type });
        $groups{ $relationship->target_type } ||= {};
        $groups{ $relationship->target_type }{ $relationship->phrase } ||= [];
        push @{ $groups{ $relationship->target_type }{ $relationship->phrase} },
            $relationship;
    }

    return \%groups;
}

sub relationships_by_type
{
    my ($self, @types) = @_;
    my %types = map { $_ => 1 } @types;

    return [ grep {
        defined $_->link && defined $_->link->type &&
        exists $types{ $_->target_type };
    } $self->all_relationships ];
}

sub relationships_by_link_type_names
{
    my ($self, @names) = @_;
    my %names = map { $_ => 1 } @names;

    return [ grep {
        defined $_->link && defined $_->link->type &&
        defined $_->link->type->name &&
        exists $names{ $_->link->type->name };
    } $self->all_relationships ];
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
