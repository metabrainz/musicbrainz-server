package MusicBrainz::Server::Edit::Release::AddBarcodes;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_ADD_BARCODES );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Add barcodes' }
sub edit_type { $EDIT_RELEASE_ADD_BARCODES }

has '+data' => (
    isa => Dict[
        submissions => ArrayRef[Dict[
            release_id => Int,
            barcode => Str,
        ]]
    ]
);

sub edit_conditions
{
    return {
        $QUALITY_LOW => {
            duration      => 4,
            votes         => 1,
            expire_action => $EXPIRE_ACCEPT,
            auto_edit     => 0,
        },
        $QUALITY_NORMAL => {
            duration      => 14,
            votes         => 3,
            expire_action => $EXPIRE_ACCEPT,
            auto_edit     => 0,
        },
        $QUALITY_HIGH => {
            duration      => 14,
            votes         => 4,
            expire_action => $EXPIRE_REJECT,
            auto_edit     => 0,
        },
    };
}

sub release_ids { map { $_->{release_id} } @{ shift->data->{submissions} } }

sub related_entities
{
    my $self = shift;
    return {
        release => [ $self->release_ids ],
    };
}

sub alter_edit_pending
{
    my $self = shift;
    return {
        Release => [ $self->release_ids ],
    }
}

sub foreign_keys
{
    my ($self) = @_;
    return {
        Release => { map { $_ => [ 'ArtistCredit' ] } $self->release_ids },
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        submissions => [
            map +{ 
                release => $loaded->{Release}->{ $_->{release_id} },
                barcode => $_->{barcode},
            }, @{ $self->data->{submissions} }
        ]
    }
}

sub accept {
    my ($self) = @_;
    for my $submission (@{ $self->data->{submissions} }) {
        $self->c->model('Release')->update(
            $submission->{release_id},
            { barcode => $submission->{barcode} }
        )
    }
}

1;
