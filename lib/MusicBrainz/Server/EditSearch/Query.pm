package MusicBrainz::Server::EditSearch::Query;
use Moose;

use CGI::Expand qw( expand_hash );
use MooseX::Types::Moose qw( Any ArrayRef Bool Str );
use MooseX::Types::Structured qw( Map Tuple );
use Moose::Util::TypeConstraints qw( enum role_type );

use MusicBrainz::Server::EditSearch::Predicate::ID;

my %field_map = (
    id => 'MusicBrainz::Server::EditSearch::Predicate::ID'
);

has negate => (
    isa => Bool,
    is => 'ro',
    default => 0
);

has combinator => (
    isa => enum([qw( or and )]),
    is => 'ro',
    required => 1
);

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
    isa => ArrayRef[ Tuple[ Str, ArrayRef[Any] ] ],
    is => 'bare',
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        where => 'elements',
        'add_where' => 'push',
    }
);

has predicates => (
    isa => ArrayRef[ role_type('MusicBrainz::Server::EditSearch::Predicate') ],
    is => 'bare',
    required => 1,
    traits => [ 'Array' ],
    handles => {
        predicates => 'elements',
    }
);

sub new_from_user_input {
    my ($class, $user_input) = @_;
    my $input = expand_hash($user_input);
    return $class->new(
        negate => $input->{negation},
        combinator => $input->{combinator},
        predicates => [
            map {
                $class->_construct_predicate($_)
            } grep { defined } @{ $input->{conditions} }
        ]
    );
}

sub _construct_predicate {
    my ($class, $input) = @_;
    my $class = $field_map{$input->{field}} or die 'No predicate for field ' . $input->{field};
    return $class->new_from_input(
        $input->{field},
        $input
    );
}

sub valid {
    my $self = shift;
    my $valid = 1;
    $valid &&= $_->valid for $self->predicates;
    return $valid
}

sub as_string {
    my $self = shift;
    $_->combine_with_query($self) for $self->predicates;
    my $comb = $self->combinator;
    return 'SELECT edit.* FROM edit ' .
        join(' ', $self->join) .
        ' WHERE ' . ($self->negate ? 'NOT' : '') . ' (' .
            join(" $comb ", map { '(' . $_->[0] . ')' } $self->where) .
        ') OFFSET ?';
}

sub arguments {
    my $self = shift;
    return map { @{$_->[1]} } $self->where;
}

1;
