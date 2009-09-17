package MusicBrainz::Server::Edit::Tracklist::DeleteTrack;
use Moose;

use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_TRACKLIST_DELETETRACK );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Delete Track' }
sub edit_type { $EDIT_TRACKLIST_DELETETRACK }

sub alter_edit_pending { { Track => [ shift->track_id ] } }
sub models { [qw( Track )] }

has 'track_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{track_id} }
);

has 'track' => (
    isa => 'Track',
    is => 'rw'
);

has '+data' => (
    isa => Dict[
        track_id => Int
    ],
);

sub accept
{
    my $self = shift;
    my $track = $self->c->model('Track')->get_by_id($self->track_id);
    $self->c->model('Track')->delete($self->track_id);
    $self->c->model('Tracklist')->offset_track_positions($track->tracklist_id,
        $track->position + 1, -1);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
