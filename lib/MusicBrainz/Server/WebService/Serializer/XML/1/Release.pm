package MusicBrainz::Server::WebService::Serializer::XML::1::Release;
use Moose;
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw(serialize_entity);

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Relationships';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Tags';

use List::Util 'sum';

use aliased 'MusicBrainz::Server::Entity::Recording';
use aliased 'MusicBrainz::Server::WebService::Entity::1::ReleaseEvent';
use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::ArtistCredit';
use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::List';

sub element { 'release'; }

before 'serialize' => sub
{
    my ($self, $entity, $inc, $opts) = @_;

    $self->attributes->{'ext:score'} = $opts->{score} if $opts && exists $opts->{score};

    my @type_status;
    push @type_status, $entity->release_group->type->name
        if $entity->release_group && $entity->release_group->type;
    push @type_status, $entity->status->name
        if $entity->status;

    $self->attributes->{type} = join (" ", @type_status)
        if @type_status;

    $self->add( $self->gen->title($entity->name) );

    my %lang_script;
    $lang_script{language} = uc($entity->language->iso_code_3b)
        if $entity->language;
    $lang_script{script} = $entity->script->iso_code
        if $entity->script;

    $self->add( $self->gen->text_representation( \%lang_script ))
        if %lang_script;

    my @asins = grep { $_->link->type->name eq 'amazon asin' } @{$entity->relationships};
    foreach (@asins)
    {
        # FIXME: use aCiD2's coverart/amazon stuff to get the ASIN.
        $self->add( $self->gen->asin("".$2) )
            if ($_->target->url =~
                m{^http://(?:www.)?(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i);
        last;
    }

    $self->add( ArtistCredit->new->serialize($entity->artist_credit) )
        if $entity->artist_credit;


    # If the release appears in a list, then we only want at most the release group gid.
    # If the release is top level however, then we do want release group information
    $self->add( serialize_entity($entity->release_group, undef, { 'gid-only' => $opts->{in_list} } ) )
        if ($inc && $inc->release_groups);

    my $tracklist = 'track-list';
    if ($inc && $inc->tracklist) {
        $self->add( $self->gen->$tracklist({
            offset => $entity->combined_track_count - 1,
        }));
    }
    elsif ($opts && $opts->{track_map}) {
        my $track = $opts->{track_map}->{$entity->id};
        $self->add( $self->gen->$tracklist({
            offset => $track->position - 1
        })) if $track;
    }

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
        my @events = grep {
            # Don't do ANYTHING if this is a totally empty release event
            !$_->date->is_empty || $_->country || $_->barcode ||
            $_->combined_format_name ||
            ($inc && $inc->labels && @{ $_->labels });
        }
        map {
            ReleaseEvent->meta->rebless_instance($_)
        } $entity;

        $self->add(
            List->new( _element => 'release-event' )->serialize(\@events, $inc)
        )
    }

    $self->add(
        $self->gen->rating(
            { 'votes-count' => $entity->release_group->rating_count },
            $entity->release_group->rating
        )
    ) if $inc && $inc->ratings;

    $self->add( $self->gen->user_rating(int($entity->release_group->user_rating / 20)) )
        if $entity->release_group && $entity->release_group->user_rating && $inc && $inc->user_ratings;

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

        $self->add( $self->gen->$disclist({
            count => scalar map { $_->all_cdtocs } map { $_->all_mediums } $entity
        })) unless $inc->discs;

        unless (
            $inc->tracklist || $inc->tracks ||
            ($opts && $opts->{track_map}) )
        {
            $self->add( $self->gen->$tracklist({
                count => sum map { $_->tracklist->track_count } $entity->all_mediums
            }) )
        }
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

