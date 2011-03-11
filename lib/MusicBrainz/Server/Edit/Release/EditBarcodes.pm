package MusicBrainz::Server::Edit::Release::EditBarcodes;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT_BARCODES );
use MusicBrainz::Server::Translation qw( l ln );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Release';

use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_name { l('Edit barcodes') }
sub edit_type { $EDIT_RELEASE_EDIT_BARCODES }

has '+data' => (
    isa => Dict[
        submissions => ArrayRef[Dict[
            release => Dict[
                id => Int,
                name => Str
            ],
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

sub release_ids { map { $_->{release}{id} } @{ shift->data->{submissions} } }

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
                release => $loaded->{Release}->{ $_->{release}{id} }
                    || Release->new( name => $_->{release}{name} ),
                barcode => $_->{barcode},
            }, @{ $self->data->{submissions} }
        ]
    }
}

sub accept {
    my ($self) = @_;
    for my $submission (@{ $self->data->{submissions} }) {
        $self->c->model('Release')->update(
            $submission->{release}{id},
            { barcode => $submission->{barcode} }
        )
    }
}

1;
