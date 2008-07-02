package MusicBrainz::Server::Controller::User;

use strict;
use warnings;
use base 'Catalyst::Controller';

use MusicBrainz;
use UserPreference;
use UserStuff;

=head1 NAME

musicbrainz::Controller::User - Catalyst Controller to handle user authentication and profile
management

=head1 DESCRIPTION

The User controller handles the Users logging in and logging out, along with providing logic for
updating & managing user profiles

=head1 METHODS

=head2 index

If the user is currently logged in redirect them to their profile page, otherwise redirect the user
to the login page.

=cut

sub index : Private
{
    my ($self, $c) = @_;

    if($c->user_exists)
    {
        # If we are logged in, redirect to profile page
        $c->response->redirect($c->uri_for('/user/profile'));
	    $c->detach();
    }
    else
    {
        # Not logged in, redirect to the login page
        $c->response->redirect($c->uri_for('/user/login'));
        $c->detach();
    }
}

=head2 login

Handle logging in users

=cut

sub login : Local Form
{
    my ($self, $c) = @_;

    if ($c->form->submitted && $c->form->validate)
    {
        my ($username, $password) = ( $c->form->field("username"),
                                      $c->form->field("password") );

        if( $c->authenticate({ username => $username,
                               password => $password }) )
        {
            $c->response->redirect($c->uri_for('/user/profile'));
            $c->detach();
        }
    }

    $c->stash->{template} = 'user/login.tt';
}

=head2 register

Handle user registration

=cut

sub register : Local Form
{
    my ($self, $c) = @_;

    if($c->form->submitted && $c->form->validate)
    {
        my $mb = $c->mb;
	
        my $ui = UserStuff->new($mb->{DBH});
        my ($userobj, $createlogin) = $ui->CreateLogin($c->form->field('username'),
                                                       $c->form->field('password'),
                                                       $c->form->field('confirm_password'));

        my $email = $c->form->field('email');

        # if createlogin list is empty, the user was created.
        if (@$createlogin == 0)
        {
            # Send the email if possible
            my $couldSend = $userobj->SendVerificationEmail($email);

            $c->authenticate({ username => $userobj->GetName,
                               password => $userobj->GetPassword });
            $c->detach('registered', $couldSend, $email);
        }
        else
        {
            $c->stash->{errors} = \@$createlogin;
        }
    }

    $c->stash->{template} = 'user/register.tt';
}

=head2 registered

Called when a user has completed registration. We use this to notify the user that everything
went ok

=cut

sub registered : Private
{
    my ($self, $c, $couldSend, $email) = @_;

    $c->stash->{emailed} = $couldSend;
    $c->stash->{email} = $email;

    $c->stash->{template} = 'user/registered.tt';
}

=head2 profile

Display a users profile page.

=cut 

sub profile : Local
{
    my ($self, $c, $userName) = @_;

    my $mb = $c->mb;
    
    my $us = UserStuff->new($mb->{DBH});
    my $user;
    
    if ($userName)
    {
        $user = $us->newFromName($userName);
    }
    else
    {
        if ($c->user_exists)
        {
            $user = $c->user->get_object;
            $c->stash->{viewing_own_profile} = 1 if defined $userName and $user->GetName eq $userName;
        }
        else
        {
            die "No username specified, please login or specify a users profile to vie";
        }
    }

    die "The user with username '" . $userName . "' could not be found"
        unless $user;

    $c->stash->{profile} = {
        name => $user->GetName,
        type => $user->GetUserType,
        email => {
            address => $user->GetEmail,
            verified_at => $user->GetEmailConfirmDate,
        },
        homepage => $user->GetWebURL,
        biography => $user->GetBio,
        public_subscriptions => UserPreference::get_for_user("subscriptions_public", $user),
        subscriber_count => scalar $user->GetSubscribers,

        member_since => $user->GetMemberSince,
        accepted_non_autoedits => $user->GetModsAccepted,
        accepted_autoedits => $user->GetAutoModsAccepted,
        edits_voted_down => $user->GetModsRejected,
        other_failed_edits => $user->GetModsFailed,
    };

    $c->stash->{template} = 'user/profile.tt';

    $c->stash->{filter} = sub { \&date };
}

=head2 logout

Logout the current user. Has no effect if the user is already logged out.

=cut

sub logout : Local
{
    my ($self, $c) = @_;

    $c->logout;
    $c->response->redirect($c->uri_for('/user/login'));
}

=head2 preferences

Change the users preferences

=cut

sub preferences : Local Form
{
  my ($self, $c) = @_;

  $c->stash->{template} = 'user/preferences.tt';
}

=head1 AUTHOR

Oliver Charles <oliver.g.charles@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
