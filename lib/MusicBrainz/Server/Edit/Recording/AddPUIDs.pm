package MusicBrainz::Server::Edit::Recording::AddPUIDs;
use Moose;
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_ADD_PUIDS );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities' => {
    -excludes => 'recording_ids'
};
with 'MusicBrainz::Server::Edit::Recording';

use aliased 'MusicBrainz::Server::Entity::Recording';

sub edit_name { l('Add PUIDs') }
sub edit_type { $EDIT_RECORDING_ADD_PUIDS }

has '+data' => (
    isa => Dict[
        client_version => Str,
        puids => ArrayRef[Dict[
            puid         => Str,
            recording    => Dict[
                id => Int,
                name => Str
            ]
        ]]
    ]
);

sub recording_ids { map { $_->{recording}{id} } @{ shift->data->{puids} } }

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => { map {
            $_->{recording}{id} => ['ArtistCredit']
        } @{ $self->data->{puids} } }
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        client_version => $self->data->{client_version},
        puids => [ map { +{
            puid      => $_->{puid},
            recording => $loaded->{Recording}{ $_->{recording}{id} }
                || Recording->new( name => $_->{recording}{name} )
        } } @{ $self->data->{puids} } ]
    }
}

sub allow_auto_edit { 1 }

sub accept
{
    my $self = shift;

    my @insert = @{ $self->data->{puids} };
    my %puid_id = $self->c->model('PUID')->find_or_insert(
        $self->data->{client_version},
        map { $_->{puid} } @insert
    );

    my @submit = map +{
        recording_id => $_->{recording}{id},
        puid_id      => $puid_id{ $_->{puid} }
    }, @insert;

    $self->c->model('RecordingPUID')->insert(
        @submit
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;
