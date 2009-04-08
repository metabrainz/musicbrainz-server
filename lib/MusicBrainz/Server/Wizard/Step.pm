package MusicBrainz::Server::Wizard::Step;
use Moose;
use MooseX::Storage;

with Storage;

has 'action_name' => (
    isa => 'Str',
    is  => 'ro',
    required => 1
);

has 'name' => (
    isa => 'Str',
    is  => 'rw',
);

has 'skip' => (
    isa => 'CodeRef',
    is  => 'ro',
    predicate => 'has_skip_condition',
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;

