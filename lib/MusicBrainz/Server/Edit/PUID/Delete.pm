package MusicBrainz::Server::Edit::PUID::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PUID_DELETE );
use MusicBrainz::Server::Translation qw( l ln );
use MooseX::Types::Moose qw( Int Maybe Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities';
with 'MusicBrainz::Server::Edit::Recording';

sub edit_type { $EDIT_PUID_DELETE }
sub edit_name { l('Remove PUID') }

use aliased 'MusicBrainz::Server::Entity::Recording';

sub alter_edit_pending  { { RecordingPUID => [ shift->recording_puid_id ] } }

has '+data' => (
    isa => Dict[
        # Edit migration might not be able to find out what these
        # were
        recording_puid_id => Maybe[Int],
        puid_id           => Maybe[Int],

        recording         => Dict[
            id => Int,
            name => Str
        ],
        puid              => Str
    ]
);

sub puid_id { shift->data->{puid_id} }
sub recording_id { shift->data->{recording}{id} }
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
        recording => $loaded->{Recording}->{ $self->recording_id }
            || Recording->new( name => $self->data->{recording}{name} ),
        puid_name => $self->data->{puid}
    };
}

sub initialize
{
    my ($self, %opts) = @_;
    my $puid = $opts{puid} or die "Missing required 'puid' object";

    unless ($puid->recording) {
        $self->c->model('Recording')->load($puid);
    }

    $self->data({
        recording_puid_id => $puid->id,
        puid_id => $puid->puid_id,
        puid => $puid->puid->puid,
        recording => {
            id => $puid->recording->id,
            name => $puid->recording->name
        }
    })
}

sub insert
{
    my ($self) = @_;
    $self->c->model('RecordingPUID')->delete($self->puid_id, $self->recording_puid_id);
}

sub reject
{
    my ($self) = @_;

    my %puid_id = $self->c->model('PUID')->find_or_insert(
        'ModBot',
        $self->data->{puid}
    );

    $self->c->model('RecordingPUID')->insert({
        recording_id => $self->data->{recording}{id},
        puid_id      => $puid_id{ $self->data->{puid} }
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
