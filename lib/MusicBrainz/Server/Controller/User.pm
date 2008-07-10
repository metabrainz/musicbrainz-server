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

=cut

# index {{{
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
# }}}
# login {{{
=head2 login

Handle logging in users

=cut

sub login : Local
{
    my ($self, $c) = @_;

    if ($c->user_exists) {
        my $redir = $c->flash->{login_redirect} || $c->uri_for('/user/profile');
        $c->response->redirect($redir);
        $c->detach;
    }

    use MusicBrainz::Server::Form::User::Login;

    my $form = MusicBrainz::Server::Form::User::Login->new;
    $c->stash->{form} = $form;

    if ($c->form_posted && $form->validate($c->request->parameters))
    {
        my ($username, $password) = ( $form->value("username"),
                                      $form->value("password") );

        if( $c->authenticate({ username => $username,
                               password => $password }) )
        {
            my $redir = $c->flash->{login_redirect} || $c->uri_for('/user/profile');
            $c->response->redirect($redir);
            $c->detach;
        }
        else
        {
            $c->stash->{errors} = ['Username/password combination invalid'];
        }
    }

    $c->stash->{template} = 'user/login.tt';
}
# }}}
# register {{{
=head2 register

Handle user registration

=cut

sub register : Local
{
    use MusicBrainz::Server::Form::User::Register;

    my ($self, $c) = @_;

    my $form = MusicBrainz::Server::Form::User::Register->new;
    $c->stash->{form} = $form;

    if($c->form_posted && $form->validate($c->request->parameters))
    {
        my $mb = $c->mb;
	
        my $ui = UserStuff->new($mb->{DBH});
        my ($userobj, $createlogin) = $ui->CreateLogin($form->value('username'),
                                                       $form->value('password'),
                                                       $form->value('confirm_password'));

        my $email = $form->value('email');

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
# }}}
# registered {{{
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
# }}}
#  forgotPassword {{{
sub forgotPassword : Local
{
    my ($self, $c) = @_;

    use MusicBrainz::Server::Form::User::ForgotPassword;

    my $form = new MusicBrainz::Server::Form::User::ForgotPassword;
    $c->stash->{form} = $form;

    if ($c->form_posted && $form->validate($c->req->params))
    {
        my ($email, $username) = ( $form->value('email'),
                                   $form->value('username') );
        my $us = new UserStuff($c->mb->{DBH});

        if ($email)
        {
            my $usernames = $us->LookupNameByEmail($email);
            if(scalar @$usernames)
            {
                foreach $username (@$usernames)
                {
                    my $user = $us->newFromName($username);
                    if ($user)
                    {
                        $user->SendPasswordReminder
                            or die "Could not send password reminder";
                    }
                }

            $c->flash->{ok} = "A password reminder has been sent to you. Please check your inbox for more details";
            }
            else
            {
                $c->field('email')->add_error('We could not find any users registered with this email address');
            }
        }
        elsif ($username)
        {
            my $user = $us->newFromName ($username);
            if ($user)
            {
                $user->SendPasswordReminder
                    or die "Could not send password reminder";

                $c->flash->{ok} = "A password reminder has been sent to you. Please check your inbox for more details";
            }
            else
            {
                $form->field('username')->add_error("This user does not exist");
            }
        }
        else
        {
            $c->stash->{errors} = "You must fill in either an email address or a username";
        }
    }

    $c->stash->{template} = 'user/forgot.tt';
}
# }}}
# editProfile {{{
sub editProfile : Local
{
    my ($self, $c) = @_;

    use MusicBrainz::Server::Form::User::EditProfile;
    my $form = new MusicBrainz::Server::Form::User::EditProfile;
    $c->stash->{form} = $form;

    if ($c->form_posted && $form->validate ($c->req->params))
    {
        my %opts;

        $opts{email} = $form->value('email');
        $opts{bio} = $form->value('biography');
        $opts{weburl} = $form->value('homepage');

        $c->user->get_object->SetUserInfo(%opts)
            or die "Could not update profile";
        $c->flash->{ok} = "Your profile has been sucessfully updated";
    }

    $c->stash->{template} = 'user/edit.tt';
}
# }}}
# changePassword {{{
sub changePassword : Local
{
    my ($self, $c) = @_;

    use MusicBrainz::Server::Form::User::ChangePassword;
    my $form = new MusicBrainz::Server::Form::User::ChangePassword;
    $c->stash->{form} = $form;

    if ($c->form_posted && $form->validate($c->req->params))
    {
        if ($form->value('old_password') eq $c->user->get_object->GetPassword)
        {
            $c->user->get_object->ChangePassword( $form->value('old_password'),
                                                  $form->value('new_password'),
                                                  $form->value('confirm_new_password') );

            $c->flash->{ok} = "Your password has been successfully changed";
        }
        else
        {
            $form->field('old_password')->add_error("Old password is incorrect.");
        }
    }

    $c->stash->{template} = 'user/changePassword.tt';
}
# }}}
# profile {{{
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
            $c->stash->{viewing_own_profile} = 1
                unless defined $userName and $user->GetName ne $userName;
        }
        else
        {
            $c->response->redirect($c->uri_for('/user/login'));
            $c->detach();
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
# }}}
# logout {{{
=head2 logout

Logout the current user. Has no effect if the user is already logged out.

=cut

sub logout : Local
{
    my ($self, $c) = @_;

    $c->logout;
    $c->response->redirect($c->uri_for('/user/login'));
}
# }}}
# preferences {{{
=head2 preferences

Change the users preferences

=cut

sub preferences : Local
{
    use MusicBrainz::Server::Form::User::Preferences;

    my ($self, $c) = @_;

    die "You must be logged in" unless $c->user_exists;
    
    my $form = MusicBrainz::Server::Form::User::Preferences->new($c->user->get_object->GetName);
    $form->build_form;
    $c->stash->{form} = $form;

    $form->update_from_form ($c->req->params)
        if $c->form_posted;

    $c->stash->{template} = 'user/preferences.tt';
}
# }}}
# donate {{{
=head2 donate

Check the status of donations and ask for one.

=cut

sub donate : Local
{
    my ($self, $c) = @_;
    my $mb = $c->mb;
    my $us = UserStuff->new($mb->{DBH});
    my $user;
    
    $user = $c->user->get_object;
    my ($nag, $days) = $us->NagCheck();
    
    $c->stash->{donateinfo} = {
        'nag' => 1,
        'days' => 1
    };
    $c->stash->{template} = 'user/donate.tt';
}
# }}}

=head1 AUTHOR

Oliver Charles <oliver.g.charles@googlemail.com>
Mustaqil 'Muzzz' Ali

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
