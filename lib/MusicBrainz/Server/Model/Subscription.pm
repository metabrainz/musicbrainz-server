package MusicBrainz::Server::Model::Subscription;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model::Base';

use UserSubscription;

sub users_subscribed_entities
{
    my ($self, $user, $type) = @_;

    my $us = UserSubscription->new($self->context->mb->{DBH});
    $us->SetUser($user->id);

    return $us->subscribed_artists;
}

sub user_artist_count
{
    my ($self, $user) = @_;

    my $us = UserSubscription->new($self->context->mb->{DBH});
    $us->SetUser($user->id);

    return $us->GetNumSubscribedArtists;
}

sub user_label_count
{
    my ($self, $user) = @_;

    my $us = UserSubscription->new($self->context->mb->{DBH});
    $us->SetUser($user->id);

    return $us->GetNumSubscribedLabels;
}

sub user_editor_count
{
    my ($self, $user) = @_;

    my $us = UserSubscription->new($self->context->mb->{DBH});
    $us->SetUser($user->id);

    return $us->GetNumSubscribedEditors;
}

sub unsubscribe_from_entities
{
    my ($self, $user, $entities) = @_;

    my $us = UserSubscription->new($self->context->mb->{DBH});
    $us->SetUser($user->id);

    $us->UnsubscribeArtists(@$entities);
}

1;
