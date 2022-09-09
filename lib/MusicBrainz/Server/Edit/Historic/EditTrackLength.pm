package MusicBrainz::Server::Edit::Historic::EditTrackLength;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_TRACK_LENGTH );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

use aliased 'MusicBrainz::Server::Entity::Recording';

sub edit_name { N_l('Edit recording') }
sub edit_kind { 'edit' }
sub edit_type { $EDIT_HISTORIC_EDIT_TRACK_LENGTH }
sub historic_type { 45 }
sub edit_template { 'EditRecording' }

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

    # Some lengths of -1 or 0 ms are stored, which is nonsensical
    # and probably meant as a placeholder for unknown duration
    my $old_length = $self->data->{old}{length};
    my $old_display_length = $old_length <= 0 ? undef : $old_length;
    my $new_length = $self->data->{new}{length};
    my $new_display_length = $new_length <= 0 ? undef : $new_length;

    return {
        recording => to_json_object(
            $loaded->{Recording}{ $self->data->{recording_id} } ||
            Recording->new( id => $self->data->{recording_id} )
        ),
        length => {
            old => $old_display_length,
            new => $new_display_length,
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
