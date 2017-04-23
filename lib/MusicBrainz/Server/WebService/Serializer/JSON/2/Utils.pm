package MusicBrainz::Server::WebService::Serializer::JSON::2::Utils;

use warnings;
use strict;

use base 'Exporter';
use Class::Load qw( load_class );
use List::UtilsBy qw( sort_by );
use MusicBrainz::Server::Constants qw( %ENTITIES );

our @EXPORT_OK = qw(
    boolean
    count_of
    list_of
    number
    serialize_date_period
    serialize_entity
    serialize_type
    serializer
);

my %serializers =
    map {
        my $class = "MusicBrainz::Server::WebService::Serializer::JSON::2::$_";
        my $entity_class = "MusicBrainz::Server::Entity::$_";
        load_class($class);
        load_class($entity_class);
        $entity_class->entity_type => $class->new
    } qw(
        Area
        Artist
        ArtistCredit
        CDStubTOC
        CDTOC
        Collection
        Event
        Instrument
        ISRC
        Label
        Place
        Medium
        Recording
        Relationship
        Release
        ReleaseGroup
        Series
        URL
        Work
    );

sub boolean { return (shift) ? JSON::true : JSON::false; }

sub number {
    my $value = shift;
    return defined $value ? $value + 0 : JSON::null;
}

sub serialize_date_period {
    my ($into, $entity) = @_;

    $into->{begin} = $entity->begin_date->format || JSON::null;
    $into->{end} = $entity->end_date->format || JSON::null;
    $into->{ended} = boolean($entity->ended);
    return;
}

sub serializer
{
    my $entity = shift;

    if ($entity->can('entity_type')) {
        my $serializer = $serializers{$entity->entity_type};
        return $serializer if $serializer;
    }

    die 'No serializer found for ' . ref($entity);
}

sub serialize_entity
{
    my ($entity) = @_;

    return unless defined $entity;

    my $output = serializer($entity)->serialize(@_);
    my $props = $ENTITIES{$entity->entity_type};

    serialize_aliases($output, @_)
        if $props->{aliases};

    serialize_type($output, @_)
        if $props->{type} && $props->{type}{simple};

    return $output;
}

sub list_of
{
    my ($entity, $inc, $stash, $type, $toplevel) = @_;

    my $opts = $stash->store($entity);
    my $list = $opts->{$type};
    my $items = (ref $list eq 'HASH') ? $list->{items} : $list;

    return [
        map { serialize_entity($_, $inc, $stash, $toplevel) }
        sort_by { $_->gid } @$items ];
}

sub count_of
{
    my ($entity, $inc, $stash, $type, $toplevel) = @_;

    my $opts = $stash->store($entity);
    my $list = $opts->{$type};
    my $items = (ref $list eq 'HASH') ? $list->{items} : $list;

    return number(scalar @$items);
}

sub serialize_aliases {
    my ($into, $entity, $inc, $stash) = @_;

    return unless defined $inc && $inc->aliases;

    my $opts = $stash->store($entity);

    $into->{aliases} = [map {
        my %item;

        $item{name} = $_->name;
        $item{'sort-name'} = $_->sort_name;
        $item{locale} = $_->locale // JSON::null;
        $item{primary} = $_->locale ?
            boolean($_->primary_for_locale) : JSON::null;

        serialize_type(\%item, $_, $inc, $stash, 1);
        serialize_date_period(\%item, $_);

        \%item;
    } sort_by { $_->name } @{ $opts->{aliases} }];

    return;
}

sub serialize_type {
    my ($into, $entity, $inc, $stash, $toplevel) = @_;

    my $entity_type = $entity->entity_type;
    return unless
        ($toplevel ||
         # For some reason, these four entities were implemented to always
         # output types in the XML and JSON, regardless of `$toplevel`.
         $entity_type eq 'collection' ||
         $entity_type eq 'event' ||
         $entity_type eq 'place' ||
         $entity_type eq 'work');

    my $type = $entity->type;
    $into->{type} = defined $type ? $type->name : JSON::null;
    $into->{'type-id'} = defined $type ? $type->gid : JSON::null;
    return;
}

1;

=head1 COPYRIGHT

Copyright (C) 2012-2013 MetaBrainz Foundation

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
