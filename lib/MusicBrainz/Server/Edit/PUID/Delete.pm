package MusicBrainz::Server::Edit::PUID::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PUID_DELETE );
use MusicBrainz::Server::Translation qw ( N_l );
use MooseX::Types::Moose qw( Int Maybe Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Recording::RelatedEntities';
with 'MusicBrainz::Server::Edit::Recording';

sub edit_type { $EDIT_PUID_DELETE }
sub edit_name { N_l('Remove PUID') }

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
        client_version    => Maybe[Str]
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

sub alter_edit_pending  { die 'This edit is read only' }
sub initialize { die 'This edit is read only' }
sub insert { die 'This edit is read only' }
sub reject { die 'This edit is read only' }
sub accept { die 'This edit is read only' }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
