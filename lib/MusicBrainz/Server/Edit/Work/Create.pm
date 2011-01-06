package MusicBrainz::Server::Edit::Work::Create;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_WORK_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable ArtistCreditDefinition );
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
);
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Work';

sub edit_name { l('Add work') }
sub edit_type { $EDIT_WORK_CREATE }
sub _create_model { 'Work' }
sub work_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        type_id       => Nullable[Int],
        name          => Str,
        artist_credit => ArtistCreditDefinition,
        comment       => Nullable[Str],
        iswc          => Nullable[Str],
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Artist   => { load_artist_credit_definitions($self->data->{artist_credit}) },
        WorkType => [ $self->data->{type_id} ]
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        artist_credit => artist_credit_from_loaded_definition($loaded, $self->data->{artist_credit}),
        name          => $self->data->{name},
        comment       => $self->data->{comment},
        type          => $loaded->{WorkType}->{ $self->data->{type_id} },
        iswc          => $self->data->{iswc},
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
