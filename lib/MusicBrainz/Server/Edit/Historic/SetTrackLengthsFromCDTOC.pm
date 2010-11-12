package MusicBrainz::Server::Edit::Historic::SetTrackLengthsFromCDTOC;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_name     { l('Set track lengths from discid') }
sub historic_type { 53 }
sub edit_type     { $EDIT_HISTORIC_SET_TRACK_LENGTHS_FROM_CDTOC }

sub related_entities
{
    my $self = shift;
    return {
        release => $self->data->{release_ids},
    }
}

has '+data' => (
    isa => Dict[
        release_ids => ArrayRef[Int],
        cdtoc       => Int,
        old         => Dict[lengths => Str],
        new         => Dict[lengths => Str],
    ]
);

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

__PACKAGE__->meta->make_immutable;
no Moose;
1;
