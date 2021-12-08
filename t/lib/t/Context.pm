package t::Context;
use Moose::Role;
use namespace::autoclean;

use Carp qw( confess );
use DBDefs;
use File::Temp;
use MusicBrainz::Server::Test;

has c => (
    is => 'ro',
    builder => '_build_context'
);

has cache_aware_c => (
    is => 'ro',
    builder => '_build_cache_aware_context',
    clearer => '_clear_cache_aware_c',
    lazy => 1
);

sub _build_context {
    MusicBrainz::Server::Test->create_test_context();
}

sub _build_cache_aware_context {
    my $test = shift;

    my $opts = DBDefs->CACHE_MANAGER_OPTIONS;
    $opts->{profiles}{external}{options}{namespace} = 'mbtest:';

    return $test->c->meta->clone_object(
        $test->c,
        cache_manager => MusicBrainz::Server::CacheManager->new(%$opts),
        models => {} # Need to reload models to use this new $c
    );
}

around run_test => sub {
    my $orig = shift;
    my $self = shift;

    MusicBrainz::Server::Test->prepare_test_server;

    $self->c->connector->_disconnect;

    $self->c->sql->begin;
    $self->_clear_cache_aware_c;

    $self->$orig(@_);

    if ($self->c->sql->transaction_depth > 1 ||
        $self->c->sql->transaction_depth > 1) {
        confess('Transactions still open after test complete');
    }

    $self->c->sql->rollback;
};

1;
