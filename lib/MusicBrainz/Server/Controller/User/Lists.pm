package MusicBrainz::Server::Controller::User::Lists;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

sub view : Chained('/user/base') PathPart('lists')
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    $c->detach('/error_404')
        if (!defined $user);

    my $show_private = $c->stash->{viewing_own_profile};

    my $lists = $self->_load_paged($c, sub {
        $c->model('List')->find_by_editor($user->id, $show_private, shift, shift);
    });

    $c->stash(
        user => $user,
        lists => $lists,
        template => 'user/lists.tt',
    );
}

1;

=head1 COPYRIGHT

Copyright (C) 2010 Sean Burke

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
