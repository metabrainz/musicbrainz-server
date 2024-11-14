package MusicBrainz::Server::Controller::Role::Subscribe;
use Moose::Role -traits => 'MooseX::MethodAttributes::Role::Meta::Role';
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use namespace::autoclean;

use List::AllUtils qw( part );

sub subscribers : Chained('load') RequireAuth {
    my ($self, $c) = @_;

    my $model = $self->{model};
    my $entity = $c->stash->{ $self->{entity_name} };

    # Don't show private collections to people without rights to see them
    if ($model eq 'Collection') {
        my $is_authorized = (
            $entity->public ||
            $c->user->id == $entity->editor_id ||
            $c->model('Collection')->is_collection_collaborator($c->user->id, $entity->id)
        );

        $c->detach('/error_403') if (!$is_authorized);
    }

    my @all_editors = $c->model($model)->subscription->find_subscribed_editors($entity->id);
    $c->model('Editor')->load_preferences(@all_editors);
    my ($public, $private) = part { $_->preferences->public_subscriptions ? 0 : 1 } @all_editors;

    $public ||= [];
    $private ||= [];

    my $entity_json;
    if ($entity->isa('MusicBrainz::Server::Entity::Editor')) {
        $entity_json = $c->controller('User')->serialize_user($entity);
    } else {
        $entity_json = $entity->TO_JSON;
    }

    my %props = (
        entity => $entity_json,
        privateEditors => scalar @$private,
        publicEditors => to_json_array($public),
        subscribed => boolean_to_json(
            $c->model($model)->subscription->check_subscription($c->user->id, $entity->id)),
    );

     $c->stash(
        component_path => 'entity/Subscribers',
        component_props => \%props,
        current_view => 'Node',
    );

}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
