package MusicBrainz::Server::WebService::Serializer::XML::1::Relation;

use Moose;
use String::CamelCase qw(camelize);
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw(serialize_entity);

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';

sub element { 'relation'; }

sub attributes {
    my ($self, $entity, $inc, $opts) = @_;

    my @attrs;

    my $type = $entity->link->type->name;
    $type =~ s/\s+/_/g;

    push @attrs, ( type => camelize($type) );
    push @attrs, ( begin => $entity->link->begin_date->format )
        unless $entity->link->begin_date->is_empty;

    push @attrs, ( end => $entity->link->end_date->format )
        unless $entity->link->end_date->is_empty;

    push @attrs, ( direction => 'backward' )
        if $entity->direction == 2;

    push @attrs, ( attributes =>
        join(' ', map {
            my $s = $_->type->name;
            $s =~ s/\s+/_/g;
            $s = camelize($s);
            $s =~ s/_//g;
            $s;
        } $entity->link->all_attributes) || undef );

    if ($entity->target_type eq 'url')
    {
        push @attrs, ( target => $entity->target->name );
    }
    elsif ($entity->target_type eq 'artist' ||
           $entity->target_type eq 'label' ||
           $entity->target_type eq 'release' ||
           $entity->target_type eq 'recording')
    {
        push @attrs, ( target => $entity->target->gid );
    }

    return @attrs;
}

sub serialize
{
    my ($self, $entity, $inc, $opts) = @_;
    my @body;

    if ($entity->target_type eq 'artist' ||
           $entity->target_type eq 'label' ||
           $entity->target_type eq 'release' ||
           $entity->target_type eq 'recording')
    {
        push @body, ( serialize_entity($entity->target) );
    }

    return @body;

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

