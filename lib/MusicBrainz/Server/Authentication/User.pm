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
        biography => $user->biography,
        homepage  => $user->web_url,
        id        => $user->id,
        password  => $user->password,
        type      => $user->GetUserType,
        username  => $user->name,

        has_public_subscriptions => UserPreference::get_for_user('subscriptions_public', $user),
        subscriber_count         => scalar $user->GetSubscribers,

        email_verification_date => $user->email_confirmation_date,
        email                   => $user->email,

        member_since           => $user->member_since,
        accepted_non_autoedits => $user->mods_accepted,
        accepted_autoedits     => $user->auto_mods_accepted,
        edits_voted_down       => $user->mods_rejected,
        edits_failed           => $user->mods_failed,

        privileges => $user->privs,

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
