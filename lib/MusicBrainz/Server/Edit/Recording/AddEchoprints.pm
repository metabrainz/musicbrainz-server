package MusicBrainz::Server::Edit::Recording::AddEchoprints;
use Moose;
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_EchoprintS );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities' => {
    -excludes => 'recording_ids'
};

sub edit_name { l('Add Echoprints') }
sub edit_type { $EDIT_RECORDING_ADD_EchoprintS }

has '+data' => (
    isa => Dict[
        client_version => Str,
        echoprints => ArrayRef[Dict[
            echoprint         => Str,
            recording_id => Int
        ]]
    ]
);

sub recording_ids { map { $_->{recording_id} } @{ shift->data->{echoprints} } }

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => { map {
            $_->{recording_id} => ['ArtistCredit']
        } @{ $self->data->{echoprints} } }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        client_version => $self->data->{client_version},
        echoprints => [ map { +{
            echoprint      => $_->{echoprint},
            recording => $loaded->{Recording}{ $_->{recording_id} }
        } } @{ $self->data->{echoprints} } ]
    }
}

sub allow_auto_edit { 1 }

sub accept
{
    my $self = shift;

    my @insert = @{ $self->data->{echoprints} };
    my %echoprint_id = $self->c->model('Echoprint')->find_or_insert(
        $self->data->{client_version},
        map { $_->{echoprint} } @insert
    );

    my @submit = map +{
        recording_id => $_->{recording_id},
        echoprint_id      => $echoprint_id{ $_->{echoprint} }
    }, @insert;

    $self->c->model('RecordingEchoprint')->insert(
        @submit
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;
