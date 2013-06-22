package MusicBrainz::Server::Controller::Account::SubscriptionsRole;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

sub add : Local RequireAuth HiddenOnSlaves DenyWhenReadonly
{
    my ($self, $c) = @_;

    my $entity_id = $c->request->params->{id};
    $c->model($self->{model})->subscription->subscribe($c->user->id, $entity_id);

    my $url = $c->request->referer || $c->uri_for("/");
    $c->response->redirect($url);
    $c->detach;
}

sub remove : Local RequireAuth HiddenOnSlaves DenyWhenReadonly
{
    my ($self, $c) = @_;

    my $entity_id = $c->request->params->{id};
    my @entities = ref($entity_id) ? @$entity_id : ($entity_id);
    $c->model($self->{model})->subscription->unsubscribe($c->user->id, @entities);

    my $url = $c->request->referer || $c->uri_for("/");
    $c->response->redirect($url);
    $c->detach;
}

no Moose::Role;
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
