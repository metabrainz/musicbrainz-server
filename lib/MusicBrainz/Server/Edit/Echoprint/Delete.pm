package MusicBrainz::Server::Edit::Echoprint::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ECHOPRINT_DELETE );
use MusicBrainz::Server::Translation qw( l ln );
use MooseX::Types::Moose qw( Int Maybe Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities';

sub edit_type { $EDIT_ECHOPRINT_DELETE }
sub edit_name { l('Remove Echoprint') }

sub alter_edit_pending  { { RecordingEchoprint => [ shift->recording_echoprint_id ] } }

has '+data' => (
    isa => Dict[
        # Edit migration might not be able to find out what these
        # were
        recording_echoprint_id => Maybe[Int],
        echoprint_id           => Maybe[Int],
        recording_id           => Int,
        echoprint              => Str
    ]
);

sub echoprint_id { shift->data->{echoprint_id} }
sub recording_id { shift->data->{recording_id} }
sub recording_echoprint_id { shift->data->{recording_echoprint_id} }

sub foreign_keys
{
    my $self = shift;
    return {
        Echoprint      => [ $self->echoprint_id ],
        Recording => [ $self->recording_id ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        echoprint      => $loaded->{Echoprint}->{ $self->echoprint_id },
        recording => $loaded->{Recording}->{ $self->recording_id },
        echoprint_name => $self->data->{echoprint}
    };
}

sub initialize
{
    my ($self, %opts) = @_;
    my $echoprint = $opts{echoprint} or die "Missing required 'echoprint' object";

    $self->data({
        recording_echoprint_id => $echoprint->id,
        echoprint_id => $echoprint->echoprint_id,
        echoprint => $echoprint->echoprint->echoprint,
        recording_id => $echoprint->recording_id
    })
}

sub accept
{
    my ($self) = @_;
    $self->c->model('RecordingEchoprint')->delete($self->echoprint_id, $self->recording_echoprint_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
