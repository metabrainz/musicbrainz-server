package MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils;

use warnings;
use strict;

use base 'Exporter';
use Class::Load qw( load_class );

our @EXPORT_OK = qw(
    serializer
    serialize_entity
);

#        ArtistCredit
#        CDStubTOC
#        CDTOC
#        Collection
#        Instrument
#        Medium
#        Recording
#        Relationship
#        Series
#        URL
#        Work

my %serializers =
    map {
        my $class = "MusicBrainz::Server::WebService::Serializer::JSON::LD::$_";
        load_class($class);
        "MusicBrainz::Server::Entity::$_" => $class->new
    } qw(
        Area
        Artist
        Label
        Place
        Release
        ReleaseGroup
    );

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
