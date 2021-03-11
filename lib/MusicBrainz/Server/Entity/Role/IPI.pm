package MusicBrainz::Server::Entity::Role::IPI;
use Moose::Role;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

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
    $json->{ipi_codes} = to_json_array($self->ipi_codes);
    return $json;
};

1;
