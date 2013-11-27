package MusicBrainz::Server::Data::Role::IPI;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::IPI;
use Moose::Util qw( ensure_all_roles );

parameter 'type' => (
    isa => 'Str',
    required => 1,
);

parameter 'table' => (
    isa => 'Str',
    default => sub { shift->type . "_ipi" },
    lazy => 1
);

role
{
    my $params = shift;

    requires 'c', '_entity_class';

    has 'ipi' => (
        is => 'ro',
        builder => '_build_ipi',
        lazy => 1
    );

    method '_build_ipi' => sub
    {
        my $self = shift;
        my $ipi = MusicBrainz::Server::Data::IPI->new(
            c      => $self->c,
            type => $params->type,
            table => $params->table,
            entity => $self->_entity_class . 'IPI',
            parent => $self
        );
        ensure_all_roles($ipi, 'MusicBrainz::Server::Data::Role::Editable' => { table => $params->table });
    };

    after update => sub {
        my ($self, $entity_id, $update) = @_;
        $self->ipi->set_ipis($entity_id, @{ $update->{ipi_codes} })
            if $update->{ipi_codes};
    };

};

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2012 MetaBrainz Foundation

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

