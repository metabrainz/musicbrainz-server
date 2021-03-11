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
            $extra_props{privateCollectionCount} = scalar(grep { !$_->public } @{$entities});
            $entities = [grep { $_->public } @{$entities}]
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
