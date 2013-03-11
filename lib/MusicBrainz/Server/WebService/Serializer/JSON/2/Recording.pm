package MusicBrainz::Server::WebService::Serializer::JSON::2::Recording;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( serialize_entity list_of );
use List::UtilsBy 'sort_by';

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Annotation';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Rating';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Relationships';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Tags';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{title} = $entity->name;
    $body{disambiguation} = $entity->comment // "";
    $body{length} = $entity->length // JSON::null;

    $body{"artist-credit"} = serialize_entity ($entity->artist_credit)
        if ($entity->artist_credit &&
            ($toplevel || ($inc && $inc->artist_credits)));

    $body{releases} = list_of ($entity, $inc, $stash, "releases")
        if ($toplevel && $inc && $inc->releases);

    return \%body unless defined $inc && ($inc->isrcs || $inc->puids);

    my $opts = $stash->store ($entity);
    $body{isrcs} = [
        map { $_->isrc } sort_by { $_->isrc } @{ $opts->{isrcs} }
        ] if $inc->isrcs;
    $body{puids} = [
        map { $_->puid->puid } sort_by { $_->puid->puid } @{ $opts->{puids} }
        ] if $inc->puids;

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

# =head1 COPYRIGHT

# Copyright (C) 2011,2012 MetaBrainz Foundation

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# =cut

