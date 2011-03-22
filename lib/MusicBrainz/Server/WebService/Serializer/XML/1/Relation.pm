package MusicBrainz::Server::WebService::Serializer::XML::1::Relation;

use Moose;
use String::CamelCase qw(camelize);
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw(serialize_entity);

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';

sub element { 'relation'; }

before 'serialize' => sub
{
    my ($self, $entity, $inc, $opts) = @_;

    my $type = $entity->link->type->name;
    $type =~ s/\s+/_/g;

    $self->attributes->{type}   = camelize($type);
    $self->attributes->{begin}  = $entity->link->begin_date->format
        unless $entity->link->begin_date->is_empty;

    $self->attributes->{end}    = $entity->link->end_date->format
        unless $entity->link->end_date->is_empty;

    $self->attributes->{direction} = 'backward' if $entity->direction == 2;

    $self->attributes->{attributes} =
        join(' ', map {
            my $s = $_->name;
            $s =~ s/^\s*//;
            $s =~ s/(^|[^A-Za-z0-9])+([A-Za-z0-9]?)/uc $2/eg;
            $s
        } $entity->link->all_attributes) || undef;

    if ($entity->target_type eq 'url')
    {
        $self->attributes->{target} = $entity->target->name;
    }
    elsif ($entity->target_type eq 'artist' ||
           $entity->target_type eq 'label' ||
           $entity->target_type eq 'release' ||
           $entity->target_type eq 'recording')
    {
        $self->attributes->{target} = $entity->target->gid;
        $self->add( serialize_entity($entity->target) );
    }

#         $self->tracklevelrels / track-level-rels

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

