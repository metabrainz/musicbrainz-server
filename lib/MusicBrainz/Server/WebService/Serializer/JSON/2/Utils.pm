package MusicBrainz::Server::WebService::Serializer::JSON::2::Utils;

use base 'Exporter';
use Readonly;
use List::UtilsBy 'sort_by';

our @EXPORT_OK = qw(
    boolean
    list_of
    number
    serializer
    serialize_entity
);

my %serializers;

Readonly my %ENTITY_TO_SERIALIZER => (
    'MusicBrainz::Server::Entity::Artist' => 'MusicBrainz::Server::WebService::Serializer::JSON::2::Artist',
    'MusicBrainz::Server::Entity::ArtistCredit' => 'MusicBrainz::Server::WebService::Serializer::JSON::2::ArtistCredit',
    'MusicBrainz::Server::Entity::Collection' => 'MusicBrainz::Server::WebService::Serializer::JSON::2::Collection',
    'MusicBrainz::Server::Entity::Label' => 'MusicBrainz::Server::WebService::Serializer::JSON::2::Label',
    'MusicBrainz::Server::Entity::Medium' => 'MusicBrainz::Server::WebService::Serializer::JSON::2::Medium',
    'MusicBrainz::Server::Entity::Recording' => 'MusicBrainz::Server::WebService::Serializer::JSON::2::Recording',
    'MusicBrainz::Server::Entity::Relationship' => 'MusicBrainz::Server::WebService::Serializer::JSON::2::Relation',
    'MusicBrainz::Server::Entity::Release' => 'MusicBrainz::Server::WebService::Serializer::JSON::2::Release',
    'MusicBrainz::Server::Entity::ReleaseGroup' => 'MusicBrainz::Server::WebService::Serializer::JSON::2::ReleaseGroup',
    'MusicBrainz::Server::Entity::Work' => 'MusicBrainz::Server::WebService::Serializer::JSON::2::Work',
);

sub boolean { return (shift) ? JSON::true : JSON::false; }

sub number {
    my $value = shift;
    return defined $value ? $value + 0 : JSON::null;
}

sub serializer
{
    my $entity = shift;

    my $class = $ENTITY_TO_SERIALIZER{$entity->meta->name};

    Class::MOP::load_class($class);

    $serializers{$class} ||= $class->new;
    return $serializers{$class};
}

sub serialize_entity
{
    return unless defined $_[0];
    return serializer($_[0])->serialize(@_);
}

sub list_of
{
    my ($entity, $inc, $stash, $type) = @_;

    my $opts = $stash->store ($entity);
    my $list = $opts->{$type};
    my $items = (ref $list eq 'HASH') ? $list->{items} : $list;

    return [
        map { serialize_entity($_, $inc, $opts) }
        sort_by { $_->gid } @$items ];
}

1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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
