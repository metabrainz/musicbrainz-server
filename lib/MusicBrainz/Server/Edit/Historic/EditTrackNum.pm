package MusicBrainz::Server::Edit::Historic::EditTrackNum;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_TRACKNUM );

extends 'MusicBrainz::Server::Edit::Historic';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_type     { $EDIT_HISTORIC_EDIT_TRACKNUM }
sub historic_type { 5 }
sub edit_name     { 'Edit track number' }

sub related_entities
{
    my $self = shift;
    return {
        recording => [ $self->data->{recording_id} ]
    }
}

has '+data' => (
    isa => Dict[
        track_id     => Int,
        recording_id => Int,
        old          => Dict[position => Int],
        new          => Dict[position => Int],
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => { $self->data->{recording_id} => [ 'ArtistCredit' ] },
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        recording => $loaded->{Recording}->{ $self->data->{recording_id} },
        position => {
            old => $self->data->{old}->{position},
            new => $self->data->{new}->{position},
        }
    };
}

sub upgrade
{
    my $self = shift;
    $self->data({
        track_id     => $self->row_id,
        recording_id => $self->resolve_recording_id( $self->row_id ),
        old          => { position => $self->previous_value },
        new          => { position => $self->new_value }
    });

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
