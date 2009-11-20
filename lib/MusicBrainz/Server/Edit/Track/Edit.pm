package MusicBrainz::Server::Edit::Track::Edit;
use Moose;

use Moose::Util::TypeConstraints qw( as find_type_constraint subtype );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_TRACK_EDIT );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
);

extends 'MusicBrainz::Server::Edit::WithDifferences';

sub edit_name { 'Edit track' }
sub edit_type { $EDIT_TRACK_EDIT }

sub alter_edit_pending { { Track => [ shift->track_id ] } }
sub related_entities
{
    my $self = shift;
    return {
        release => $self->c->model('Release')->find_ids_by_track_ids($self->track_id)
    }
}


has 'track_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{track} }
);

subtype 'TrackHash',
    as Dict[
        name => Optional[Str],
        recording_id => Optional[Int],
        tracklist_id => Optional[Int],
        artist_credit => Optional[ArtistCreditDefinition],
        position => Optional[Int]
    ];

has '+data' => (
    isa => Dict[
        track => Int,
        old => find_type_constraint('TrackHash'),
        new => find_type_constraint('TrackHash')
    ]
);

sub foreign_keys
{
    my $self = shift;
    my $relations = {};
    changed_relations($self->data, $relations,
        Recording => 'recording_id',
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

    my $data = changed_display_data($self->data, $loaded,
        recording    => [ qw( recording_id Recording )],
        tracklist_id => 'tracklist_id',
        position     => 'position',
        name         => 'name',
    );

    if (exists $self->data->{new}{artist_credit}) {
        $data->{artist_credit} = {
            new => artist_credit_from_loaded_definition($loaded, $self->data->{new}{artist_credit}),
            old => artist_credit_from_loaded_definition($loaded, $self->data->{old}{artist_credit})
        }
    }

    return $data;
}

sub _mapping
{
    return (
        artist_credit => sub { artist_credit_to_ref(shift->artist_credit) }
    );
}

sub initialize
{
    my ($self, %opts) = @_;
    my $track = delete $opts{track}
        or die 'Must specify the track object to edit';

    if (!defined $track->artist_credit) {
        $self->c->model('ArtistCredit')->load($track);
    }

    $self->track_id($track->id);
    $self->data({
        track => $track->id,
        $self->_change_data($track, %opts)
    });
}

sub accept
{
    my ($self) = @_;
    my %data = %{ $self->data->{new} };

    if (exists $data{position}) {
        my $track = $self->c->model('Track')->get_by_id($self->track_id);
        $self->c->model('Tracklist')->offset_track_positions($track->tracklist_id, $track->position +1, -1);
        $self->c->model('Tracklist')->offset_track_positions($track->tracklist_id, $data{position}, +1);
    }

    if (exists $data{artist_credit}) {
        my $ac = $self->c->model('ArtistCredit')->find_or_insert(@{ $data{artist_credit} });
        $data{artist_credit} = $ac;
    }

    $self->c->model('Track')->update($self->track_id, \%data);
}

sub _xml_arguments { ForceArray => [ 'artist_credit' ] }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
