package MusicBrainz::Server::WebService::Serializer::XML::1::Artist;
use Moose;

use List::UtilsBy 'sort_by';
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw( list_of );

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::LifeSpan';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Relationships';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Rating';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Tags';

sub element { 'artist'; }

sub attributes {
    my ($self, $entity) = @_;
    my @attributes;
    push @attributes, ( type => $entity->type->name ) if $entity->type;
    return @attributes;
}

sub serialize
{
    my ($self, $entity, $inc, $opts) = @_;
    my @body;

    push @body, ($self->gen->name($entity->name));
    push @body, ($self->gen->sort_name($entity->sort_name));
    push @body, ($self->gen->disambiguation($entity->comment)) if $entity->comment;

    push @body, ( $self->lifespan($entity) ) if $self->has_lifespan($entity);

    push @body, ( list_of($opts->{aliases}) )
        if ($inc && $inc->aliases);

    push @body, ( list_of([ sort_by { $_->gid } @{$opts->{releases}} ], $inc) )
        if ($inc && $inc->releases);

    push @body, ( list_of($opts->{release_groups}) )
        if ($inc && $inc->release_groups && $inc->rg_type);

    return @body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
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

