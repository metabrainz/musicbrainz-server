package MusicBrainz::Server::Edit::PUID::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PUID_DELETE );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Edit::Exceptions;
use MooseX::Types::Moose qw( Int Maybe Str );
use MooseX::Types::Structured qw( Dict Optional );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities';
with 'MusicBrainz::Server::Edit::Recording';

sub edit_type { $EDIT_PUID_DELETE }
sub edit_name { N_l('Remove PUID (historic)') }
sub edit_kind { 'remove' }
sub edit_template_react { 'historic/RemovePuid' }

use aliased 'MusicBrainz::Server::Entity::Recording';

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
        puid              => Str,
        client_version    => Optional[Str]
    ]
);

sub puid_id { shift->data->{puid_id} }
sub recording_id { shift->data->{recording}{id} }
sub recording_puid_id { shift->data->{recording_puid_id} }

sub foreign_keys
{
    my $self = shift;
    return {
        Recording => [ $self->recording_id ],
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        recording => $loaded->{Recording}->{ $self->recording_id }
            || Recording->new( name => $self->data->{recording}{name} ),
        puid_name => $self->data->{puid}
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
