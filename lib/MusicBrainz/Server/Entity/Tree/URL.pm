package MusicBrainz::Server::Entity::Tree::URL;
use Moose;

has url => (
    is => 'rw',
    predicate => 'url_set',
);

sub merge {
    my ($self, $tree) = @_;

    die 'Undefined';

    return $self;
}

sub complete {
    my $tree = shift;
    die 'Undefined';
}

1;
