package MusicBrainz::Server::Entity::Role::Linkable;
use Moose::Role;

use List::UtilsBy qw( partition_by sort_by );
use MooseX::Types::Moose qw( Str );
use MooseX::Types::Structured qw( Map Optional );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( l );
use aliased 'MusicBrainz::Server::Entity::RelationshipTargetTypeGroup';

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

has 'paged_relationship_groups' => (
    is => 'rw',
    isa => Map[Str, Optional[RelationshipTargetTypeGroup]],
    default => sub { +{} },
    lazy => 1,
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

sub relationships_by_type
{
    my ($self, @types) = @_;
    my %types = map { $_ => 1 } @types;

    return [ grep {
        defined $_->link && defined $_->link->type &&
        exists $types{ $_->target_type };
    } $self->all_relationships ];
}

has '_relationships_by_link_type_name' => (
    is => 'rw',
    isa => 'HashRef',
    lazy => 1,
    default => sub {
        my $self = shift;
        my %result = partition_by {
            (defined $_->link && defined $_->link->type)
                ? ($_->link->type->name // '')
                : ''
        } sort_by { $_->id } (
            $self->all_relationships,
            (map { $_->all_relationships }
                values %{ $self->paged_relationship_groups })
        );
        \%result;
    },
);

sub relationships_by_link_type_names
{
    my ($self, @names) = @_;
    return [ map {
        @{ $self->_relationships_by_link_type_name->{$_} // [] }
    } @names ];
}

our $_relationships_depth = 0;

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;

    # Allow a depth of up to 2, which should cover work relationships
    # linked via a release.
    if ($_relationships_depth < 2 && $self->has_loaded_relationships) {
        $json->{relationships} = [map {
            local $_relationships_depth = $_relationships_depth + 1;
            $_->TO_JSON
        } $self->all_relationships];
    }

    my %paged_relationship_groups = %{ $self->paged_relationship_groups };
    if (%paged_relationship_groups) {
        $json->{paged_relationship_groups} = {
            map {
                $_ => to_json_object($paged_relationship_groups{$_})
            } keys %paged_relationship_groups
        };
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
