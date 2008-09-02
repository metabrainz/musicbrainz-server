package MusicBrainz::Server::Authentication::User;

use strict;
use warnings;

use UserPreference;

use base qw(Catalyst::Authentication::User);

__PACKAGE__->mk_accessors(qw(
    biography
    homepage
    id
    password
    type
    username

    email
    email_verification_date

    has_public_subscriptions
    subscriber_count

    member_since
    accepted_non_autoedits
    accepted_autoedits
    edits_voted_down
    edits_failed

    privileges
));

sub new
{
    my ($class, $user) = @_;

    return undef
        unless ref $user;

    bless {
        biography => $user->GetBio,
        homepage  => $user->GetWebURL,
        id        => $user->id,
        password  => $user->GetPassword,
        type      => $user->GetUserType,
        username  => $user->GetName,

        has_public_subscriptions => UserPreference::get_for_user('subscriptions_public', $user),
        subscriber_count         => scalar $user->GetSubscribers,

        email_verification_date => $user->GetEmailConfirmDate,
        email                   => $user->GetEmail,

        member_since           => $user->GetMemberSince,
        accepted_non_autoedits => $user->GetModsAccepted,
        accepted_autoedits     => $user->GetAutoModsAccepted,
        edits_voted_down       => $user->GetModsRejected,
        edits_failed           => $user->GetModsFailed,

        privileges => $user->GetPrivs,

        _u => $user,
    }, $class;
}

sub get_user
{
    my $self = shift;
    $self->{_u};
}

sub supported_features
{
    { session => 1 };
}

1;
