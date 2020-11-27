package MusicBrainz::Server::Controller::User::SubscriptionsRole;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;

use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );

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

        $c->stash(
            current_view => 'Node',
            component_path => 'user/UserSubscriptions',
            component_props => {
                entities  => $entities,
                user      => $c->controller('User')->serialize_user($user),
                summary   => $c->model('Editor')->subscription_summary($user->id),
                type      => $type,
                pager     => serialize_pager($c->stash->{pager}),
            },
        );
    };
};

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
