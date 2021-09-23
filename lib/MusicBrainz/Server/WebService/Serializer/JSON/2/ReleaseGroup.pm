package MusicBrainz::Server::WebService::Serializer::JSON::2::ReleaseGroup;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( serialize_entity list_of );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{title} = $entity->name;
    $body{'primary-type'} = $entity->primary_type
        ? $entity->primary_type->name : JSON::null;
    $body{'primary-type-id'} = $entity->primary_type
        ? $entity->primary_type->gid : JSON::null;
    $body{'secondary-types'} = [ map {
        $_->name } $entity->all_secondary_types ];
    $body{'secondary-type-ids'} = [ map {
        $_->gid } $entity->all_secondary_types ];
    $body{'first-release-date'} = $entity->first_release_date->format;
    $body{disambiguation} = $entity->comment // '';

    $body{'artist-credit'} = serialize_entity($entity->artist_credit, $inc, $stash)
        if $inc && ($inc->artist_credits || $inc->artists);

    $body{releases} = list_of($entity, $inc, $stash, 'releases')
        if $inc && $inc->releases;

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

