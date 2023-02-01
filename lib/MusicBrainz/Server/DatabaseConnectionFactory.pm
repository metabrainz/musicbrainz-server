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

    if ($opts{fresh}) {
        return $connector_class->new( database => $database );
    } else {
        $connections{ $key } ||= do {
            confess "There is no configuration in DBDefs for database $key but one is required" unless defined($database);
            $connector_class->new( database => $database );
        };

        return $connections{ $key };
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

sub get {
    my ($class, $name) = @_;

    my $database = $databases{$name};

    if ($name eq 'MAINTENANCE' && !defined($database)) {
        $database = $databases{READWRITE};
    }

    return $database;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
