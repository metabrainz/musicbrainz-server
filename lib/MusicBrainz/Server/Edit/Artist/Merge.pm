package MusicBrainz::Server::Edit::Artist::Merge;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Data::Artist;
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub edit_type { $EDIT_ARTIST_MERGE }
sub edit_name { "Merge Artists" }

sub related_entities
{
    my $self = shift;
    return {
        artist => [ $self->old_artist_id, $self->new_artist_id ],
    }
}

sub alter_edit_pending
{
    my $self = shift;
    return {
        Artist => [ $self->old_artist_id, $self->new_artist_id ],
    }
}

sub models { [qw( Artist )] }

has 'old_artist_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{old_artist} }
);

has 'new_artist_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{new_artist} }
);

has [qw( old_artist new_artist )] => (
    isa => 'Artist',
    is => 'rw'
);

has '+data' => (
    isa => Dict[
        new_artist => Int,
        old_artist => Int,
    ]
);

sub initialize
{
    my ($self, %args) = @_;
    $self->data({
        old_artist => $args{old_artist_id},
        new_artist => $args{new_artist_id}
    });
}

override 'accept' => sub
{
    my $self = shift;
    $self->c->model('Artist')->merge($self->new_artist_id, $self->old_artist_id);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
