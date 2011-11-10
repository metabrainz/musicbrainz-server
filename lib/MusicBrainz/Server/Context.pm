package MusicBrainz::Server::Context;
use Moose;

use DBDefs;
use LWP::UserAgent;
use MusicBrainz::Server::CacheManager;
use aliased 'MusicBrainz::Server::DatabaseConnectionFactory';
use Class::MOP;

has 'cache_manager' => (
    is => 'ro',
    isa => 'MusicBrainz::Server::CacheManager',
    handles => [ 'cache' ]
);

has 'conn' => (
    is => 'ro',
    handles => [ 'dbh', 'sql' ],
    lazy_build => 1,
);

sub _build_conn {
    return DatabaseConnectionFactory->get_connection('READWRITE');
}

has 'models' => (
    isa     => 'HashRef',
    is      => 'ro',
    default => sub { {} }
);

sub model
{
    my ($self, $name) = @_;
    my $model = $self->models->{$name};
    if (!$model) {
        my $class_name = "MusicBrainz::Server::Data::$name";
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
    my $cache_manager = MusicBrainz::Server::CacheManager->new(&DBDefs::CACHE_MANAGER_OPTIONS);
    return MusicBrainz::Server::Context->new(cache_manager => $cache_manager);
}

has lwp => (
    is => 'ro',
    default => sub {
        return LWP::UserAgent->new;
    }
);

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
