package MusicBrainz::Server::Entity::Role::Linkable;
use Moose::Role;

use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Translation qw( l );
use List::UtilsBy qw( sort_by );

has 'relationships' => (
    is => 'rw',
    isa => 'ArrayRef[Relationship]',
    default => sub { [] },
    lazy => 1,
    traits => [ 'Array' ],
    handles => {
        all_relationships       => 'elements',
        add_relationship        => 'push',
        clear_relationships     => 'clear'
    }
);

has has_loaded_relationships => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
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

        my $phrase = $relationship->phrase;
        if ($relationship->source_credit) {
            $phrase = l('{role} (as {credited_name})', {
                role => $phrase,
                credited_name => $relationship->source_credit
            });
        }

        push @{ $groups{$relationship->target_type}{$phrase} }, $relationship;
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

    return [ sort_by { $_->id } grep {
        defined $_->link && defined $_->link->type &&
        defined $_->link->type->name &&
        exists $names{ $_->link->type->name };
    } $self->all_relationships ];
}

sub appearances {
    my $self = shift;
    my @rels = @{ $self->relationships_by_type($self->_appearances_table_types) };

    my %groups;
    for my $rel (@rels) {
        my $phrase = $rel->link->type->name;
        $groups{ $phrase } ||= [];
        push @{ $groups{$phrase} }, $rel;
    }

    return \%groups;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;

    if ($self->has_loaded_relationships) {
        $json->{relationships} = [map { $_->TO_JSON } $self->all_relationships];
    }

    return $json;
};

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
