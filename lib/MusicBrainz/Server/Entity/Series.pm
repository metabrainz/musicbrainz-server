package MusicBrainz::Server::Entity::Series;

use Moose;
use MusicBrainz::Server::Constants qw( %PART_OF_SERIES );
use MusicBrainz::Server::Entity::Types;

no if $] >= 5.018, warnings => "experimental::smartmatch";

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'SeriesType' };

sub entity_type { 'series' }

has ordering_type_id => (
    is => 'rw',
    isa => 'Int'
);

has ordering_type => (
    is => 'rw',
    isa => 'SeriesOrderingType'
);

sub display_relationships {
    my ($self) = @_;

    my %groups;
    my @relationships = sort { $a <=> $b } grep {
        !($_->link->type->gid ~~ [values %PART_OF_SERIES]);
    } $self->all_relationships;

    for my $relationship (@relationships) {
        $groups{ $relationship->target_type } ||= {};
        $groups{ $relationship->target_type }{ $relationship->phrase } ||= [];
        push @{ $groups{ $relationship->target_type }{ $relationship->phrase} }, $relationship;
    }

    return \%groups;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{orderingTypeID} = $self->ordering_type_id;

    if ($self->type) {
        $json->{type} = $self->type->TO_JSON;
    }

    return $json;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
