package MusicBrainz::Server::Controller::User;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME
musicbrainz::Controller::User - Catalyst Controller to handle user authentication and profile management

=head1 DESCRIPTION
The User controller handles the Users logging in and logging out, along with providing logic for updating &
managing user profiles

=head1 METHODS
=cut

=head2 index 
If the user is currently logged in redirect them to their profile page, otherwise redirect the user to the login page.
=cut

sub index : Private {
    my ($self, $c) = @_;

    if(defined $c->session->{user}) {
	# If we are logged in, redirect to profile page
	#
	$c->response->redirect($c->uri_for('/user/profile'));
	$c->detach();
    } else {
	# Not logged in, redirect to the login page
	#
	$c->response->redirect($c->uri_for('/user/login'));
	$c->detach();
    }
}

=head2 login
Handle logging in users
=cut

sub login : Local Form {
    my ($self, $c) = @_;

    if($c->form->submitted && $c->form->validate)
    {
	require MusicBrainz;
	require UserStuff;
    
	my ($self, $c) = @_;

	my $username = $c->request->params->{username};
	my $password = $c->request->params->{password};
	
	my $mb = new MusicBrainz;
	$mb->Login();
	
	my $us = UserStuff->new($mb->{DBH});
	my $user = $us->Login($username, $password);
	if($user)
	{
	    $c->session->{user} = {
		name => $user->GetName
	    };
	    $c->response->redirect($c->uri_for('/user/profile'));
	}
	else
	{
	    $c->error("FAIL");
	}
    }
    else
    {
	$c->stash->{template} = 'user/login.tt';
    }
}

=head2 register
Handle user registration
=cut

sub register : Local Form
{
    my ($self, $c) = @_;

    if($c->form->submitted && $c->form->validate)
    {
    }
    else
    {
	$c->stash->{template} = 'user/register.tt';
    }
}

=head2 profile
Display a users profile page.
=cut 

sub profile : Local {
    require UserStuff;
    require MusicBrainz;
    require UserPreference;
    
    my ($self, $c, $userName) = @_;

    my $userId = $userName or $c->session->{user}->{name};

    my $mb = new MusicBrainz;
    $mb->Login();
    
    my $us = UserStuff->new($mb->{DBH});
    my $user = $us->newFromName($userId);

    $c->stash->{viewing_own_profile} = $c->session->{user}->{name} eq $userId;

    $c->stash->{user} = {
	name => $userId,
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

sub logout : Local {
    my ($self, $c) = @_;
    $c->session->{user} = undef;
    $c->response->redirect($c->uri_for('/user/login'));
}

=head1 AUTHOR
Oliver Charles

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
