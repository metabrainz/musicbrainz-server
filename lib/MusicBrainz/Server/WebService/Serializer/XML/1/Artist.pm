package MusicBrainz::Server::WebService::Serializer::XML::1::Artist;
use Moose;
use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::LifeSpan';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Relationships';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Rating';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Tags';

sub element { 'artist'; }

before 'serialize' => sub
{
    my ($self, $entity, $inc, $opts) = @_;

    $self->attributes->{type} = $entity->type->name if $entity->type;

    $self->add($self->gen->name($entity->name));
    $self->add($self->gen->sort_name($entity->sort_name));
    $self->add($self->gen->disambiguation($entity->comment)) if $entity->comment;

    $self->add( $self->lifespan ($entity) ) if $self->has_lifespan ($entity);

    $self->add( List->new->serialize($opts->{aliases}) )
        if ($inc && $inc->aliases);

    $self->add( List->new( sort => sub { $_->gid } )->serialize($opts->{releases}, $inc) )
        if ($inc && $inc->releases);

    $self->add( List->new->serialize($opts->{release_groups}) )
        if ($inc && $inc->release_groups);
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

