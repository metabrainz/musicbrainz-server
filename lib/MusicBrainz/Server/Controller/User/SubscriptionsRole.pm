package MusicBrainz::Server::Controller::User::SubscriptionsRole;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

sub add : Local RequireAuth
{
    my ($self, $c) = @_;

    my $entity_id = $c->request->params->{id};
    $c->model($self->{model})->subscription->subscribe($c->user->id, $entity_id);

    my $url = $c->request->referer || $c->uri_for("/");
    $c->response->redirect($url);
    $c->detach;
}

sub remove : Local RequireAuth
{
    my ($self, $c) = @_;

    my $entity_id = $c->request->params->{id};
    $c->model($self->{model})->subscription->unsubscribe($c->user->id, $entity_id);

    my $url = $c->request->referer || $c->uri_for("/");
    $c->response->redirect($url);
    $c->detach;
}

sub view : Local Args(1) RequireAuth
{
    my ($self, $c, $user_name) = @_;

    my $user = $c->model('Editor')->get_by_name($user_name);

    $c->detach('/error_404')
        if (!defined $user);

    if (!defined $c->user || $c->user->id != $user->id)
    {
        $c->model('Editor')->load_preferences($user);
        $c->detach('/error_403')
            unless $user->preferences->public_subscriptions;
    }

    my $entities = $self->_load_paged($c, sub {
        $c->model($self->{model})->find_by_subscribed_editor($user->id, shift, shift);
    });

    $c->stash(
        user => $user,
        $self->{entities} => $entities,
        template => $self->{template},
    );
}

no Moose::Role;
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
