package MusicBrainz::Server::WebService::Serializer::JSON::2::Medium;
use Moose;
use JSON;
use List::UtilsBy qw( nsort_by sort_by );
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw( number serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{title} = $entity->name;
    $body{format} = $entity->format ? $entity->format->name : JSON::null;
    $body{'format-id'} = $entity->format ? $entity->format->gid : JSON::null;
    $body{position} = $entity->position;

    if (defined $inc && $inc->discids)
    {
        $body{discs} = [ map {
            serialize_entity($_->cdtoc, $inc, $stash)
        } sort_by { $_->cdtoc->discid } $entity->all_cdtocs ];
    }

    $body{'track-count'} = number($entity->cdtoc_track_count);

    # Not all tracks in the tracklists may have been loaded.  If not all
    # tracks have been loaded, only one them will have been loaded which
    # therefore can be represented as if a query had been performed with
    # limit = 1 and offset = track->position.

    my @tracks = nsort_by { $_->position } $entity->all_tracks;
    my $min = scalar @tracks ? $tracks[0]->position : 0;

    if (@tracks && $entity->has_pregap) {
        $body{pregap} = $self->serialize_track($tracks[0], $inc, $stash);
    }

    my @list;
    foreach my $track_entity (@{ $entity->cdtoc_tracks }) {
        push @list, $self->serialize_track($track_entity, $inc, $stash);
    }

    if (scalar @list) {
        $body{tracks} = \@list ;
        $body{'track-offset'} = number($entity->has_pregap ? 0 : $min - 1);
    }

    if (my @data_tracks = grep { $_->position > 0 && $_->is_data_track } @tracks) {
        $body{'data-tracks'} = [ map { $self->serialize_track($_, $inc, $stash) } @data_tracks ];
    }

    return \%body;
};

sub serialize_track {
    my ($self, $entity, $inc, $stash) = @_;

    my %track_output = (
        id => $entity->gid,
        length => $entity->length,
        number => $entity->number,
        position => $entity->position,
        title => $entity->name,
    );

    if ($inc->recordings) {
        local $stash->{track_artist_credit} = $entity->artist_credit;
        $track_output{recording} = serialize_entity($entity->recording, $inc, $stash);
    }

    $track_output{'artist-credit'} = serialize_entity($entity->artist_credit, $inc, $stash)
        if $inc->artist_credits;

    return \%track_output;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

