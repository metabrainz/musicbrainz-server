package MusicBrainz::Server::Context;

use Moose;
use MusicBrainz;
use UNIVERSAL::require;

has 'cache_manager' => (
    is => 'ro',
    isa => 'MusicBrainz::Server::CacheManager',
    handles => [ 'cache' ]
);

has '_logout' => (
    is => 'rw',
    isa => 'Int',
    default => 0
);

has 'mb' => (
    is => 'ro',
    isa => 'MusicBrainz',
    lazy => 1,
    required => 0,
    default => sub {
        my $self = shift;
        my $mb = MusicBrainz->new;
        $mb->Login;
        $self->_logout($self->_logout | 1);
        return $mb;
    },
    handles => [ 'dbh' ]
);

has 'raw_mb' => (
    is => 'ro',
    isa => 'MusicBrainz',
    lazy => 1,
    required => 0,
    default => sub {
        my $self = shift;
        my $mb = MusicBrainz->new;
        $mb->Login(db => 'RAWDATA');
        $self->_logout($self->_logout | 2);
        return $mb;
    },
    handles => { 'raw_dbh' => 'dbh' }
);

sub logout
{
    my $self = shift;

    $self->mb->Logout if $self->_logout & 1;
    $self->raw_mb->Logout if $self->_logout & 2;
}

sub model
{
    my ($self, $name) = @_;
    my $class_name = "MusicBrainz::Server::Data::$name";
    $class_name->require;
    return $class_name->new(c => $self);
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
