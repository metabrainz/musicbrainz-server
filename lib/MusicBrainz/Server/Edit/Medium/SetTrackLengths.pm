package MusicBrainz::Server::Edit::Medium::SetTrackLengths;
use Moose;
use namespace::autoclean;

use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_SET_TRACK_LENGTHS );

extends 'MusicBrainz::Server::Edit';

sub edit_name { 'Set tracks lengths' }
sub edit_type { $EDIT_SET_TRACK_LENGTHS }

has '+data' => (
    isa => Dict[
        tracklist_id => Int,
        cdtoc_id => Int
    ]
);

sub accept {
    my $self = shift;
    $self->c->model('Tracklist')->set_lengths_to_cdtoc(
        $self->data->{tracklist_id},
        $self->data->{cdtoc_id}
    );
}

__PACKAGE__->meta->make_immutable;
1;
