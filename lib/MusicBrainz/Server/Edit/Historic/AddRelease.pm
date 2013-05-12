package MusicBrainz::Server::Edit::Historic::AddRelease;

use strict;
use warnings;
use MusicBrainz::Server::Edit::Historic::Base;

use List::MoreUtils qw( uniq );
use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::Label';

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_RELEASE );
use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_date upgrade_id upgrade_type_and_status );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Translation qw ( N_l );

sub edit_name     { N_l('Add release') }
sub historic_type { 16 }
sub edit_type     { $EDIT_HISTORIC_ADD_RELEASE }
sub edit_template { 'historic/add_release' }

sub _recording_ids
{
    my $self = shift;
    return map { $_->{recording_id} } @{ $self->data->{tracks} };
}

sub _release_ids
{
    my $self = shift;
    return @{ $self->data->{release_ids} };
}

sub _artist_ids
{
    my $self = shift;
    return $self->data->{artist_id}, (map { $_->{artist_id} } @{ $self->data->{tracks} });
}

sub _release_events
{
    my $self = shift;
    return @{ $self->data->{release_events} };
}

sub _tracks
{
    my $self = shift;
    return @{ $self->data->{tracks} };
}

sub _build_related_entities
{
    my $self = shift;
    return {
        artist    => [ $self->_artist_ids ],
        recording => [ $self->_recording_ids ],
        release   => [ $self->_release_ids ],
        release_group => $self->data->{release_group_ids},
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Artist        => [ $self->_artist_ids ],
        Area          => [ map { $_->{country_id} } $self->_release_events ],
        Label         => [ map { $_->{label_id} } $self->_release_events ],
        Language      => [ $self->data->{language_id} ],
        MediumFormat  => [ map { $_->{format_id} } $self->_release_events ],
        Recording     => [ $self->_recording_ids ],
        Release       => [ $self->_release_ids ],
        ReleaseStatus => [ $self->data->{status_id} ],
        ReleaseGroupType => [ $self->data->{type_id} ],
        Script        => [ $self->data->{script_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        name           => $self->data->{name},
        artist         => defined($self->data->{artist_id}) &&
                            $loaded->{Artist}->{ $self->data->{artist_id} },
        releases       => [
            map { $loaded->{Release}->{ $_ } } grep { defined } $self->_release_ids
        ],
        status         => defined($self->data->{status_id}) &&
                            $loaded->{ReleaseStatus}->{ $self->data->{status_id} },
        type           => defined($self->data->{type_id}) &&
                            $loaded->{ReleaseGroupType}->{ $self->data->{type_id} },
        language       => defined($self->data->{language_id}) &&
                            $loaded->{Language}->{ $self->data->{language_id} },
        script         => defined($self->data->{script_id}) &&
                            $loaded->{Script}->{ $self->data->{script_id} },
        release_events => [
            map { +{
                country        => defined($_->{country_id}) &&
                                    $loaded->{Area}->{ $_->{country_id} },
                date           => MusicBrainz::Server::Entity::PartialDate->new_from_row( $_->{date} ),
                label          => $_->{label_id}
                    ? ($loaded->{Label}->{ $_->{label_id} } || Label->new( id => $_->{label_id} ))
                    : undef,
                catalog_number => $_->{catalog_number},
                barcode        => $_->{barcode},
                format         => defined($_->{format_id}) &&
                                    $loaded->{MediumFormat}->{ $_->{format_id} }
            } } $self->_release_events
        ],
        tracks => [
            map {
                # Stuff that had artist_name present did not actually have an artist ID
                my $track_artist = defined ($_->{artist_name})
                    ? Artist->new( name => $_->{artist_name} )
                    : $loaded->{Artist}->{ $_->{artist_id} };

                +{
                    name      => $_->{name},
                    artist    => $track_artist,
                    length    => $_->{length},
                    position  => $_->{position},
                    recording => defined($_->{recording_id}) &&
                                   $loaded->{Recording}->{ $_->{recording_id} }
                } } sort { $a->{position} <=> $b->{position} } $self->_tracks
        ]
    }
}

our %status_map = (
    100 => 1,
    101 => 2,
    102 => 3,
    104 => 4,
);

sub upgrade
{
    my ($self) = @_;

    my $release_artist_id = $self->new_value->{_artistid};

    my $data = {
        name           => $self->new_value->{AlbumName},
        artist_id      => $release_artist_id,
        artist_name    => $self->new_value->{Artist} || 'Various Artists',
        release_events => [],
        release_ids    => [],
        tracks         => [],
    };

    if (my $attributes = $self->new_value->{Attributes}) {
        my ($type_id, $status_id) = upgrade_type_and_status($attributes);
        $data->{status_id} = $status_id;
        $data->{type_id} = $type_id;
    }

    if (my $language = $self->new_value->{Language}) {
        my ($language_id, $script_id) = split /,/, $language;
        $data->{language_id} = upgrade_id($language_id);
        $data->{script_id}   = upgrade_id($script_id);
    }

    for (my $i = 0; 1; $i++) {
        my $release_event = $self->new_value->{"Release$i"}
            or last;

        my $release_event_id = $self->new_value->{"Release$i" . 'Id'};
        my ($country_id, $date, $label_id, $catalog_number, $barcode, $format_id) =
            split /,/, $release_event;

        push @{ $data->{release_events} }, {
            country_id     => upgrade_id($country_id),
            date           => upgrade_date($date),
            label_id       => upgrade_id($label_id),
            catalog_number => $catalog_number,
            barcode        => $barcode,
            format_id      => upgrade_id($format_id)
        };

        push @{ $data->{release_ids} }, ($self->resolve_release_id($release_event_id) || ());
    }

    push @{ $data->{release_ids} }, @{ $self->album_release_ids($self->new_value->{_albumid}) };

    $data->{release_group_ids} = [ uniq (
        $self->new_value->{ReleaseGroupID},
        map {
            $self->find_release_group_id($_)
        } @{ $data->{release_ids} }
    )];

    for (my $i = 1; 1; $i++) {
        my $track_name = $self->new_value->{"Track$i"}
            or last;

        my $artist_id = $self->new_value->{"ArtistID$i"} ||
            $release_artist_id;

        my $length = $self->new_value->{"TrackDur$i"};
        my $track_id = $self->new_value->{'Track' . $i . 'Id'};

        push @{ $data->{tracks} }, {
            position     => $i,
            name         => $track_name,
            artist_id    => $artist_id,
            artist_name  => $self->new_value->{"Artist$i"},
            length       => $length,
            recording_id => $self->resolve_recording_id($track_id)
        }
    }

    $self->data($data);
    return $self;
}

1;
