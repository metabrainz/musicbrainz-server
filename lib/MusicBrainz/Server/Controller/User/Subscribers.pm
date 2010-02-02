package MusicBrainz::Server::Controller::User::Subscribers;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

__PACKAGE__->config(
    model => 'Editor',
    entities => 'editors',
);

sub view : Chained('/user/base') PathPart('subscribers') RequireAuth
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    my $entities = $self->_load_paged($c, sub {
        $c->model($self->{model})->find_subscribers ($user->id, shift, shift);
    });

    $c->stash(
        user => $user,
        $self->{entities} => $entities,
        template => 'user/subscribers.tt',
    );
}

1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

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
