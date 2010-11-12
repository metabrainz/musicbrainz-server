package MusicBrainz::Server::Edit::Historic::EditTrackLength;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( Int );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_TRACK_LENGTH );
use MusicBrainz::Server::Translation qw ( l ln );

extends 'MusicBrainz::Server::Edit::Historic';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_name { l('Edit track length') }
sub edit_type { $EDIT_HISTORIC_EDIT_TRACK_LENGTH }
sub historic_type { 45 }

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
        old          => Dict[length => Int],
        new          => Dict[length => Int]
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
        length => {
            old => $self->data->{old}->{length},
            new => $self->data->{new}->{length},
        }
    };
}

sub upgrade
{
    my $self = shift;
    $self->data({
        track_id     => $self->row_id,
        recording_id => $self->resolve_recording_id( $self->row_id ),
        old          => { length => $self->previous_value },
        new          => { length => $self->new_value }
    });

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
