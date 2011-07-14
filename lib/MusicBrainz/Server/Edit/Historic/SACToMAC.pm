package MusicBrainz::Server::Edit::Historic::SACToMAC;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw(
    $EDIT_HISTORIC_SAC_TO_MAC
    $VARTIST_ID
);
use MusicBrainz::Server::Translation qw ( l ln );

use aliased 'MusicBrainz::Server::Entity::Artist';

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { l('Convert release to multiple artists') }
sub historic_type { 9 }
sub edit_type     { $EDIT_HISTORIC_SAC_TO_MAC }

sub _build_related_entities
{
    my $self = shift;
    return {
        artist => [ $self->data->{old_artist_id} ],
        release => $self->data->{release_ids}
    }
}

sub release_ids
{
    my $self = shift;
    return @{ $self->data->{release_ids} };
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => {
            map { $_ => [ 'ArtistCredit' ] }
                $self->release_ids
        },
        Artist => [ $VARTIST_ID, $self->data->{old_artist_id} ]
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        releases => [
            map { $loaded->{Release}->{ $_ } }
                $self->release_ids
        ],
        artist => {
            new => $loaded->{Artist}->{ $VARTIST_ID },
            old => $loaded->{Artist}->{ $self->data->{old_artist_id} } ||
                Artist->new( name => $self->data->{old_artist_name} )
        }
    };
}

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids     => $self->album_release_ids($self->row_id),
        old_artist_id   => $self->artist_id,
        old_artist_name => $self->previous_value,
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
