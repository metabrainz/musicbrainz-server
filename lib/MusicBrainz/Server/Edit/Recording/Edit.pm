package MusicBrainz::Server::Edit::Recording::Edit;
use Moose;

use Moose::Util::TypeConstraints qw( find_type_constraint subtype as );
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

extends 'MusicBrainz::Server::Edit::WithDifferences';

sub edit_type { $EDIT_RECORDING_EDIT }
sub edit_name { 'Edit recording' }

sub related_entities   { { recording => [ shift->recording_id ] } }
sub alter_edit_pending { { Recording => [ shift->recording_id ] } }

sub recording_id { return shift->data->{recording_id} }

subtype 'RecordingHash' => as Dict[
    name => Optional[Str],
    artist_credit => Optional[ArtistCreditDefinition],
    length => Nullable[Int],
    comment => Nullable[Str]
];

has '+data' => (
    isa => Dict[
        recording_id => Int,
        old => find_type_constraint('RecordingHash'),
        new => find_type_constraint('RecordingHash')
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

sub initialize
{
    my ($self, %opts) = @_;
    my $recording = delete $opts{recording}
        or die 'You must specify a recording object to edit';

    if (exists $opts{artist_credit} && !$recording->artist_credit)
    { 
        my $ac_data = $self->c->model('ArtistCredit');
        $ac_data->load($recording);
    }

    $self->data({
        recording_id => $recording->id,
        $self->_change_data($recording, %opts)
    });
}

sub _mapping
{
    return (
        artist_credit => sub { artist_credit_to_ref(shift->artist_credit) },
    );
}

override 'accept' => sub
{
    my $self = shift;

    my %data = %{ $self->data->{new} };
    $data{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert(@{ $data{artist_credit} })
        if (exists $data{artist_credit});

    $self->c->model('Recording')->update($self->recording_id, \%data);
};

sub _xml_arguments { ForceArray => [ 'artist_credit' ] }

1;
