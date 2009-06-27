package MusicBrainz::Server::Edit::Artist::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_DELETE );
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Entity::Types;
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_ARTIST_DELETE }
sub edit_name { "Delete Artist" }
sub entity_model { 'Artist' }
sub entity_id { shift->artist_id }

has '+data' => (
    isa => Dict[
        artist_id => Int
    ]
);

sub artist_id { return shift->data->{artist_id} }
has 'artist' => (
    isa => 'Artist',
    is => 'rw',
);

sub entities
{
    my $self = shift;
    return {
        artist => [ $self->artist_id ],
    }
}

override 'accept' => sub
{
    my $self = shift;
    my $artist_data = MusicBrainz::Server::Data::Artist->new(c => $self->c);
    $artist_data->delete($self->artist_id);
};

__PACKAGE__->register_type;
__PACKAGE__->meta->make_immutable;

no Moose;
1;

