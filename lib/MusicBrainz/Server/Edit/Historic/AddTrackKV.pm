package MusicBrainz::Server::Edit::Historic::AddTrackKV;
use Moose;
use MooseX::Types::Structured qw( Dict Optional );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_TRACK_KV );
use MusicBrainz::Server::Edit::Types qw( Nullable );

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_name     { 'Add track' }
sub historic_type { 18 }
sub edit_type     { $EDIT_HISTORIC_ADD_TRACK_KV }
sub edit_template { 'historic/add_track_kv' }

sub related_entities
{
    my $self = shift;
    return {
        release   => $self->data->{release_ids},
        recording => [ $self->data->{recording_id} ]
    }
}

has '+data' => (
    isa => Dict[
        release_ids  => ArrayRef[Int],
        track_id     => Int,
        recording_id => Int,
        name         => Str,
        # There are some edits with track number as "10 secret track"
        position     => Int | Str,
        length       => Nullable[Int],
        artist_id    => Int,
    ]
);

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
        release_ids  => $self->album_release_ids($self->new_value->{AlbumId}),
        recording_id => $self->resolve_recording_id($self->row_id),
        track_id     => $self->row_id,
        artist_id    => $self->artist_id,
        position     => $self->new_value->{TrackNum},
        name         => $self->new_value->{TrackName},
        length       => $self->new_value->{TrackLength},
    });

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
