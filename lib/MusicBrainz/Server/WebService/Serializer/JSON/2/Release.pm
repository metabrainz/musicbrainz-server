package MusicBrainz::Server::WebService::Serializer::JSON::2::Release;
use Moose;
use MusicBrainz::Server::Constants qw( :quality );
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( list_of serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Rating';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Relationships';
with 'MusicBrainz::Server::WebService::Serializer::JSON::2::Role::Tags';

sub _quality
{
    my $quality_id = shift;

    my %quality_names = (
        $QUALITY_LOW => 'low',
        $QUALITY_NORMAL => 'normal',
        $QUALITY_HIGH => 'high'
    );

    return $quality_names{
        $QUALITY_UNKNOWN ? $QUALITY_UNKNOWN_MAPPED : $quality_id };
}

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{title} = $entity->name;
    $body{country} = $entity->country
        ? $entity->country->iso_code : JSON::null;

    $body{asin} = $entity->amazon_asin;
    $body{barcode} = $entity->barcode->code;
    $body{date} = $entity->date->format;
    $body{disambiguation} = $entity->comment;
    $body{status} = $entity->status_name;
    $body{quality} = _quality ($entity->quality);
    $body{packaging} = $entity->packaging
        ? $entity->packaging->name : JSON::null;

    $body{"text-representation"} = {
        script => $entity->script ? $entity->script->iso_code : JSON::null,
        language => $entity->language ? $entity->language->iso_code_3 : JSON::null
    };

    $body{collections} = list_of ($entity, $inc, $stash, "collections")
        if $inc && $inc->collections;

    $body{"release-group"} = serialize_entity ($entity->release_group, $inc, $stash)
        if $inc && $inc->release_groups;

    if ($toplevel)
    {
        $body{"artist-credit"} = serialize_entity ($entity->artist_credit, $inc, $stash, $inc->artists)
            if $inc->artist_credits || $inc->artists;
    }
    else
    {
        $body{"artist-credit"} = serialize_entity ($entity->artist_credit, $inc, $stash)
            if $inc->artist_credits;
    }

    $body{"label-info"} = [
        map {
            {
                "catalog-number" => $_->catalog_number,
                label => serialize_entity ($_->label, $inc, $stash)
            }
        } @{ $entity->labels } ] if $toplevel && $inc->labels;

    if ($inc->media || $inc->discids || $inc->recordings)
    {
        $body{media} = [
            map { serialize_entity($_, $inc, $stash) }
            $entity->all_mediums ];
    }

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

