package MusicBrainz::Server::WebService::Serializer::XML::1::Utils;

use base 'Exporter';
use Readonly;

use String::CamelCase qw(camelize);

our @EXPORT_OK = qw(
    serializer
    serialize_entity
    map_type
);

Readonly my %ENTITY_TO_SERIALIZER => (
    'MusicBrainz::Server::Entity::AggregatedTag' => 'MusicBrainz::Server::WebService::Serializer::XML::1::AggregatedTag',
    'MusicBrainz::Server::Entity::Artist' => 'MusicBrainz::Server::WebService::Serializer::XML::1::Artist',
    'MusicBrainz::Server::Entity::ArtistAlias' => 'MusicBrainz::Server::WebService::Serializer::XML::1::Alias',
    'MusicBrainz::Server::Entity::ArtistCredit' => 'MusicBrainz::Server::WebService::Serializer::XML::1::ArtistCredit',
    'MusicBrainz::Server::Entity::CDStub' => 'MusicBrainz::Server::WebService::Serializer::XML::1::CDStub',
    'MusicBrainz::Server::Entity::Editor' => 'MusicBrainz::Server::WebService::Serializer::XML::1::Editor',
    'MusicBrainz::Server::Entity::ISRC' => 'MusicBrainz::Server::WebService::Serializer::XML::1::ISRC',
    'MusicBrainz::Server::Entity::Label' => 'MusicBrainz::Server::WebService::Serializer::XML::1::Label',
    'MusicBrainz::Server::Entity::MediumCDTOC' => 'MusicBrainz::Server::WebService::Serializer::XML::1::CDTOC',
    'MusicBrainz::Server::Entity::LabelAlias' => 'MusicBrainz::Server::WebService::Serializer::XML::1::Alias',
    'MusicBrainz::Server::Entity::PUID' => 'MusicBrainz::Server::WebService::Serializer::XML::1::PUID',
    'MusicBrainz::Server::Entity::RecordingPUID' => 'MusicBrainz::Server::WebService::Serializer::XML::1::RecordingPUID',
    'MusicBrainz::Server::Entity::Recording' => 'MusicBrainz::Server::WebService::Serializer::XML::1::Recording',
    'MusicBrainz::Server::Entity::Relationship' => 'MusicBrainz::Server::WebService::Serializer::XML::1::Relation',
    'MusicBrainz::Server::Entity::Release' => 'MusicBrainz::Server::WebService::Serializer::XML::1::Release',
    'MusicBrainz::Server::Entity::ReleaseGroup' => 'MusicBrainz::Server::WebService::Serializer::XML::1::ReleaseGroup',
    'MusicBrainz::Server::Entity::SearchResult' => 'MusicBrainz::Server::WebService::Serializer::XML::1::SearchResult',
    'MusicBrainz::Server::Entity::Tag' => 'MusicBrainz::Server::WebService::Serializer::XML::1::Tag',
    'MusicBrainz::Server::Entity::UserTag' => 'MusicBrainz::Server::WebService::Serializer::XML::1::UserTag',
    'MusicBrainz::Server::WebService::Entity::1::ReleaseEvent' => 'MusicBrainz::Server::WebService::Serializer::XML::1::ReleaseEvent'
);

sub serializer
{
    my $entity = shift;

    my $class = $ENTITY_TO_SERIALIZER{$entity->meta->name};

    Class::MOP::load_class($class);

    return $class;
}

sub serialize_entity
{
    return unless defined $_[0];
    return serializer($_[0])->new->serialize(@_);
}

my %type_map = (
    recording => 'Track',
);

sub map_type {
    my $type = lc shift;
    return $type_map{$type} || camelize($type);
}

1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
