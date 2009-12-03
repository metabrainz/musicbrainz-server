package MusicBrainz::Server::Edit::Work::Edit;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_WORK_EDIT );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use Moose::Util::TypeConstraints qw( find_type_constraint subtype as );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
);
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );

extends 'MusicBrainz::Server::Edit::WithDifferences';

sub edit_type { $EDIT_WORK_EDIT }
sub edit_name { 'Edit work' }

sub related_entities { { work => [ shift->work_id ] } }
sub alter_edit_pending { { Work => [ shift->work_id ] } }

has 'work_id' => (
    isa => 'Int',
    lazy => 1,
    is => 'rw',
    default => sub { shift->data->{work} }
);

has 'work' => (
    isa => 'Work',
    is => 'rw',
);

subtype 'WorkHash'
    => as Dict[
        name => Optional[Str],
        comment => Nullable[Str],
        type_id => Nullable[Str],
        artist_credit => Optional[ArtistCreditDefinition],
        iswc => Nullable[Str]
    ];

has '+data' => (
    isa => Dict[
        work => Int,
        new => find_type_constraint('WorkHash'),
        old => find_type_constraint('WorkHash')
    ],
);

sub foreign_keys
{
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations,
        WorkType => 'type_id',
    );

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
        type    => [ qw( type_id WorkType ) ],
        iswc    => 'iswc',
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
    my $work = delete $opts{work}
        or die 'You must specify a work object to edit';

    if (exists $opts{artist_credit} && !$work->artist_credit_loaded)
    { 
        my $ac_data = $self->c->model('ArtistCredit');
        $ac_data->load($work);
    }

    $self->work($work);
    $self->work_id($work->id);
    $self->data({
        work => $work->id,
        $self->_change_data($work, %opts)
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
    my $work_data = $self->c->model('Work');

    my %data = %{ $self->data->{new} };
    if (exists $data{artist_credit}) {
        my $ac_data = $self->c->model('ArtistCredit');
        $data{artist_credit} = $ac_data->find_or_insert(@{ $data{artist_credit} });
    }
    $work_data->update($self->work_id, \%data);
};

sub _xml_arguments { ForceArray => [ 'artist_credit' ] }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
