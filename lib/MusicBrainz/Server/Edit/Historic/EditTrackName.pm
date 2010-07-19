package MusicBrainz::Server::Edit::Historic::EditTrackName;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_EDIT_TRACKNAME );

extends 'MusicBrainz::Server::Edit::Historic';
with 'MusicBrainz::Server::Edit::Historic::NoSerialization';

sub edit_type     { $EDIT_HISTORIC_EDIT_TRACKNAME }
sub historic_type { 4 }
sub edit_name     { 'Edit track name' }

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
        old          => Dict[name => Str],
        new          => Dict[name => Str],
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
        name => {
            old => $self->data->{old}->{name},
            new => $self->data->{new}->{name},
        }
    };
}

sub upgrade
{
    my $self = shift;
    $self->data({
        track_id     => $self->row_id,
        recording_id => $self->resolve_recording_id( $self->row_id ),
        old          => { name => $self->previous_value },
        new          => { name => $self->new_value }
    });

    return $self;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
