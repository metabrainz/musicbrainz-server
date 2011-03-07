package MusicBrainz::Server::WebService::Serializer::XML::1::ReleaseGroup;
use Moose;

use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw(serializer serialize_entity);

use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::GID';

sub element { 'release-group'; }

before 'serialize' => sub
{
    my ($self, $entity, $inc, $opts) = @_;

    # a special case, used when the release group is included in an artist lookup.
    return if $opts->{'gid-only'};

    $self->attributes->{type} = $entity->type->name
        if $entity->type;

    $self->add( $self->gen->title($entity->name) );

    $self->add( serialize_entity($entity->artist_credit) )
        if ($inc && $inc->artist);

    $self->add( List->new->serialize($opts->{releases}, $inc) )
        if ($inc && $inc->releases);
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

