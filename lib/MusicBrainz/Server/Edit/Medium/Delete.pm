package MusicBrainz::Server::Edit::Medium::Delete;
use Moose;

use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_DELETE );
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_MEDIUM_DELETE }
sub edit_name { 'Delete medium' }

sub alter_edit_pending { { Medium => [ shift->medium_id ] } }
sub models { [qw( Medium )] }

has 'medium_id' => (
    isa     => 'Int',
    is      => 'rw',
    lazy    => 1,
    default => sub { shift->data->{medium_id} }
);

has 'medium' => (
    isa => 'Medium',
    is => 'rw'
);

has '+data' => (
    isa => Dict[
        medium_id => Int
    ]
);

sub accept
{
    my $self = shift;
    $self->c->model('Medium')->delete($self->medium_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
