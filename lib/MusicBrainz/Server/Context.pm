package MusicBrainz::Server::Context;
use Moose;
use namespace::autoclean;

use DBDefs;
use MusicBrainz::DataStore::RedisMulti;
use MusicBrainz::Server::Replication qw( :replication_type );
use MusicBrainz::Server::CacheManager;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory';
use Class::Load qw( load_class );
use LWP::UserAgent;

has 'cache_manager' => (
    is => 'ro',
    isa => 'MusicBrainz::Server::CacheManager',
    lazy => 1,
    builder => '_build_cache_manager',
    clearer => 'clear_cache_manager',
    handles => [ 'cache' ],
);

sub _build_cache_manager {
    my $cache_opts = DBDefs->CACHE_MANAGER_OPTIONS;
    return MusicBrainz::Server::CacheManager->new($cache_opts);
}

has 'connector' => (
    is => 'ro',
    handles => [ 'dbh', 'sql', 'conn' ],
    lazy_build => 1,
    clearer => 'clear_connector',
    predicate => 'has_connector',
);

has 'ro_connector' => (
    is => 'ro',
    lazy_build => 1,
    clearer => 'clear_ro_connector',
    predicate => 'has_ro_connector',
);

sub is_globally_read_only {
    return DBDefs->DB_READ_ONLY || DBDefs->REPLICATION_TYPE == RT_MIRROR;
}

sub prefer_ro_connector {
    my ($self) = @_;
    # There are two cases where we cannot, or do not want to use the
    # `ro_connector` (if available):
    #  * Case 1:
    #    There is a logged-in user. We want to ensure replication lag (no
    #    matter how minimal) doesn't prevent just-applied edits from being
    #    visible to them.
    #  * Case 2:
    #    We're in a current writable transaction. We should of course perform
    #    our query in the same transaction for consistency and atomicity.
    if (
        (
            defined $self->catalyst_context &&
            $self->catalyst_context->user_exists
        ) ||
        (
            $self->has_connector &&
            $self->connector->sql->is_in_transaction
        )
    ) {
        return $self->connector;
    }
    # `ro_connector` may be undef; see `_build_ro_connector`.
    return $self->ro_connector // $self->connector;
}

sub prefer_ro_dbh { shift->prefer_ro_connector->dbh }

sub prefer_ro_sql { shift->prefer_ro_connector->sql }

sub prefer_ro_conn { shift->prefer_ro_connector->conn }

has 'database' => (
    is => 'rw',
    isa => 'Str',
    default => sub {
        shift->is_globally_read_only
            ? 'READONLY'
            : 'READWRITE';
    },
    lazy => 1,
    clearer => 'clear_database',
);

has 'ro_database' => (
    is => 'rw',
    isa => 'Str',
    default => sub { 'READONLY' },
    lazy => 1,
    clearer => 'clear_ro_database',
);

has 'fresh_connector' => (
    is => 'ro',
    isa => 'Bool',
    default => sub { 0 },
);

sub _build_connector {
    my $self = shift;

    my $conn = DatabaseConnectionFactory->get_connection(
        $self->database,
        fresh => $self->fresh_connector,
    );

    if ($self->database eq 'MAINTENANCE') {
        $conn->sql->auto_commit;
        $conn->sql->do('SET statement_timeout = 0');
    }

    return $conn;
}

sub _build_ro_connector {
    my $self = shift;

    return unless (
        DBDefs->USE_RO_DATABASE_CONNECTOR &&
        !$self->is_globally_read_only
    );

    return DatabaseConnectionFactory->get_connection(
        $self->ro_database,
        fresh => $self->fresh_connector,
        read_only => 1,
    );
}

has 'models' => (
    isa     => 'HashRef',
    is      => 'ro',
    default => sub { {} },
);

has lwp => (
    is => 'ro',
    default => sub {
        my $lwp = LWP::UserAgent->new;
        $lwp->env_proxy;
        $lwp->timeout(5);
        $lwp->agent(DBDefs->LWP_USER_AGENT);
        return $lwp;
    },
);

has data_prefix => (
    isa => 'Str',
    is => 'ro',
    default => 'MusicBrainz::Server::Data',
);

has store => (
    is => 'ro',
    does => 'MusicBrainz::DataStore',
    lazy => 1,
    builder => '_build_store',
    clearer => 'clear_store',
);

sub _build_store { MusicBrainz::DataStore::RedisMulti->new }

# This is not the Catalyst stash, but it's used by
# MusicBrainz::Server::JSONLookup to trick some controller methods into
# thinking it is.
has stash => (
    is => 'rw',
    isa => 'Maybe[HashRef]',
    lazy => 1,
    default => sub { {} },
);

sub model
{
    my ($self, $name) = @_;
    my $model = $self->models->{$name};
    if (!$model) {
        my $class_name = $self->data_prefix . "::$name";
        if ($name eq 'Email') {
            $class_name =~ s/Data::Email/Email/;
        }
        load_class($class_name);
        $model = $class_name->new(c => $self);
        $self->models->{$name} = $model;
    }

    return $model;
}

sub create_script_context
{
    my ($class, %args) = @_;
    my $cache_manager = MusicBrainz::Server::CacheManager->new(DBDefs->CACHE_MANAGER_OPTIONS);
    return MusicBrainz::Server::Context->new(cache_manager => $cache_manager, database => 'MAINTENANCE', %args);
}

# `DBDefs::DETERMINE_MAX_REQUEST_TIME` must be called with a Catalyst request
# object. This attribute stores the result of that call so it can be accessed
# in the data layer.
has 'max_request_time' => (
    is => 'rw',
    isa => 'Maybe[Int]',
);

has current_language => (
    is => 'rw',
    isa => 'Str',
    default => 'en',
);

has 'catalyst_context' => (
    is => 'rw',
    isa => 'Maybe[MusicBrainz::Server]',
    weak_ref => 1,
);

1;

=head1 ATTRIBUTES

=head2 ro_database

String referencing a database name in C<DBDefs> that may be used to
distribute read-only queries to PostgreSQL standby instance if
`USE_RO_DATABASE_CONNECTOR` is enabled.

=head2 ro_connector

Connector (to `ro_database`) that may be used for read-only transactions.

=head2 catalyst_context

Provides access to the current Catalyst context. This should be used
sparingly to avoid coupling the controller and data layers.

=head1 METHODS

=head2 prefer_ro_connector()

Returns `ro_connector` unless `connector` is in a transaction, or unless
there's a logged-in user.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
