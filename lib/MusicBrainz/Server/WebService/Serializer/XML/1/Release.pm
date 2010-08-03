package MusicBrainz::Server::WebService::Serializer::XML::1::Release;
use Moose;
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw(serialize_entity);

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::ArtistCredit';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Relationships';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Tags';

use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';
use aliased 'MusicBrainz::Server::Entity::Recording';
use aliased 'MusicBrainz::Server::WebService::Entity::1::ReleaseEvent';

sub element { 'release'; }

before 'serialize' => sub
{
    my ($self, $entity, $inc, $opts) = @_;

    $self->attributes->{type} = join (" ", $entity->release_group->type->name, $entity->status->name);

    $self->add( $self->gen->title($entity->name) );

    $self->add( $self->gen->text_representation({
        language => uc($entity->language->iso_code_3b),
        script => $entity->script->iso_code,
    }));

    my @asins = grep { $_->link->type->name eq 'amazon asin' } @{$entity->relationships};
    foreach (@asins)
    {
        # FIXME: use aCiD2's coverart/amazon stuff to get the ASIN.
        $self->add( $self->gen->asin("".$2) )
            if ($_->target->url =~
                m{^http://(?:www.)?(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i);
    }

    # If the release appears in a list, then we only want at most the release group gid.
    # If the release is top level however, then we do want release group information
    $self->add( serialize_entity($entity->release_group, undef, { 'gid-only' => $opts->{in_list} } ) )
        if ($inc && $inc->release_groups);

    my $tracklist = 'track-list';
    $self->add( $self->gen->$tracklist({
        offset => $entity->combined_track_count - 1,
    })) if $inc && $inc->tracklist;

    $self->add( List->new->serialize(
        [
            map {
                # Display a recording with the track's name (not the recording's)
                Recording->meta->clone_object(
                    $_->recording,
                    name => $_->name,

                    # We only show track artists if inc=artist, and if this is a
                    # various artist release
                    ($inc && $inc->artist && $_->artist_credit->name ne $entity->artist_credit->name ?
                         (artist_credit => $_->artist_credit) : ())
                );
            }
                map { $_->all_tracks }
                map { $_->tracklist } $entity->all_mediums
        ], $inc)) if $inc && $inc->tracks;

    if ($inc && $inc->release_events) {
        # FIXME - try and find other possible release events
        $self->add(
            List->new( _element => 'release-event' )->serialize([
                map {
                    ReleaseEvent->meta->rebless_instance($_)
                } $entity
            ], $inc)
        )
    }

    $self->add(
        $self->gen->rating(
            { 'rating-count' => $entity->release_group->rating_count },
            $entity->release_group->rating
        )
    ) if $inc && $inc->ratings;

    if ($inc && $inc->discs) {
        $self->add( List->new->serialize([
            map { $_->all_cdtocs } map { $_->all_mediums } $entity
        ]) );
    }

    if ($inc && $inc->counts) {
        my $tracklist = 'track-list';
        my $relist    = 'release-event-list';
        my $disclist  = 'disc-list';

        $self->add( $self->gen->$relist({ count => 1 }) )
            unless $inc->release_events;

        $self->add( $self->gen->$tracklist({
            count => $entity->combined_track_count,
        }));

        $self->add( $self->gen->$disclist({
            count => scalar map { $_->all_cdtocs } map { $_->all_mediums } $entity
        })) unless $inc->discs;
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

