package MusicBrainz::Server::Controller::User;

use strict;
use warnings;
use parent 'Catalyst::Controller';

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
    my ( $self, $c ) = @_;

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

sub login : Local {
    my ($self, $c) = @_;

    $c->stash->{template} = 'user/login.tt';
}

=head2 processLogin
Process login details from a POST request (from /user/login/).
=cut

sub processLogin : Path("process-login") {
    require MusicBrainz;
    require UserStuff;
    
    my ($self, $c) = @_;

    my $username = $c->request->params->{username};
    my $password = $c->request->params->{password};

    my $mb = new MusicBrainz;
    $mb->Login();

    my $us = UserStuff->new($mb->{DBH});
    my $user = $us->Login($username, $password);
    if($user) {
	$c->session->{user} = {
	    name => $user->GetName
	};
	$c->response->redirect($c->uri_for('/user/profile'));
    } else {
	$c->error("FAIL");
    }
}

=head2 profile
Display a users profile page.
=cut 

sub profile : Local {
    my ($self, $c) = @_;

    $c->stash->{template} = 'user/profile.tt';
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
