package MusicBrainz::Server::WebService::Serializer::XML::1::Artist;
use Moose;
use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';

use MusicBrainz::Server::WebService::Mapping::1 qw( map_type );

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::LifeSpan';

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

    $self->add( List->new->serialize($opts->{releases}, $inc) )
        if ($inc && $inc->releases);

    $self->add( List->new->serialize($opts->{release_groups}) )
        if ($inc && $inc->release_groups);

    if ($inc && $inc->has_rels) {
        my %by_type;
        for my $relationship (@{ $entity->relationships }) {
            $by_type{ $relationship->target_type } ||= [];
            push @{ $by_type{ $relationship->target_type } },
                $relationship;
        }

        while (my ($type, $relationships) = each %by_type) {
            $self->add(
                List->new->serialize({ 'target-type' => map_type($type) }, $relationships)
            )
        }
    }

    if ($inc && $inc->tags) {
        $self->add( List->new->serialize($opts->{tags}) );
    }
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

