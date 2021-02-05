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

with 'MusicBrainz::Server::Controller::User::SubscriptionsRole' => {
    type => 'series',
};

after collection => sub {
    my ($self, $c) = @_;

    my $private_collection_count = scalar(grep { !$_->public } @{ $c->stash->{component_props}{entities} });
    $c->stash->{component_props}{privateCollectionCount} = $private_collection_count;

    my @public_collections = grep { $_->public } @{ $c->stash->{component_props}{entities} };
    $c->stash->{component_props}{entities} = \@public_collections;
};

sub subscriptions : Chained('/user/load') {
    my ($self, $c) = @_;
    my $user = $c->stash->{user};
    $c->response->redirect($c->uri_for_action('/user/subscriptions/artist', [ $user->name ]));
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
