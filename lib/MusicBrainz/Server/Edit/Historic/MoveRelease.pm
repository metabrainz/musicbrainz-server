package MusicBrainz::Server::Edit::Historic::MoveRelease;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_MOVE_RELEASE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::Entity::Artist';

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { N_l('Edit release') }
sub edit_kind     { 'edit' }
sub historic_type { 8 }
sub edit_type     { $EDIT_HISTORIC_MOVE_RELEASE }
sub edit_template_react { 'historic/MoveRelease' }

sub _build_related_entities
{
    my $self = shift;
    return {
        artist  => [
            $self->data->{old_artist_id},
            $self->data->{artist_id}
        ],
        release => $self->data->{release_ids},
    }
}

sub release_ids { @{ shift->data->{release_ids} } }

sub foreign_keys
{
    my $self = shift;
    return {
        Release => {
            map { $_ => [ 'ArtistCredit' ] } $self->release_ids
        },
        Artist => [
            $self->data->{old_artist_id},
            $self->data->{artist_id},
        ]
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $new_artist = defined $loaded->{Artist}{ $self->data->{artist_id} }
        ? Artist->meta->clone_object(
            $loaded->{Artist}{ $self->data->{artist_id} },
            name => $self->data->{artist_name},
        )
        : Artist->new(
            id => $self->data->{artist_id},
            name => $self->data->{artist_name} );

    my $old_artist = defined $loaded->{Artist}{ $self->data->{old_artist_id} }
        ? Artist->meta->clone_object(
            $loaded->{Artist}{ $self->data->{old_artist_id} },
            name => $self->data->{old_artist_name},
        )
        : Artist->new(
            id => $self->data->{old_artist_id},
            name => $self->data->{old_artist_name} );

    return {
        releases => [
            map {
                to_json_object($loaded->{Release}{$_})
            } $self->release_ids
        ],
        artist => {
            new => to_json_object($new_artist),
            old => to_json_object($old_artist),
        },
        move_tracks => boolean_to_json($self->data->{move_tracks}),
    }
}

sub upgrade
{
    my $self = shift;
    $self->data({
        release_ids     => $self->album_release_ids($self->row_id),
        old_artist_name => $self->previous_value,
        %{ $self->new_value },
        old_artist_id   => $self->artist_id,
    });

    return $self;
}

sub deserialize_previous_value
{
    my $self = shift;
    return shift;
}

sub deserialize_new_value
{
    my ($self, $new) = @_;

    my %deserialized;

    if ($new =~ /\n/) {
        # new.name might be undef (in which case, name==sortname)
        @deserialized{qw( sort_name artist_name artist_id move_tracks)} = split /\n/, $new;
    }
    else {
        %deserialized = ( artist_name => $new );
    }

    # If the name was blank and the new artist id ended up in its slot, swap the two values
    if ($deserialized{artist_name} =~ /^\d+$/ && !defined $deserialized{artist_id}) {
        $deserialized{move_tracks} = $deserialized{artist_id};
        $deserialized{artist_id}   = $deserialized{artist_name};
    }

    $deserialized{move_tracks} ||= 0;
    $deserialized{artist_id} ||= 0;
    $deserialized{artist_name} = delete $deserialized{sort_name}
        if $deserialized{sort_name};

    return \%deserialized;
}

1;
