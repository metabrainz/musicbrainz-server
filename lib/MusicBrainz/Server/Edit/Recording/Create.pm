package MusicBrainz::Server::Edit::Recording::Create;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_CREATE );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
);
use MusicBrainz::Server::Track;
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( normalise_strings );

use aliased 'MusicBrainz::Server::Entity::Recording';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities';
with 'MusicBrainz::Server::Edit::Recording';

sub edit_type { $EDIT_RECORDING_CREATE }
sub edit_name { l('Add standalone recording') }
sub _create_model { 'Recording' }
sub recording_id { return shift->entity_id }

has '+data' => (
    isa => Dict[
        name          => Optional[Str],
        artist_credit => Optional[ArtistCreditDefinition],
        length        => Nullable[Int],
        comment       => Nullable[Str]
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Artist    => { load_artist_credit_definitions($self->data->{artist_credit}) },
        Recording => { $self->entity_id => [ 'ArtistCredit' ] }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        artist_credit => artist_credit_from_loaded_definition($loaded, $self->data->{artist_credit}),
        name          => $self->data->{name},
        comment       => $self->data->{comment},
        length        => $self->data->{length},
        recording => $loaded->{Recording}{ $self->entity_id } ||
            Recording->new( name => $self->data->{name} )
    };
}


sub _insert_hash
{
    my ($self, $data) = @_;
    $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert($data->{artist_credit});
    return $data
}

around reject => sub {
    my ($orig, $self) = @_;
    if ($self->c->model('Recording')->can_delete($self->entity_id)) {
        $self->$orig;
    }
    else {
        MusicBrainz::Server::Edit::Exceptions::MustApply->throw(
            'This edit cannot be rejected as the recording is already being used by other releases',
        );
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
