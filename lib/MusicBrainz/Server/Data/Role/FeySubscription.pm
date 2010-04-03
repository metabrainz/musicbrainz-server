package MusicBrainz::Server::Data::Role::FeySubscription;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::Data::FeySubscription;

parameter 'subscription_table';

role {
    my $params    = shift;
    my $sub_table = $params->subscription_table;

    has 'subscription' => (
        is         => 'ro',
        lazy_build => 1
    );

    method _build_subscription => sub {
        my $self = shift;
        return MusicBrainz::Server::Data::FeySubscription->new(
            c      => $self->c,
            table  => $sub_table,
            parent => $self
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
