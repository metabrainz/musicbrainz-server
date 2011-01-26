package MusicBrainz::Server::Edit::Historic::ChangeTrackArtist;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_CHANGE_TRACK_ARTIST );
use MusicBrainz::Server::Translation qw ( l ln );

use MusicBrainz::Server::Edit::Historic::Base;

use aliased 'MusicBrainz::Server::Entity::Artist';

sub edit_name     { l('Change track artist') }
sub edit_type     { $EDIT_HISTORIC_CHANGE_TRACK_ARTIST }
sub historic_type { 10 }

sub related_entities {
    my $self = shift;
    return {
        artist    => [ $self->data->{new_artist_id}, $self->data->{old_artist_id} ],
        recording => [ $self->data->{recording_id} ]
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Artist    => [ $self->data->{new_artist_id}, $self->data->{old_artist_id} ],
        Recording => [ $self->data->{recording_id} ]
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        recording => $loaded->{Recording}->{ $self->data->{recording_id} },
        artist => {
            old => Artist->meta->clone_instance(
                $loaded->{Artist}->{ $self->data->{old_artist_id} },
                name => $self->data->{old_artist_name}
            ),
            new => $loaded->{Artist}->{ $self->data->{new_artist_id} },
        }
    }
}

sub upgrade
{
    my $self = shift;

    $self->data({
        recording_id    => $self->resolve_recording_id($self->row_id),
        old_artist_id   => $self->artist_id,
        old_artist_name => $self->previous_value,
        new_artist_id   => $self->new_value->{artist_id},
        new_artist_name => $self->new_value->{name},
    });

    return $self;
}

sub deserialize_previous_value { return $_[1] }

sub deserialize_new_value
{
    my ($self, $value) = @_;

    my ($name, $sort_name, $id) = split /\n/, $value;
    return {
        name      => $name,
        sort_name => $sort_name,
        artist_id => $id || 0  # Some edits appear to lack this - 1792375
    }
}

1;
