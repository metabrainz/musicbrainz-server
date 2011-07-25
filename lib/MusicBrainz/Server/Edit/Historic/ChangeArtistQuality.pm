package MusicBrainz::Server::Edit::Historic::ChangeArtistQuality;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_CHANGE_ARTIST_QUALITY );
use MusicBrainz::Server::Translation qw ( l ln );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { l('Change artist quality') }
sub historic_type { 52 }
sub edit_type     { $EDIT_HISTORIC_CHANGE_ARTIST_QUALITY }

sub _build_related_entities
{
    my $self = shift;
    return {
        artist => [ $self->data->{artist_id} ]
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Artist => [ $self->data->{artist_id} ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        artist => $loaded->{Artist}{ $self->data->{artist_id} },
        quality => {
            old => $self->data->{old}{quality},
            new => $self->data->{new}{quality}
        }
    }
}

sub upgrade
{
    my $self = shift;
    $self->data({
        artist_id => $self->artist_id,
        old       => { quality => $self->previous_value },
        new       => { quality => $self->new_value },
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
