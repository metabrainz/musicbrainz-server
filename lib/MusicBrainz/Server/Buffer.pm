package MusicBrainz::Server::Buffer;
use Moose;
use namespace::autoclean;

has 'contents' => (
    isa     => 'ArrayRef',
    is      => 'ro',
    traits  => [ 'Array' ],
    default => sub { [] },
    handles => {
        _push => 'push',
        count => 'count',
        empty => 'clear',
    }
);

has 'on_full' => (
    isa      => 'CodeRef',
    is       => 'ro',
    traits   => [ 'Code' ],
    handles  => {
        callback => 'execute',
    },
    required => 1
);

has 'limit' => (
    isa      => 'Int',
    required => 1,
    is       => 'ro'
);

has 'skip_empty' => (
    isa => 'Bool',
    is => 'ro',
    default => 1
);

sub flush_on_complete
{
    my ($self, $code) = @_;
    $code->();
    $self->flush;
}

sub add_items
{
    my ($self, @items) = @_;

    while (@items) {
        my $item = shift(@items);
        $self->flush if ($self->count > $self->limit);
        $self->_push($item);
    }
}

sub flush
{
    my ($self) = @_;
    return if $self->skip_empty && $self->count == 0;
    $self->callback($self->contents);
    $self->empty;
}

1;
