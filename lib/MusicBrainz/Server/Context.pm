package MusicBrainz::Server::Context;
use Moose;

use DBDefs;
use MusicBrainz::DataStore::Redis;
use MusicBrainz::Server::Replication ':replication_type';
use MusicBrainz::Server::CacheManager;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory';
use Class::MOP;
use LWP::UserAgent;

has 'cache_manager' => (
    is => 'ro',
    isa => 'MusicBrainz::Server::CacheManager',
    handles => [ 'cache' ]
);

has 'connector' => (
    is => 'ro',
    handles => [ 'dbh', 'sql', 'conn' ],
    lazy_build => 1,
);

has 'database' => (
    is => 'ro',
    isa => 'Str',
    default => sub { DBDefs->REPLICATION_TYPE == RT_SLAVE ? 'READONLY' : 'READWRITE' }
);

sub _build_connector {
    my $self = shift;
    return DatabaseConnectionFactory->get_connection($self->database);
}

has 'models' => (
    isa     => 'HashRef',
    is      => 'ro',
    default => sub { {} }
);

has lwp => (
    is => 'ro',
    default => sub {
        my $lwp = LWP::UserAgent->new;
        $lwp->env_proxy;
        $lwp->timeout(5);
        return $lwp;
    }
);

has data_prefix => (
    isa => 'Str',
    is => 'ro',
    default => 'MusicBrainz::Server::Data'
);

has redis => (
    is => 'ro',
    does => 'MusicBrainz::DataStore',
    lazy => 1,
    default => sub { MusicBrainz::DataStore::Redis->new }
);

sub model
{
    my ($self, $name) = @_;
    my $model = $self->models->{$name};
    if (!$model) {
        my $class_name = $self->data_prefix . "::$name";
        if ($name eq "Email") {
            $class_name =~ s/Data::Email/Email/;
        }
        Class::MOP::load_class($class_name);
        $model = $class_name->new(c => $self);
        $self->models->{$name} = $model;
    }

    return $model;
}

sub create_script_context
{
    my ($class, %args) = @_;
    my $cache_manager = MusicBrainz::Server::CacheManager->new(DBDefs->CACHE_MANAGER_OPTIONS);
    return MusicBrainz::Server::Context->new(cache_manager => $cache_manager, %args);
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
