package MusicBrainz::Server::WebService::Serializer::JSON::LD::Work;
use Moose;

use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( list_or_single serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::LD';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Genre';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Name';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Aliases';

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    $ret->{'@type'} = 'MusicComposition';

    if ($entity->all_iswcs) {
       $ret->{'iswcCode'} = list_or_single(map { $_->iswc } $entity->all_iswcs);
    }

    my @languages = $entity->all_languages;
    if (@languages) {
        $ret->{inLanguage} =
            list_or_single(map { $_->language->bcp47 } @languages);
    }

    if ($toplevel) {
        my @recordings = @{ $entity->relationships_by_link_type_names('performance') };
        if (@recordings) {
            $ret->{recordedAs} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @recordings);
        }

        my @composers =  @{ $entity->relationships_by_link_type_names('composer', 'writer') };
        if (@composers) {
            $ret->{composer} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @composers);
        }

        my @lyricists =  @{ $entity->relationships_by_link_type_names('lyricist') };
        if (@lyricists) {
            $ret->{lyricist} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @lyricists);
        }

        my @publishers = @{ $entity->relationships_by_link_type_names('publishing') };
        if (@publishers) {
            $ret->{publisher} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @publishers);
        }

        my @subworks = grep { $_->direction == 1 } @{ $entity->relationships_by_link_type_names('parts') };
        if (@subworks) {
            $ret->{includedComposition} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @subworks);
        }

        my @arrangements = (
            (grep { $_->direction == 1 } @{ $entity->relationships_by_link_type_names('arrangement') }),
            (grep { $_->direction == 2 } @{ $entity->relationships_by_link_type_names('medley') }),
        );

        if (@arrangements) {
            $ret->{musicArrangement} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @arrangements);
        }
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

