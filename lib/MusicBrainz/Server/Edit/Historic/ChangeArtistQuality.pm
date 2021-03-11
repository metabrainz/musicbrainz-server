package MusicBrainz::Server::Edit::Historic::ChangeArtistQuality;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_CHANGE_ARTIST_QUALITY );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

use aliased 'MusicBrainz::Server::Entity::Artist';

sub edit_name     { N_l('Change artist quality (historic)') }
sub edit_kind     { 'other' }
sub historic_type { 52 }
sub edit_type     { $EDIT_HISTORIC_CHANGE_ARTIST_QUALITY }
sub edit_template_react { 'historic/ChangeArtistQuality' }

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
        artist => to_json_object(
            $loaded->{Artist}{ $self->data->{artist_id} } ||
            Artist->new( id => $self->data->{artist_id} )
        ),
        quality => {
            old => $self->data->{old}{quality} + 0, # force number
            new => $self->data->{new}{quality} + 0, # force number
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
