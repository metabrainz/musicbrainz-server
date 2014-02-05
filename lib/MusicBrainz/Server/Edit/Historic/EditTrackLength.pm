package MusicBrainz::Server::Edit::Historic::EditTrackLength;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_TRACK_LENGTH );
use MusicBrainz::Server::Translation qw ( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name { N_l('Edit track length (historic)') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_HISTORIC_EDIT_TRACK_LENGTH }
sub historic_type { 45 }
sub edit_template { 'historic/edit_track_length' }

sub _build_related_entities
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
        length => {
            old => $self->data->{old}->{length},
            new => $self->data->{new}->{length},
        }
    };
}

sub upgrade
{
    my $self = shift;
    $self->data({
        track_id     => $self->row_id,
        recording_id => $self->resolve_recording_id( $self->row_id ),
        old          => { length => $self->previous_value },
        new          => { length => $self->new_value }
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
