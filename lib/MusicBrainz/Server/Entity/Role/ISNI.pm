package MusicBrainz::Server::Entity::Role::ISNI;
use Moose::Role;

has isni_codes => (
    isa => 'ArrayRef',
    is => 'ro',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        add_isni => 'push',
        all_isni_codes => 'elements',
    }
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{isni_codes} = [map { $_->TO_JSON } $self->all_isni_codes];
    return $json;
};

1;
