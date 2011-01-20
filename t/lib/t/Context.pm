package t::Context;
use Moose::Role;
use namespace::autoclean;

use MusicBrainz::Server::Test;

has c => (
    is => 'ro',
    builder => '_build_context'
);

sub _build_context {
    MusicBrainz::Server::Test->create_test_context();
}

1;
