package MusicBrainz::Script::Role::Context;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Context;

has 'c' => (
    isa        => 'MusicBrainz::Server::Context',
    is         => 'ro',
    traits     => [ 'NoGetopt' ],
    lazy_build => 1,
    handles => 'sql'
);

sub _build_c
{
    return MusicBrainz::Server::Context->create_script_context;
}

1;
