package MusicBrainz::Server::Controller::Account::SubscriptionsRole;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';

sub add : Local RequireAuth HiddenOnSlaves DenyWhenReadonly
{
    my ($self, $c) = @_;

    my $entity_id = $c->request->params->{id};
    $c->model($self->{model})->subscription->subscribe($c->user->id, $entity_id);
    $c->redirect_back;
}

sub remove : Local RequireAuth HiddenOnSlaves DenyWhenReadonly
{
    my ($self, $c) = @_;

    my $entity_id = $c->request->params->{id};
    my @entities = ref($entity_id) ? @$entity_id : ($entity_id);
    $c->model($self->{model})->subscription->unsubscribe($c->user->id, @entities);
    $c->redirect_back;
}

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
