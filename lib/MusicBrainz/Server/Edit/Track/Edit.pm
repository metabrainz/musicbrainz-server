package MusicBrainz::Server::Edit::Track::Edit;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );

use MusicBrainz::Server::Constants qw( $EDIT_TRACK_EDIT );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
    clean_submitted_artist_credits
);

extends 'MusicBrainz::Server::Edit::Generic::Edit';

sub edit_name { 'Edit track' }
sub edit_type { $EDIT_TRACK_EDIT }
sub _edit_model { 'Track' }
sub track_id { shift->entity_id }

sub related_entities
{
    my $self = shift;
    return {
        release => $self->c->model('Release')->find_ids_by_track_ids($self->track_id)
    }
}

sub change_fields
{
    return Dict[
        name => Optional[Str],
        recording_id => Optional[Int],
        tracklist_id => Optional[Int],
        artist_credit => Optional[ArtistCreditDefinition],
        position => Optional[Int],
        length => Nullable[Int],
    ];
}

has '+data' => (
    isa => Dict[
        entity_id => Int,
        old => change_fields(),
        new => change_fields()
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
        length       => 'length',
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

around 'initialize' => sub
{
    my $orig = shift;

    my ($self, %opts) = @_;
    my $track = $opts{to_edit} or return;
    if (exists $opts{artist_credit} && !$track->artist_credit) {
        $self->c->model('ArtistCredit')->load($track);
    }

    if ($opts{length}) {
        # Format both the track times into MM:SS, to avoid sub-second differences
        my $old_length = MusicBrainz::Server::Track::FormatTrackLength($track->length);
        my $new_length = MusicBrainz::Server::Track::FormatTrackLength($opts{length});

        delete $opts{length} if $old_length eq $new_length;
    }

    if (exists $opts{artist_credit})
    {
        $opts{artist_credit} = clean_submitted_artist_credits ($opts{artist_credit});
    }

    $self->$orig(%opts);
};

sub _edit_hash
{
    my ($self, $data) = @_;

    if (exists $data->{position}) {
        my $track = $self->c->model('Track')->get_by_id($self->track_id);
        $self->c->model('Tracklist')->offset_track_positions($track->tracklist_id, $track->position +1, -1);
        $self->c->model('Tracklist')->offset_track_positions($track->tracklist_id, $data->{position}, +1);
    }

    if (exists $data->{artist_credit}) {
        my $ac = $self->c->model('ArtistCredit')->find_or_insert(@{ $data->{artist_credit} });
        $data->{artist_credit} = $ac;
    }

    return $data;
}

sub _xml_arguments { ForceArray => [ 'artist_credit' ] }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
