package MusicBrainz::Server::WebService::Serializer::JSON::LD::Recording;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( list_or_single serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::LD';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Name';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Length';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Producer';

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    $ret->{'@type'} = 'MusicRecording';

    if ($stash->store($entity)->{trackNumber}) {
        $ret->{trackNumber} = $stash->store($entity)->{trackNumber};
    }

    if ($entity->all_isrcs) {
       $ret->{'isrc'} = list_or_single(map { $_->isrc } $entity->all_isrcs);
    }

    my @works = @{ $entity->relationships_by_link_type_names('performance') };
    if (@works) {
        $ret->{recordingOf} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @works);
    }

    return $ret;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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

