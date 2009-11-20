package MusicBrainz::Server::Edit::Tracklist::DeleteTrack;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_TRACKLIST_DELETETRACK );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Edit::Types qw( ArtistCreditDefinition Nullable );
use MusicBrainz::Server::Edit::Utils qw( load_artist_credit_definitions artist_credit_from_loaded_definition );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Delete Track' }
sub edit_type { $EDIT_TRACKLIST_DELETETRACK }

sub alter_edit_pending { { Track => [ shift->data->{track_id} ] } }

has '+data' => (
    isa => Dict[
        track_id => Int,
        name => Str,
        artist_credit => ArtistCreditDefinition,
        recording_id => Int,
    ],
);

sub foreign_keys
{
    my $self = shift;
    return {
        Artist => { load_artist_credit_definitions($self->data->{artist_credit}) },
        Recording => { $self->data->{recording_id} => [] }
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        artist_credit => artist_credit_from_loaded_definition($loaded, $self->data->{artist_credit}),
        recording => $loaded->{Recording}->{ $self->data->{recording_id} },
        map { $_ => $self->data->{$_} } qw( length name )
    }
}

sub initialize
{
    my ($self, %args) = @_;
    my $track = delete $args{track} or die "Required 'track' object";

    if (!$track->artist_credit)
    {
        $self->c->model('ArtistCredit')->load($track);
    }

    $self->data({
        track_id => $track->id,
        name => $track->name,
        artist_credit => artist_credit_to_ref($track->artist_credit),
        recording_id => $track->recording_id,
    });
}

sub accept
{
    my $self = shift;
    my $track = $self->c->model('Track')->get_by_id($self->track_id);
    $self->c->model('Track')->delete($self->track_id);
    $self->c->model('Tracklist')->offset_track_positions($track->tracklist_id,
        $track->position + 1, -1);
}

sub _xml_arguments { ForceArray => [ 'artist_credit' ] }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
