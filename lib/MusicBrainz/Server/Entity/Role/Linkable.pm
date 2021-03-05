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

# Converted to JavaScript at root/utility/groupRelationships.js
sub grouped_relationships
{
    my ($self, @types) = @_;
    my %filter = map { $_ => 1 } @types;
    my $filter_present = @types > 0;

    my %groups;
    my @relationships = sort { $a <=> $b } $self->all_relationships;

    for my $relationship (@relationships) {
        next if ($filter_present && !$filter{ $relationship->target_type });

        my $phrase = $relationship->grouping_phrase;
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

# Converted to JavaScript at root/utility/filterRelationshipsByType.js
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

my $_serialize_relationships = 1;

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;

    if ($_serialize_relationships && $self->has_loaded_relationships) {
        $json->{relationships} = [map {
            $_serialize_relationships = 0;
            my $result = $_->TO_JSON;
            $_serialize_relationships = 1;
            $result;
        } $self->all_relationships];
    }

    return $json;
};

1;

=head1 NAME

MusicBrainz::Server::Entity::Role::Linkable

=head1 ATTRIBUTES

=head2 relationships

List of relationships.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
