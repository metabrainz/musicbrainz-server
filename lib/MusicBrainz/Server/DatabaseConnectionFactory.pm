package MusicBrainz::Server::DatabaseConnectionFactory;

use strict;
use warnings;

use aliased 'MusicBrainz::Server::Database';
use Carp qw( confess );
use Class::Load qw( load_class );

my $connector_class = 'MusicBrainz::Server::Connector';
our %databases;
our %connections;

sub register_databases
{
    my ($class, %databases) = @_;
    while (my ($key, $args) = each %databases) {
        next unless $args;
        $class->register_database($key, Database->new($args));
    }
}

sub register_database
{
    my ($class, $key, $database) = @_;
    return unless $database;
    return if $databases{$key};
    $databases{$key} = $database;
}

sub alias {
    my ($class, $alias, $key) = @_;
    $databases{$alias} = $databases{$key};
}

sub get_connection
{
    my ($class, $key, %opts) = @_;
    load_class($connector_class);

    my $database = $class->get($key);
    confess "There is no configuration in DBDefs for database $key but one is required"
        unless defined $database;

    my $read_only = 0;
    if (
        $key eq 'READONLY' ||
        $key eq 'PROD_STANDBY' ||
        $database->read_only ||
        $opts{read_only}
    ) {
        # NOTE-ROFLAG-1: This is assumed in the READONLY fallback strategy
        # below.
        $read_only = 1;
    }

    if ($opts{fresh}) {
        return $connector_class->new(
            database => $database,
            read_only => $read_only,
        );
    } else {
        my $connection = $connections{$key};
        if (
            defined $connection &&
            $read_only != $connection->read_only
        ) {
            die "The read_only flag requested for the $key database " .
                'does not match an existing cached connector.';
        }
        if (!defined $connection) {
            $connection = $connector_class->new(
                database => $database,
                read_only => $read_only,
            );
            $connections{$key} = $connection;
        }
        return $connection;
    }
}

sub connector_class
{
    my $self = shift;
    if (@_) {
        $connector_class = shift;
    }

    return $connector_class;
}

sub exists {
    my ($class, $name) = @_;
    return exists $databases{$name};
}

sub get {
    my ($class, $name) = @_;

    my $database = $databases{$name};

    unless (defined $database) {
        if ($name eq 'MAINTENANCE') {
            $database = $databases{READWRITE};
        } elsif ($name eq 'READONLY') {
            # NOTE-ROFLAG-1: We still set the `read_only` flag in
            # `get_connection` above.
            $database = $databases{READWRITE};
        } elsif ($name =~ /^READONLY_(.+)$/) {
            my $base_dbdef_key = $1;
            my $base_db = $class->get($base_dbdef_key);
            $database = $base_db->meta->clone_object(
                $base_db,
                read_only => 1,
            );
            $class->register_database($name, $database);
        } elsif ($name =~ /^SYSTEM_(.+)$/) {
            my $base_dbdef_key = $1;
            my $system = $class->get('SYSTEM');
            $database = $system->meta->clone_object(
                $system,
                database => $class->get($base_dbdef_key)->database,
            );
            $class->register_database($name, $database);
        }
    }

    return $database;
}

1;
