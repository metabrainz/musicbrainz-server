package MusicBrainz::Server::Edit::Historic::AddTrackKV;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_TRACK_KV );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_l('Add track') }
sub edit_kind     { 'add' }
sub historic_type { 18 }
sub edit_type     { $EDIT_HISTORIC_ADD_TRACK_KV }
sub edit_template { 'historic/add_track_kv' }

sub _build_related_entities
{
    my $self = shift;
    return {
        artist    => [ $self->data->{artist_id} ],
        release   => $self->data->{release_ids},
        recording => [ $self->data->{recording_id} ]
    }
}

sub release_ids { @{ shift->data->{release_ids} } }

sub foreign_keys
{
    my $self = shift;
    return {
        Release => {
            map { $_ => [ 'ArtistCredit' ] } $self->release_ids
        },
        Artist => [ $self->data->{artist_id} ],
        Recording => [ $self->data->{recording_id} ]
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my @release_ids = @{ $self->data->{release_ids} };
    return {
        releases => [
            map {
                $loaded->{Release}->{ $_ }
            } $self->release_ids
        ],
        position  => $self->data->{position},
        name      => $self->data->{name},
        length    => $self->data->{length},
        artist    => $loaded->{Artist}->{ $self->data->{artist_id} },
        recording => $loaded->{Recording}->{ $self->data->{recording_id} },
    }
}

sub upgrade
{
    my $self = shift;
    $self->data({
        # -1 means we'll turn this into a standalone recording later
        release_ids  => $self->previous_value eq '[non-album tracks]'
            ? [ -42 ]
            : $self->album_release_ids($self->new_value->{AlbumId}),
        recording_id => $self->resolve_recording_id($self->row_id),
        track_id     => $self->row_id,
        artist_id    => $self->artist_id,
        position     => $self->new_value->{TrackNum},
        name         => $self->new_value->{TrackName},
        length       => $self->new_value->{TrackLength},
    });

    return $self;
}

sub deserialize_previous_value { shift; return shift() }

1;
