package MusicBrainz::Server::EditSearch::Query;
use Moose;

use MooseX::Types::Moose qw( Any ArrayRef Str );
use MooseX::Types::Structured qw( Map );

has join => (
    isa => ArrayRef[Str],
    is => 'bare',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        join => 'elements',
        add_join => 'push',
    }
);

has where => (
    isa => ArrayRef[ Map[ Str, Any ] ],
    is => 'bare',
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        where => 'elements',
        'add_where' => 'push',
    }
);

1;
