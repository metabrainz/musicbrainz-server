package MusicBrainz::Server::Edit::Historic::EditTrackNum;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_TRACKNUM );
use Scalar::Util qw( looks_like_number );

use base 'MusicBrainz::Server::Edit::Historic::Fast';

sub edit_type     { $EDIT_HISTORIC_EDIT_TRACKNUM }
sub historic_type { 5 }
sub edit_name     { 'Edit track number' }

sub related_entities
{
    my $self = shift;
    return {
        recording => [ $self->data->{recording_id} ]
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
        recording => $loaded->{Recording}->{ $self->data->{recording_id} },
        position => {
            old => $self->data->{old}->{position},
            new => $self->data->{new}->{position},
        }
    };
}

sub upgrade
{
    my $self = shift;
    unless (looks_like_number($self->new_value) &&
            looks_like_number($self->previous_value)) {
        die "This data is corrupt and cannot be upgraded";
    }

    $self->data({
        track_id     => $self->row_id,
        recording_id => $self->resolve_recording_id( $self->row_id ),
        old          => { position => $self->previous_value },
        new          => { position => $self->new_value }
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
