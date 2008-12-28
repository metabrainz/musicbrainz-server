package MusicBrainz::Server::Model::Subscription;

use strict;
use warnings;

use base 'MusicBrainz::Server::Model';

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

sub is_user_subscribed_to_entity
{
    my ($self, $user, $entity) = @_;

    my $us = UserSubscription->new($self->dbh);
    $us->SetUser($user->id);

    use Switch;
    switch ($entity->entity_type)
    {
        case ('artist') { return $us->is_subscribed_to_artist($entity); }
        case ('label')  { return $us->is_subscribed_to_artist($entity); }
    }

    return;
}

1;
