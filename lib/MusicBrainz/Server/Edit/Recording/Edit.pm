package MusicBrainz::Server::Edit::Recording::Edit;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_EDIT );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
);
use MusicBrainz::Server::Track;

extends 'MusicBrainz::Server::Edit::Generic::Edit';

sub edit_type { $EDIT_RECORDING_EDIT }
sub edit_name { 'Edit recording' }
sub _edit_model { 'Recording' }
sub recording_id { return shift->entity_id }

sub change_fields
{
    Dict[
        name          => Optional[Str],
        artist_credit => Optional[ArtistCreditDefinition],
        length        => Nullable[Int],
        comment       => Nullable[Str]
    ];
}

has '+data' => (
    isa => Dict[
        entity_id => Int,
        old => change_fields(),
        new => change_fields(),
    ]
);

sub foreign_keys
{
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations);

    if (exists $self->data->{new}{artist_credit}) {
        $relations->{Artist} = {
            map {
                load_artist_credit_definitions($self->data->{$_}{artist_credit})
            } qw( new old )
        }
    }

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        name    => 'name',
        comment => 'comment',
        length  => 'length',
    );

    my $data = changed_display_data($self->data, $loaded, %map);

    if (exists $self->data->{new}{artist_credit}) {
        $data->{artist_credit} = {
            new => artist_credit_from_loaded_definition($loaded, $self->data->{new}{artist_credit}),
            old => artist_credit_from_loaded_definition($loaded, $self->data->{old}{artist_credit})
        }
    }

    return $data;
}

before 'initialize' => sub
{
    my ($self, %opts) = @_;
    my $recording = $opts{to_edit} or return;
    if (exists $opts{artist_credit} && !$recording->artist_credit) {
        $self->c->model('ArtistCredit')->load($recording);
    }

    if (exists $opts{length}) {
        delete $opts{length}
            if MusicBrainz::Server::Track::FormatTrackLength($opts{length}) eq
                MusicBrainz::Server::Track::FormatTrackLength($recording->length);
    }
};

sub _mapping
{
    return (
        artist_credit => sub { artist_credit_to_ref(shift->artist_credit) },
    );
}

sub _edit_hash
{
    my ($self, $data) = @_;
    $data->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert(@{ $data->{artist_credit} })
        if (exists $data->{artist_credit});
    return $data;
}

sub _xml_arguments { ForceArray => [ 'artist_credit' ] }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
