package MusicBrainz::Server::Edit::Historic::SetTrackLengthsFromCDTOC;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Track;
use MusicBrainz::Server::Edit::Historic::Base;

use aliased 'MusicBrainz::Server::Entity::Medium';
use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_name     { N_l('Set track lengths') }
sub edit_kind     { 'other' }
sub historic_type { 53 }
sub edit_type     { $EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC }
sub edit_template { 'set_track_lengths' }

sub _build_related_entities
{
    my $self = shift;
    return {
        artist  => [ $self->artist_id ],
        release => $self->data->{release_ids},
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release => { map { $_ => [ 'ArtistCredit' ] } @{ $self->data->{release_ids} } },
        CDTOC => [ $self->data->{cdtoc} ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        mediums => [ map { Medium->new( release => $loaded->{Release}{$_} // Release->new() ) } @{ $self->data->{release_ids} } ],
        cdtoc => $loaded->{CDTOC}{ $self->data->{cdtoc} },
        length => {
            map {
                $_ => [ map { MusicBrainz::Server::Track::UnformatTrackLength($_) }
                            split /\s+(?!ms)/, $self->data->{$_}{lengths} ]
            } qw( old new)
        },
    }
}

sub upgrade
{
    my $self = shift;

    my ($cdtoc, $lengths) = split(/\n/, $self->new_value);
    $cdtoc =~ s/CDTOCId=//;
    $lengths =~ s/NewDurs=//;

    $self->data({
        release_ids => $self->album_release_ids($self->row_id),
        cdtoc    => $cdtoc,
        old      => { lengths => $self->previous_value },
        new      => { lengths => $lengths },
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
