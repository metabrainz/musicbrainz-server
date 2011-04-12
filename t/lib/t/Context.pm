package t::Context;
use Moose::Role;
use namespace::autoclean;

use Carp 'confess';
use MusicBrainz::Server::Test;

has c => (
    is => 'ro',
    builder => '_build_context'
);

sub _build_context {
    MusicBrainz::Server::Test->create_test_context();
}

around run_test => sub {
    my $orig = shift;
    my $self = shift;

    MusicBrainz::Server::Test->prepare_test_server;

    $self->c->sql->begin;
    $self->c->raw_sql->begin;

    $self->$orig(@_);

    if ($self->c->sql->transaction_depth > 1 ||
        $self->c->sql->transaction_depth > 1) {
        confess('Transactions still open after test complete');
    }

    $self->c->sql->rollback;
    $self->c->raw_sql->rollback;
};

1;
