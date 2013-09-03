package MusicBrainz::Server::WebService::Serializer::XML::1::Recording;
use Moose;

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Tags';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Rating';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Relationships';

use List::UtilsBy qw( sort_by );

use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw(serialize_entity list_of);

sub element { 'track'; }

sub serialize
{
    my ($self, $entity, $inc, $opts) = @_;
    my @body;

    push @body, ( $self->gen->title($entity->name) );
    push @body, ( $self->gen->duration($entity->length) ) if $entity->length;

    push @body, ( serialize_entity($entity->artist_credit) )
        if $entity->artist_credit;

    $inc && $inc->artist(0);

    push @body, ( list_of($entity->isrcs) )
        if $inc && $inc->isrcs;

    # FIXME This is hackish
    # Because a recording might appear multiple times on the same release,
    # we have to create a new release for each track and "stuff" the offset
    # into the release. See also Release.pm
    push @body, (
        list_of([
            sort_by { $_->gid }
            map {
                my ($release_id, $offset) = @$_;
                my $release = $opts->{releases}{$release_id};
                my $track_release = $release->meta->clone_object(
                    $release
                );
                $track_release->{track_offset} = $offset;
                $track_release;
            } @{ $opts->{track_map} }
        ], $inc, $opts)
    ) if $inc && $inc->releases;

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

