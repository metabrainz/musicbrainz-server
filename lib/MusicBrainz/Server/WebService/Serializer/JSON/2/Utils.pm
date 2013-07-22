package MusicBrainz::Server::WebService::Serializer::JSON::2::Utils;

use warnings;
use strict;

use base 'Exporter';
use Class::Load 'load_class';
use List::UtilsBy 'sort_by';

our @EXPORT_OK = qw(
    boolean
    count_of
    list_of
    number
    date_period
    serializer
    serialize_entity
);

my %serializers =
    map {
        my $class = "MusicBrainz::Server::WebService::Serializer::JSON::2::$_";
        load_class($class);
        "MusicBrainz::Server::Entity::$_" => $class->new
    } qw(
        Area
        Artist
        ArtistCredit
        CDStubTOC
        CDTOC
        Collection
        Label
        Medium
        Recording
        Relationship
        Release
        ReleaseGroup
        URL
        Work
    );

sub boolean { return (shift) ? JSON::true : JSON::false; }

sub number {
    my $value = shift;
    return defined $value ? $value + 0 : JSON::null;
}

sub date_period {
    my $entity = shift;

    my %lifespan = (
        begin => JSON::null,
        end => JSON::null,
        ended => boolean ($entity->ended),
        );

    $lifespan{begin} = $entity->begin_date->format if !$entity->begin_date->is_empty;
    $lifespan{end} = $entity->end_date->format if !$entity->end_date->is_empty;

    return \%lifespan;
}

sub serializer
{
    my $entity = shift;

    my $serializer;

    for my $class (keys %serializers) {
        if ($entity->isa($class)) {
            return $serializers{$class};
        }
    }

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

    my $opts = $stash->store ($entity);
    my $list = $opts->{$type};
    my $items = (ref $list eq 'HASH') ? $list->{items} : $list;

    return [
        map { serialize_entity($_, $inc, $stash, $toplevel) }
        sort_by { $_->gid } @$items ];
}

sub count_of
{
    my ($entity, $inc, $stash, $type, $toplevel) = @_;

    my $opts = $stash->store ($entity);
    my $list = $opts->{$type};
    my $items = (ref $list eq 'HASH') ? $list->{items} : $list;

    return number (scalar @$items);
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
