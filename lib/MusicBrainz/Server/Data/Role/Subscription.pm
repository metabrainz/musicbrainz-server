package MusicBrainz::Server::Data::Role::Subscription;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::Subscription;

parameter 'table' => (
    isa => 'Str',
    required => 1,
);

parameter 'column' => (
    isa => 'Str',
    required => 1,
);

parameter 'active_class' => (
    isa => 'Str',
    required => 1
);

parameter 'deleted_class' => (
    isa => 'Str',
);

role
{
    my $params = shift;

    requires 'c';

    has 'subscription' => (
        is => 'ro',
        lazy => 1,
        builder => '_build_subscription_data',
    );

    method '_build_subscription_data' => sub
    {
        my $self = shift;
        return MusicBrainz::Server::Data::Subscription->new(
            c => $self->c,
            table => $params->table,
            column => $params->column,
            active_class => $params->active_class,
            deleted_class => $params->deleted_class
        );
    };
};

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

