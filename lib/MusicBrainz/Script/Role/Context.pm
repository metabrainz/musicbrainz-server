package MusicBrainz::Script::Role::Context;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Context;

has 'c' => (
    isa        => 'MusicBrainz::Server::Context',
    is         => 'ro',
    traits     => [ 'NoGetopt' ],
    lazy_build => 1,
    handles    => [qw( sql )],
);

has database => (
    is => 'ro',
    isa => 'Str',
    default => 'MAINTENANCE',
    traits => ['Getopt'],
    documentation => 'database to use (default: MAINTENANCE)',
);

sub _build_c
{
    return MusicBrainz::Server::Context->create_script_context(
        database => shift->database,
    );
}

1;
