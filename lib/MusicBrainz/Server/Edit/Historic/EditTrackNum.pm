package MusicBrainz::Server::Edit::Historic::EditTrackNum;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_TRACKNUM );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use Scalar::Util qw( looks_like_number );
use MusicBrainz::Server::Translation qw( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

use aliased 'MusicBrainz::Server::Entity::Recording';

sub edit_name     { N_l('Edit track (historic)') }
sub edit_kind     { 'edit' }
sub historic_type { 5 }
sub edit_type     { $EDIT_HISTORIC_EDIT_TRACKNUM }
sub edit_template { 'historic/EditTrack' }

sub _build_related_entities
{
    my $self = shift;
    return {
        release => $self->data->{release_ids}
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => { $self->data->{recording_id} => [ 'ArtistCredit' ] },
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        recording => to_json_object(
            $loaded->{Recording}{ $self->data->{recording_id} } ||
            Recording->new(
                id => $self->data->{recording_id},
            )
        ),
        position => {
            old => $self->data->{old}{position},
            new => $self->data->{new}{position},
        }
    };
}

sub upgrade
{
    my $self = shift;
    unless (looks_like_number($self->new_value) &&
            looks_like_number($self->previous_value)) {
        die 'This data is corrupt and cannot be upgraded';
    }

    $self->data({
        track_id     => $self->row_id,
        recording_id => $self->resolve_recording_id( $self->row_id ),
        old          => { position => $self->previous_value },
        new          => { position => $self->new_value },
        release_ids  => $self->album_release_ids(
            $self->track_to_album( $self->row_id )
        )
    });

    return $self;
}

sub deserialize_new_value {
    my ($self, $value ) = @_;
    return $value;
}

sub deserialize_previous_value {
    my ($self, $value ) = @_;
    return $value;
}

1;
