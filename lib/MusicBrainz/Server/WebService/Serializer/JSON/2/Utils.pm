package MusicBrainz::Server::WebService::Serializer::JSON::2::Utils;

use warnings;
use strict;

use base 'Exporter';
use Class::Load qw( load_class );
use List::UtilsBy qw( sort_by );

our @EXPORT_OK = qw(
    boolean
    count_of
    list_of
    number
    serialize_date_period
    serialize_entity
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

    my $serializer = $serializers{$entity->entity_type};
    return $serializer if $serializer;

    die 'No serializer found for ' . ref($entity);
}

sub serialize_entity
{
    return unless defined $_[0];
    return serializer($_[0])->serialize(@_);
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
