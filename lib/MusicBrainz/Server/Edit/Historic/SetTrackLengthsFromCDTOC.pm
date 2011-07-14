package MusicBrainz::Server::Edit::Historic::SetTrackLengthsFromCDTOC;
use strict;
use warnings;

use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC );
use MusicBrainz::Server::Translation qw ( l ln );

use MusicBrainz::Server::Edit::Historic::Base;

sub edit_name     { l('Set track lengths from discid') }
sub historic_type { 53 }
sub edit_type     { $EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC }

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
        releases => [ map { $loaded->{Release}->{$_} } @{ $self->data->{release_ids} } ],
        cdtoc => $loaded->{CDTOC}->{$self->data->{cdtoc}},
        lengths => {
            new => $self->data->{new}{lengths},
            old => $self->data->{old}{lengths},
        },
    }
}

sub upgrade
{
    my $self = shift;

    my ($cdtoc, $lengths) = split (/\n/, $self->new_value);
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
