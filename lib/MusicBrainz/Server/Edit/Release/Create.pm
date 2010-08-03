package MusicBrainz::Server::Edit::Release::Create;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable ArtistCreditDefinition );
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
);

extends 'MusicBrainz::Server::Edit::Generic::Create';

sub edit_name { 'Add release' }
sub edit_type { $EDIT_RELEASE_CREATE }
sub _create_model { 'Release' }
sub release_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        status_id       => Nullable[Int],
        release_group_id => Int,
        name          => Str,
        artist_credit => ArtistCreditDefinition,
        comment       => Nullable[Str]
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Artist           => { load_artist_credit_definitions($self->data->{artist_credit}) },
        ReleaseStatus    => [ $self->data->{status_id} ],
        ReleaseGroup     => [ $self->data->{release_group_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        artist_credit => artist_credit_from_loaded_definition($loaded, $self->data->{artist_credit}),
        name          => $self->data->{name},
        comment       => $self->data->{comment},
        status        => $loaded->{ReleaseStatus}->{ $self->data->{status_id} }
    };
}

sub _insert_hash
{
    my ($self, $data) = @_;
    $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert(@{ $data->{artist_credit} });
    return $data
}

sub _xml_arguments { ForceArray => [ 'artist_credit' ] }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
