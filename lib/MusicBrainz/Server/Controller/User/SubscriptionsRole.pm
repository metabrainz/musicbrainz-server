package MusicBrainz::Server::Controller::User::SubscriptionsRole;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

parameter 'type' => (
    required => 1
);

role {
    my $params = shift;
    my $type   = $params->type;

    my %extra = @_;

    $extra{consumer}->name->config(
        action => {
            $type => { Chained => '/user/load', PathPart => "subscriptions/$type",
                      RequireAuth => undef, HiddenOnSlaves => undef }
        }
    );

    method $type => sub {
        my ($self, $c) = @_;

        my $user = $c->stash->{user};

        if (!defined $c->user || $c->user->id != $user->id) {
            $c->model('Editor')->load_preferences($user);
            $c->detach('/error_403')
                unless $user->preferences->public_subscriptions;
        }

        my $entities = $self->_load_paged($c, sub {
            $c->model(type_to_model($type))->find_by_subscribed_editor($user->id, shift, shift);
        });
        my %extra_props;

        if ($type eq 'collection') {
            # Show only public collections by default
            my @private_collections = grep { !$_->public } @{$entities};
            $entities = [grep { $_->public } @{$entities}];

            # If not logged in, all private collections are hidden
            if (!$c->user) {
                $extra_props{hiddenPrivateCollectionCount} =
                    scalar(@private_collections);
            } else {
                my @visible_private_collections;
                my $hidden_private_collection_count;

                for my $collection (@private_collections) {
                    my $is_collection_owner =
                        $collection->editor_id == $c->user->id;
                    if ($is_collection_owner) {
                        push @visible_private_collections, $collection;
                        next;
                    }

                    my $is_collection_collaborator =
                        $c->model('Collection')->is_collection_collaborator(
                            $c->user->id,
                            $collection->id);
                    if ($is_collection_collaborator) {
                        push @visible_private_collections, $collection;
                        next;
                    }
                    $hidden_private_collection_count++;
                }
                $extra_props{visiblePrivateCollections} =
                    to_json_array(\@visible_private_collections);
                $extra_props{hiddenPrivateCollectionCount} =
                    $hidden_private_collection_count;
            }
        }

        $c->stash(
            current_view => 'Node',
            component_path => 'user/UserSubscriptions',
            component_props => {
                entities  => to_json_array($entities),
                user      => $c->controller('User')->serialize_user($user),
                summary   => $c->model('Editor')->subscription_summary($user->id),
                type      => $type,
                pager     => serialize_pager($c->stash->{pager}),
                %extra_props,
            },
        );
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
