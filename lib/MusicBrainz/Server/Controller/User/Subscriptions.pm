package MusicBrainz::Server::Controller::User::Subscriptions;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

with 'MusicBrainz::Server::Controller::User::SubscriptionsRole' => {
    type => 'artist',
};

with 'MusicBrainz::Server::Controller::User::SubscriptionsRole' => {
    type => 'collection',
};

with 'MusicBrainz::Server::Controller::User::SubscriptionsRole' => {
    type => 'editor',
};

with 'MusicBrainz::Server::Controller::User::SubscriptionsRole' => {
    type => 'label',
};

sub subscriptions : Chained('/user/load') {
    my ($self, $c) = @_;
    my $user = $c->stash->{user};
    $c->response->redirect($c->uri_for_action('/user/subscriptions/artist', [ $user->name ]));
}

1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation
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
