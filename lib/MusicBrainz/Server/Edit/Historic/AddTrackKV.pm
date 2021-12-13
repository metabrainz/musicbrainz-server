package MusicBrainz::Server::Edit::Historic::AddTrackKV;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_TRACK_KV );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_l('Add track (historic)') }
sub edit_kind     { 'add' }
sub historic_type { 18 }
sub edit_type     { $EDIT_HISTORIC_ADD_TRACK_KV }
sub edit_template_react { 'historic/AddTrackKV' }

use aliased 'MusicBrainz::Server::Entity::Recording';
use aliased 'MusicBrainz::Server::Entity::Release';

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

    # Some lengths of -1 or 0 ms are stored, which is nonsensical
    # and probably meant as a placeholder for unknown duration
    my $length = $self->data->{length};
    my $display_length = $length <= 0 ? undef : $length;

    return {
        releases => [
            map {
                to_json_object($_ == -42
                    ? Release->new( name => '[non-album tracks]' )
                    : $loaded->{Release}{$_})
            } $self->release_ids
        ],
        position  => $self->data->{position},
        name      => $self->data->{name},
        length    => $display_length,
        artist    => to_json_object($loaded->{Artist}{ $self->data->{artist_id} }),
        recording => to_json_object(
            $loaded->{Recording}{ $self->data->{recording_id} } ||
            Recording->new( name => $self->data->{name} )
        ),
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
