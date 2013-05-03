package MusicBrainz::Server::WebService::Serializer::XML::1::Release;
use Moose;
use MusicBrainz::Server::WebService::Serializer::XML::1::Utils qw( list_of serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::XML::1';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Relationships';
with 'MusicBrainz::Server::WebService::Serializer::XML::1::Role::Tags';

use List::Util 'sum';

use aliased 'MusicBrainz::Server::Entity::Recording';
use aliased 'MusicBrainz::Server::WebService::Entity::1::ReleaseEvent';
use aliased 'MusicBrainz::Server::WebService::Serializer::XML::1::ArtistCredit';

sub element { 'release'; }

sub attributes {
    my ($self, $entity, $inc, $opts) = @_;
    my @attr;

    push @attr, ( 'ext:score' => $opts->{score} )
        if $opts && exists $opts->{score};

    my @type_status;
    push @type_status, $entity->release_group->primary_type->name
        if $entity->release_group && $entity->release_group->primary_type;
    push @type_status, $entity->status->name
        if $entity->status;

    push @attr, ( type => join (" ", @type_status) )
        if @type_status;

    return @attr;
}

sub serialize
{
    my ($self, $entity, $inc, $opts) = @_;
    my @body;

    push @body, ( $self->gen->title($entity->name) );

    my %lang_script;
    $lang_script{language} = uc($entity->language->iso_code_3 // $entity->language->iso_code_2t)
        if $entity->language;
    $lang_script{script} = $entity->script->iso_code
        if $entity->script;

    push @body, ( $self->gen->text_representation( \%lang_script ))
        if %lang_script;

    my @asins = grep { $_->link->type->name eq 'amazon asin' } @{$entity->relationships};
    foreach (@asins)
    {
        # FIXME: use aCiD2's coverart/amazon stuff to get the ASIN.
        push @body, ( $self->gen->asin("".$2) )
            if ($_->target->url =~
                m{^http://(?:www.)?(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)}i);
        last;
    }

    push @body, ( serialize_entity($entity->artist_credit) )
        if $entity->artist_credit;


    # If the release appears in a list, then we only want at most the release group gid.
    # If the release is top level however, then we do want release group information
    push @body, ( serialize_entity($entity->release_group, undef, { 'gid-only' => $opts->{in_list} } ) )
        if ($inc && $inc->release_groups);

    my $tracklist = 'track-list';
    if ($inc && $inc->tracklist) {
        push @body, ( $self->gen->$tracklist({
            offset => (sum map { $_->track_count } $entity->all_mediums) - 1
        }));
    }
    elsif ($opts && $opts->{track_map}) {
        # FIXME This is fairly hackish
        # $entity->{track_offset} breaks encapsulation. It is defined in
        # Recording.pm
        my $offset = $entity->{track_offset};
        push @body, ( $self->gen->$tracklist({
            offset => $offset
        })) if defined($offset);
    }

    if ($inc && $inc->tracks) {
        push @body, ( list_of(
            [
                map {
                    # Display a recording with the track's name (not the recording's)
                    Recording->meta->clone_object(
                        $_->recording,
                        name => $_->name,
                        length => $_->length,

                        # We only show track artists if inc=artist, and if this is a
                        # various artist release
                        ($inc && $inc->artist && $_->artist_credit->name ne $entity->artist_credit->name ?
                             (artist_credit => $_->artist_credit) : ())
                    );
                }
                map { $_->all_tracks } $entity->all_mediums
            ], $inc));
    }

    if ($inc && $inc->release_events) {
        # FIXME - try and find other possible release events
        my @events = grep {
            # Don't do ANYTHING if this is a totally empty release event
            $_->release->barcode ||
            $_->release->combined_format_name ||
            ($inc && $inc->labels && @{ $_->release->labels });
        }
        map {
            ReleaseEvent->new(
                release => $entity,
                event => $_
            )
        } grep {
            !$_->date->is_empty || $_->country
        }
        $entity->all_events;

        push @body, (
            list_of( \'release-event-list', \@events, $inc )
        )
    }

    push @body, (
        $self->gen->rating(
            { 'votes-count' => $entity->release_group->rating_count },
            defined($entity->release_group->rating) ? int($entity->release_group->rating / 20) : ()
        )
    ) if $inc && $inc->ratings;

    push @body, ( $self->gen->user_rating(int($entity->release_group->user_rating / 20)) )
        if $entity->release_group && $entity->release_group->user_rating && $inc && $inc->user_ratings;

    if ($inc && $inc->discs) {
        push @body, ( list_of([
            map { $_->all_cdtocs } map { $_->all_mediums } $entity
        ]) );
    }

    if ($inc && $inc->counts) {
        my $tracklist = 'track-list';
        my $relist    = 'release-event-list';
        my $disclist  = 'disc-list';

        push @body, ( $self->gen->$relist({ count => 1 }) )
            unless $inc->release_events;

        push @body, ( $self->gen->$disclist({
            count => scalar map { $_->all_cdtocs } map { $_->all_mediums } $entity
        })) unless $inc->discs;

        unless (
            $inc->tracklist || $inc->tracks ||
            ($opts && $opts->{track_map}) )
        {
            push @body, ( $self->gen->$tracklist({
                count => sum map { $_->track_count } $entity->all_mediums
            }) )
        }
    }

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

