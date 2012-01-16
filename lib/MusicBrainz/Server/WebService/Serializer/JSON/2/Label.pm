package MusicBrainz::Server::WebService::Serializer::JSON::2::Label;
use Moose;

use List::UtilsBy 'sort_by';
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( list_of );
use String::CamelCase qw(camelize);

with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::LifeSpan';
# with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Rating';
# with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Relationships';
# with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Tags';

sub element { 'label'; }

sub serialize
{
    my ($self, $entity, $inc, $opts) = @_;
    my %body;

    $body{'name'} = $entity->name;
    $body{'sort-name'} = $entity->sort_name;
    $body{'label-code'} = $entity->label_code if $entity->label_code;
    $body{'disambiguation'} = $entity->comment if $entity->comment;
    $body{'country'} = $entity->country->iso_code if $entity->country;

    return %body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2011 MetaBrainz Foundation

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

