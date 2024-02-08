package t::Context;
use Moose::Role;
use namespace::autoclean;

use Carp qw( confess );
use DBDefs;
use File::Temp;
use MusicBrainz::DataStore::Redis;
use MusicBrainz::Server::Test;

has c => (
    is => 'ro',
    builder => '_build_context',
    lazy => 1,
);

sub _build_context {
    MusicBrainz::Server::Test->get_test_context;
}

around run_test => sub {
    my $orig = shift;
    my $self = shift;

    MusicBrainz::Server::Test->prepare_test_server;

    my $c = $self->c;

    $c->sql->begin;

    $self->$orig(@_);

    if ($c->sql->transaction_depth > 1 ||
        $c->sql->transaction_depth > 1) {
        confess('Transactions still open after test complete');
    }

    $c->sql->rollback;
    $c->cache->clear;
    $c->store->clear;
};

1;
