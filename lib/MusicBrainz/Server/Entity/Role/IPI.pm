package MusicBrainz::Server::Entity::Role::IPI;
use Moose::Role;

has ipi_codes => (
    isa => 'ArrayRef',
    is => 'ro',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        add_ipi => 'push',
        all_ipi_codes => 'elements',
    }
);

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{ipi_codes} = [map { $_->TO_JSON } $self->all_ipi_codes];
    return $json;
};

1;
