package MusicBrainz::Server::Edit::Artist::Delete;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_DELETE );
use MusicBrainz::Server::Data::Artist;
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Types;
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_ARTIST_DELETE }
sub edit_name { "Delete Artist" }

sub related_entities { { artist => [ shift->artist_id ] } }
sub alter_edit_pending { { Artist => [ shift->artist_id ] } }
sub models { [qw( Artist )] }

has '+data' => (
    isa => Dict[
        artist_id => Int
    ]
);

has 'artist_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{artist_id} }
);

has 'artist' => (
    isa => 'Artist',
    is => 'rw',
);

override 'accept' => sub
{
    my $self = shift;
    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw
          if $self->c->model('Artist')->in_use($self->artist_id);
    $self->c->model('Artist')->delete($self->artist_id);
};

__PACKAGE__->meta->make_immutable;

no Moose;
1;
