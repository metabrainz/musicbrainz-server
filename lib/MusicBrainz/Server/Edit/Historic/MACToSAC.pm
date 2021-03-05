package MusicBrainz::Server::Edit::Historic::MACToSAC;
use strict;
use warnings;

use MusicBrainz::Server::Edit::Historic::Base;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MAC_TO_SAC );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::Entity::Artist';

sub edit_name     { N_l('Convert release to single artist (historic)') }
sub edit_kind     { 'other' }
sub historic_type { 13 }
sub edit_type     { $EDIT_HISTORIC_MAC_TO_SAC }
sub edit_template_react { 'historic/ChangeReleaseArtist' }

sub _build_related_entities {
    my $self = shift;
    return {
        artist => [ $self->data->{old_artist_id}, $self->data->{new_artist_id} ],
        release => [ $self->_release_ids ]
    }
}

sub _release_ids
{
    my $self = shift;
    return @{ $self->data->{release_ids} };
}

sub foreign_keys
{
    my $self = shift;
    return {
        Artist  => [ $self->data->{old_artist_id}, $self->data->{new_artist_id} ],
        Release => [ $self->_release_ids ]
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $new_artist = $loaded->{Artist}{ $self->data->{new_artist_id} } ||
        Artist->new();

    $new_artist = $new_artist->meta->clone_object(
        $new_artist,
        name => $self->data->{artist_name}
    );

    return {
        releases => [ map {
            to_json_object($loaded->{Release}{$_})
        } $self->_release_ids ],
        artist => {
            old => to_json_object($loaded->{Artist}{ $self->data->{old_artist_id} }),
            new => to_json_object($new_artist),
        }
    }
}

sub upgrade
{
    my ($self) = @_;

    my $target = $self->artist_id == 1 ? $self->new_value->{artist_id} :
                                         $self->artist_id;

    $self->data({
        release_ids   => $self->album_release_ids($self->row_id),
        artist_name   => $self->new_value->{name},
        new_artist_id => $target || 0,
        old_artist_id => 1
    });

    return $self;
}

sub deserialize_new_value
{
    my ($self, $value) = @_;

    my %deserialized;
    if ($value =~ /\n/) {
        @deserialized{qw( sort_name name artist_id move_tracks)} =
            split /\n/, $value;

        if ($deserialized{'name'} =~ /\A\d+\z/ && !defined $deserialized{'artist_id'})
        {
            $deserialized{'move_tracks'} = $deserialized{'artist_id'};
            $deserialized{'artist_id'}   = $deserialized{'name'};
        }

        $deserialized{'name'} = delete $deserialized{sort_name};
    }
    else {
        $deserialized{move_tracks} = 0;
        $deserialized{artist_id} = 0;
        $deserialized{name} = $value;
    }

    return \%deserialized;
}

1;
