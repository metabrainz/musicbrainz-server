package MusicBrainz::Server::Controller::User::Subscriptions;
use Moose;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

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

with 'MusicBrainz::Server::Controller::User::SubscriptionsRole' => {
    type => 'series',
};

sub subscriptions : Chained('/user/load') {
    my ($self, $c) = @_;
    my $user = $c->stash->{user};
    $c->model('Editor')->load_preferences($user);

    my $is_admin_viewing_private = defined $c->user &&
                                   $c->user->is_account_admin &&
                                   $c->user->id != $user->id &&
                                   !$user->preferences->public_subscriptions;

    if ($is_admin_viewing_private) {
        $c->response->redirect(
            $c->uri_for_action('/user/subscriptions/editor', [ $user->name ])
        );
    } else {
        $c->response->redirect(
            $c->uri_for_action('/user/subscriptions/artist', [ $user->name ])
        );
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
