package MusicBrainz::Server::WebService::Serializer::JSON::LD::Release;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::LD';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Name';

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    $ret->{'@type'} = 'MusicRelease';
    if ($entity->all_events) {
        $ret->{hasReleaseRegion} = [
            map { release_event($_, $inc, $stash) } $entity->all_events
        ];
    }

    return $ret;
};

sub release_event {
    my ($event, $inc, $stash) = @_;
    my $ret = {'@type' => 'CreativeWorkReleaseRegion'};
    if ($event->date) {
        $ret->{releaseDate} = $event->date->format;
    }
    if ($event->country) {
        $ret->{releaseCountry} = serialize_entity($event->country, $inc, $stash)
    }
    return $ret;
}

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

