package MusicBrainz::Server::Edit::Recording::Create;
use Moose;

use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_CREATE );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
    verify_artist_credits
);
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Track;
use MusicBrainz::Server::Translation qw( N_lp );

use aliased 'MusicBrainz::Server::Entity::Recording';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities',
     'MusicBrainz::Server::Edit::Recording',
     'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit',
     'MusicBrainz::Server::Edit::Role::CheckOverlongString' => {
        get_string => sub { shift->{name} },
     };

sub edit_type { $EDIT_RECORDING_CREATE }
sub edit_name { N_lp('Add standalone recording', 'edit type') }
sub edit_template { 'AddStandaloneRecording' }
sub _create_model { 'Recording' }
sub recording_id { return shift->entity_id }

has '+data' => (
    isa => Dict[
        name          => Str,
        artist_credit => ArtistCreditDefinition,
        length        => Nullable[Int],
        comment       => Nullable[Str],
        video         => Optional[Bool],
    ],
);

sub foreign_keys
{
    my $self = shift;
    return {
        Artist    => { load_artist_credit_definitions($self->data->{artist_credit}) },
        Recording => { $self->entity_id => [ 'ArtistCredit' ] },
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        artist_credit => to_json_object(artist_credit_from_loaded_definition($loaded, $self->data->{artist_credit})),
        name          => $self->data->{name},
        comment       => $self->data->{comment},
        length        => $self->data->{length},
        video         => boolean_to_json($self->data->{video}),
        recording     => to_json_object((defined($self->entity_id) &&
            $loaded->{Recording}{ $self->entity_id }) ||
            Recording->new( name => $self->data->{name} ),
        ),
    };
}


sub _insert_hash
{
    my ($self, $data) = @_;
    $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert($data->{artist_credit});
    $data->{comment} //= '';
    return $data;
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

before accept => sub {
    my ($self) = @_;

    verify_artist_credits($self->c, $self->data->{artist_credit});
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
