package MusicBrainz::Server::WebService::Serializer::JSON::2::Area;
use Moose;

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Aliases';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Annotation';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::LifeSpan';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Relationships';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Tags';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{name} = $entity->name;
    $body{"sort-name"} = $entity->name;
    $body{disambiguation} = $entity->comment // "";
    $body{'iso-3166-1-codes'} = [$entity->iso_3166_1_codes] if $entity->iso_3166_1_codes;
    $body{'iso-3166-2-codes'} = [$entity->iso_3166_2_codes] if $entity->iso_3166_2_codes;
    $body{'iso-3166-3-codes'} = [$entity->iso_3166_3_codes] if $entity->iso_3166_3_codes;

    if ($toplevel)
    {
        $body{type} = $entity->type_name;
    }

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2013 MetaBrainz Foundation

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

