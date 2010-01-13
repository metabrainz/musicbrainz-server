package MusicBrainz::Server::Edit::PUID::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PUID_DELETE );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_PUID_DELETE }
sub edit_name { 'Delete PUID' }

sub alter_edit_pending  { { RecordingPUID => [ shift->recording_puid_id ] } }
sub related_entities    { { recording     => [ shift->recording_id ] } }

has '+data' => (
    isa => Dict[
        recording_puid_id => Int,
        puid_id           => Int,
        recording_id      => Int,
        puid              => Str
    ]
);

sub puid_id { shift->data->{puid_id} }
sub recording_id { shift->data->{recording_id} }
sub recording_puid_id { shift->data->{recording_puid_id} }

sub foreign_keys
{
    my $self = shift;
    return {
        PUID      => [ $self->puid_id ],
        Recording => [ $self->recording_id ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        puid      => $loaded->{PUID}->{ $self->puid_id },
        recording => $loaded->{Recording}->{ $self->recording_id },
        puid_name => $self->data->{puid}
    };
}

sub initialize
{
    my ($self, %opts) = @_;
    my $puid = $opts{puid} or die "Missing required 'puid' object";

    $self->data({
        recording_puid_id => $puid->id,
        puid_id => $puid->puid_id,
        puid => $puid->puid->puid,
        recording_id => $puid->recording_id
    })
}

sub accept
{
    my ($self) = @_;
    $self->c->model('RecordingPUID')->delete($self->puid_id, $self->recording_puid_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
