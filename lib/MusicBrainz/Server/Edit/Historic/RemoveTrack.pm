package MusicBrainz::Server::Edit::Historic::RemoveTrack;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_TRACK );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_l('Remove track') }
sub edit_kind     { 'remove' }
sub edit_type     { $EDIT_HISTORIC_REMOVE_TRACK }
sub historic_type { 11 }
sub edit_template { 'historic/RemoveTrack' }

use aliased 'MusicBrainz::Server::Entity::Recording';

sub _release_ids
{
    my $self = shift;
    return @{ $self->data->{release_ids} };
}

sub _build_related_entities
{
    my $self = shift;
    return {
        release   => $self->data->{release_ids},
        recording => [ $self->data->{recording_id} ],
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release   => [ map { $_ => ['ArtistCredit'] } $self->_release_ids ],
        Recording => [ $self->data->{recording_id} ]
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        name => $self->data->{name},
        recording => to_json_object(
            $loaded->{Recording}{ $self->data->{recording_id} } ||
            Recording->new( name => $self->data->{name} )
        ),
        releases => [
            map {
                to_json_object($loaded->{Release}{$_})
            } $self->_release_ids
        ]
    }
}

sub upgrade
{
    my $self = shift;

    $self->data({
        name         => $self->previous_value->{name},
        release_ids  => $self->album_release_ids(
            $self->previous_value->{album_id}),
        recording_id => $self->resolve_recording_id($self->row_id),
    });

    return $self;
}

sub deserialize_previous_value
{
    my ($self, $value) = @_;

    my ($name, $album_id) = split /\n/, $value;

    return {
        name     => $name,
        album_id => $album_id,
    }
}

1;
