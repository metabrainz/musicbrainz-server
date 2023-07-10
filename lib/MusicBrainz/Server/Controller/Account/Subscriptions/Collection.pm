package MusicBrainz::Server::Controller::Account::Subscriptions::Collection;
use Moose;
use namespace::autoclean;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Translation qw( l );

with 'MusicBrainz::Server::Controller::Account::SubscriptionsRole';

__PACKAGE__->config( model => 'Collection' );

before add => sub
{
    my ($self, $c) = @_;

    my $entity_id = $c->request->params->{id};
    my $entity = $c->model($self->{model})->get_by_id($entity_id);

    if (!$entity) {
        $c->stash(
            message  => l('The provided collection ID doesn’t exist.')
        );
        $c->detach('/error_400');
    }

    my $is_authorized = (
        $entity->public ||
        $c->user->id == $entity->editor_id ||
        $c->model('Collection')->is_collection_collaborator(
            $c->user->id,
            $entity->id,
        )
    );

    $c->detach('/error_403') if (!$is_authorized);
};

__PACKAGE__->meta->make_immutable;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
