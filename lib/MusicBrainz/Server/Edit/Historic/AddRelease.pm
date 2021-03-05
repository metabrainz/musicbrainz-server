package MusicBrainz::Server::Edit::Historic::AddRelease;

use strict;
use warnings;
use MusicBrainz::Server::Edit::Historic::Base;

use List::MoreUtils qw( uniq );
use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::Label';
use aliased 'MusicBrainz::Server::Entity::Recording';

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_ADD_RELEASE );
use MusicBrainz::Server::Edit::Historic::Utils qw( upgrade_date upgrade_id upgrade_type_and_status );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

sub edit_name     { N_l('Add release') }
sub edit_kind     { 'add' }
sub historic_type { 16 }
sub edit_type     { $EDIT_HISTORIC_ADD_RELEASE }
sub edit_template_react { 'historic/AddRelease' }

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

sub foreign_keys {
    my $self = shift;

    my $data = $self->data;

    my $fks = {
        Artist        => [ $self->_artist_ids ],
        Area          => [ map { $_->{country_id} } $self->_release_events ],
        Label         => [ map { $_->{label_id} } $self->_release_events ],
        MediumFormat  => [ map { $_->{format_id} } $self->_release_events ],
        Recording     => [ $self->_recording_ids ],
        Release       => [ $self->_release_ids ],
    };

    $fks->{Language} = [$data->{language_id}] if $data->{language_id};
    $fks->{ReleaseGroupType} = [$data->{type_id}] if $data->{type_id};
    $fks->{ReleaseStatus} = [$data->{status_id}] if $data->{status_id};
    $fks->{Script} = [$data->{script_id}] if $data->{script_id};

    return $fks;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $artist = defined($self->data->{artist_id})
        ? to_json_object(
            $loaded->{Artist}{ $self->data->{artist_id} } ||
            Artist->new(
                id => $self->data->{artist_id},
                name => $self->data->{artist_name},
            ),
        )
        : undef;

    return {
        name           => $self->data->{name},
        artist         => $artist,
        releases       => [
            map { to_json_object($loaded->{Release}{$_}) }
            grep { defined } $self->_release_ids
        ],
        status         => defined($self->data->{status_id}) &&
                            to_json_object($loaded->{ReleaseStatus}{ $self->data->{status_id} }),
        type           => defined($self->data->{type_id}) &&
                            to_json_object($loaded->{ReleaseGroupType}{ $self->data->{type_id} }),
        language       => defined($self->data->{language_id}) &&
                            to_json_object($loaded->{Language}{ $self->data->{language_id} }),
        script         => defined($self->data->{script_id}) &&
                            to_json_object($loaded->{Script}{ $self->data->{script_id} }),
        release_events => [
            map { +{
                country        => defined($_->{country_id}) &&
                                    to_json_object($loaded->{Area}{ $_->{country_id} }),
                date           => to_json_object(MusicBrainz::Server::Entity::PartialDate->new_from_row( $_->{date} )),
                label          => $_->{label_id}
                    ? to_json_object($loaded->{Label}{ $_->{label_id} } || Label->new( id => $_->{label_id} ))
                    : undef,
                catalog_number => $_->{catalog_number},
                barcode        => $_->{barcode},
                format         => defined($_->{format_id}) &&
                                    to_json_object($loaded->{MediumFormat}{ $_->{format_id} })
            } } $self->_release_events
        ],
        tracks => [
            map {
                # Stuff that had artist_name present did not actually have an artist ID
                my $track_artist = to_json_object(defined($_->{artist_name})
                    ? Artist->new(
                        id => $_->{artist_id},
                        name => $_->{artist_name},
                    ) : $loaded->{Artist}{ $_->{artist_id} }
                        || Artist->new( id => $_->{artist_id} ));

                # Our code expects undef, not 0, for length unknown, but older edits have 0
                my $track_length = defined $_->{length} && $_->{length} == 0
                    ? undef
                    : $_->{length};

                +{
                    name      => $_->{name},
                    artist    => $track_artist,
                    length    => $track_length,
                    position  => $_->{position},
                    recording => to_json_object(defined($_->{recording_id}) &&
                                    $loaded->{Recording}{ $_->{recording_id} } || Recording->new(
                                        id => $_->{recording_id},
                                        name => $_->{name},
                                    )),
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
