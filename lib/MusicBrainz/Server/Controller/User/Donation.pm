package MusicBrainz::Server::Controller::User::Donation;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

sub view : Chained('/user/base') PathPart('donation') RequireAuth
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    $c->detach('/error_403')
        unless $c->{stash}->{viewing_own_profile};

    my $result = $c->model('Editor')->donation_check ($user);
    $c->detach('/error_500') unless $result;

    $c->stash(
        nag => $result->{nag},
        days => sprintf ("%.0f", $result->{days}),
        template => 'user/donation.tt',
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
