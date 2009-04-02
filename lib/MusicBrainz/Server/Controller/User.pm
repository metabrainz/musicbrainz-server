package MusicBrainz::Server::Controller::User;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

use Digest::SHA1 qw(sha1_base64);
use MusicBrainz;
use MusicBrainz::Server::Editor;
use UserPreference;

=head1 NAME

MusicBrainz::Server::Controller::User - Catalyst Controller to handle
user authentication and profile management

=head1 DESCRIPTION

The user controller handles users logging in and logging out, the
registration or administration of accounts, and the viewing/updating of
profile pages.

=head1 METHODS

=head2 index

If the user is currently logged in redirect them to their profile page,
otherwise redirect the user to the login page.

=cut

sub index : Private
{
    my ($self, $c) = @_;

    $c->forward('login');
    $c->detach('profile', [ $c->user->name ]);
}

=head2 login

Display a form allowing users to login. If a POST request is received,
we validate this login data, and attempt to log the user in.

=cut

sub login : Private
{
    my ($self, $c) = @_;

    return 1
        if MusicBrainz::Server::Editor->TryAutoLogin($c);

    return 1
        if $c->user_exists;

    use MusicBrainz::Server::Form::User::Login;
    $self->form(MusicBrainz::Server::Form::User::Login->new);

    $c->stash->{template}         = 'user/login.tt';
    $c->stash->{form}             = $self->form;
    $c->session->{__login_dest} ||= $c->req->uri;

    $c->detach unless $self->submit_and_validate($c);

    if( !$c->authenticate({ username => $self->form->value("username"),
                            password => $self->form->value("password") }) )
    {
        $self->form->add_general_error('Username/password combination invalid');
        $c->detach;
    }
    else
    {
        if ($self->form->value('remember_me'))
        {
            $c->user->SetPermanentCookie($c,
                only_this_ip => $self->form->value('single_ip')
            );
        }
    }
    
    $c->response->redirect(delete $c->session->{__login_dest});
    $c->detach;
}

sub login_form : Local Path('login')
{
    my ($self, $c) = @_;

    $c->detach('/user/profile', [ $c->user->name ])
        if $c->user_exists;

    unless (defined $c->session->{__login_dest})
    {
        # Only redirect to referer if it came from $base
        # (the hostname of this server)
        my $base    = $c->req->base;
        my $referer = $c->req->referer;

        $c->session->{__login_dest} = $referer =~ $base
            ? $referer : $c->uri_for('/')
    }

    $c->forward('/user/login');

    if ($c->user_exists)
    {
        # As strange as this condition appears, it happens
        # if users clicks login while being on the login page
        $c->response->redirect($c->uri_for('/'));
        $c->detach;
    }
}

=head2 register

Display a form allowing new users to register on the site. When a POST
request is received, we validate the data and attempt to create the
new user.

=cut

sub register : Local Form
{
    my ($self, $c) = @_;

    $c->detach('profile', [ $c->user->name ])
        if $c->user_exists;

    my $form = $self->form;

    return unless $self->submit_and_validate($c);

    my $new_user = $c->model('User')->create($form->value('username'),
                                             $form->value('password'));

    my $email = $form->value('email');

    $c->authenticate({ username => $new_user->name,
                       password => $new_user->password });

    my $email_sent = undef;
    if ($email)
    {
        $self->_send_confirmation_email($c, $new_user, $email);
        $email_sent = scalar @{ $c->error } == 0;
    }

    $c->stash->{email_sent} = defined $email && scalar @{ $c->error } == 0;
    $c->stash->{template}   = 'user/registered.tt';
}

=head2 _send_confirmation_email

Send out an email allowing users to confirm their email address

=cut

sub _send_confirmation_email
{
    my ($self, $c, $user, $email) = @_;

    my $time     = time;
    my $checksum = $self->_checksum($email, $user->id, $time);

    $c->stash->{verification_link} = $c->uri_for('/user/verify', {
        userid => $user->id,
        email  => $email,
        time   => $time,
        chk    => $checksum,
    });

    $c->stash->{email} = {
        header => [
            'Reply-To' => 'MusicBrainz Support <support@musicbrainz.org>',
        ],
        to           => $email,
        from         => 'MusicBrainz <webserver@musicbrainz.org>',
        subject      => 'Please verify your email address',
        content_type => 'text/plain',
        template     => 'email/confirm_address.tt',
    };

    $c->forward($c->view('Email::Template'));
}

sub _checksum
{
    my ($self, $email, $uid, $time) = @_;
    return sha1_base64("$email $uid $time " . DBDefs::SMTP_SECRET_CHECKSUM);
}

=head2 verify

Verify the email address (this is the URL handed out in "verify your email
address" emails)

=cut

sub verify : Local
{
    my ($self, $c) = @_;

    my $user_id = $c->request->query_params->{userid};
    my $email   = $c->request->query_params->{email};
    my $time    = $c->request->query_params->{time};
    my $key     = $c->request->query_params->{chk};

    die "The user ID is missing or, is in an invalid format"
        unless MusicBrainz::Server::Validation::IsNonNegInteger($user_id) && $user_id;

    die "The email address is missing"
        unless $email;

    die "The time is missing, or is in an invalid format"
        unless MusicBrainz::Server::Validation::IsNonNegInteger($time) && $time;

    die "The key is missing"
        unless $key;

    die "The checksum is invalid, please double check your email"
        unless $self->_checksum($email, $user_id, $time) eq $key;

    if (($time + DBDefs::EMAIL_VERIFICATION_TIMEOUT) < time)
    {
        die "Sorry, this email verification link has expired";
    }
    else
    {
        my $user = $c->model('User')->load({ id => $user_id });

        die "User with id $user_id could not be found"
            unless $user;

        $user->SetUserInfo(email => $email)
            or die "Could not update user information";
        $user->email($email);

        $c->stash->{template} = 'user/verified.tt';
    }
}

=head2 forgot_password

Allow users to retrieve their password if they have forgotten it.

This displays a form allowing the user to enter either their username
or email address in. With this data we then attempt to email the user
their password.

=cut

sub forgot_password : Local Form
{
    my ($self, $c) = @_;

    my $form = $self->form;

    return unless $self->submit_and_validate($c);

    my ($email, $username) = ( $form->value('email'),
                               $form->value('username') );

    my $user = undef;

    if ($email)
    {
        my $usernames = $c->model('User')->find_by_email($email);
        if(scalar @$usernames)
        {
            foreach $username (@$usernames)
            {
                $user = $c->model('User')->load({ username => $username });
                last if defined $user;
            }
        }
        else
        {
            $c->field('email')->add_error('We could not find any users registered with this email address');
        }
    }
    elsif ($username)
    {
        $user = $c->model('User')->load({ username => $username });
    }

    if (defined $user)
    {
        $c->stash->{username} = $user->name;
        $c->stash->{password} = $user->password;

        $c->stash->{email} = {
            header => [
                'Reply-To' => 'MusicBrainz Support <support@musicbrainz.org>',
            ],
            from     => 'MusicBrainz <webserver@musicbrainz.org>',
            to       => $user->email,
            subject  => 'Your MusicBrainz account',
            content_type => 'text/plain',

            template => 'email/forgot_password.tt',
        };

        $c->forward($c->view('Email::Template'));
    }
}

=head2 edit

Display a form to allow users to edit their profile, or (if a POST
request is received), update the profile data in the database.

=cut

sub edit : Local Form('User::EditProfile')
{
    my ($self, $c) = @_;

    $c->forward('login');

    # We refresh $c->user as this is no longed loaded from the database
    # on each request
    my $form = $self->form;
    $c->user->Refresh;
    $form->init($c->user);

    return unless $self->submit_and_validate($c);

    $form->update_model;

    $c->flash->{ok} = "Your profile has been sucessfully updated";
    $c->response->redirect('/user/');
    $c->detach;
}

=head2 change_password

Allow users to change their password. This displays a form prompting
for their old password and a new password (with confirmation), which
when use to update the database data when we receive a valid POST request.

=cut

sub change_password : Local Form
{
    my ($self, $c) = @_;

    $c->forward('login');

    my $form = $self->form;

    return unless $self->submit_and_validate($c);

    $c->user->Refresh;
    if ($form->value('old_password') eq $c->user->password)
    {
        $c->user->ChangePassword( $form->value('old_password'),
                                  $form->value('new_password'),
                                  $form->value('confirm_new_password') );

        $c->flash->{ok} = "Your password has been successfully changed";
    }
    else
    {
        $form->field('old_password')->add_error("Old password is incorrect.");
    }
}

=head2 profile

Display a users profile page.

=cut

sub profile : Local Args(1)
{
    my ($self, $c, $user_name) = @_;

    my $user = $c->model('User')->load({ username => $user_name });

    $c->detach('/error_404')
        if (!defined $user);

    if ($c->user_exists && $c->user->id eq $user->id)
    {
        $c->stash->{viewing_own_profile} = 1;
    }

    my $vote = MusicBrainz::Server::Vote->new($c->mb->dbh);
    my $all_votes = $vote->AllVotesForUser_as_hashref($user->id);
    my $recent_votes = $vote->RecentVotesForUser_as_hashref($user->id);

    for ($all_votes, $recent_votes)
    {
        my $t = 0;
        $t += $_ for values %$_;
        $_->{"TOTAL"} = $t;
    }

    $c->stash->{votes}= [];
    for my $v (
        [ "yes", &ModDefs::VOTE_YES ],
        [ "no", &ModDefs::VOTE_NO ],
        [ "abstain", &ModDefs::VOTE_ABS ],
        [ "total", "TOTAL" ] 
    ) {
        my $recent = $recent_votes->{$v->[1]};
        my $all    = $all_votes->{$v->[1]};

        push @{ $c->stash->{votes} }, {
            name    => $v->[0],
            recent  => $recent || 0,
            overall => $all    || 0,
            
            recent_pc  => int(($recent / ($recent_votes->{TOTAL} || 1)) * 100 + 0.5),
            overall_pc => int(($all / ($all_votes->{TOTAL} || 1)) * 100 + 0.5),
        };
    }

    $c->stash->{preferences} = $c->model('User')->get_preferences_hash($user);

    $c->stash->{user    } = $user;
    $c->stash->{template} = 'user/profile.tt';
}

=head2 contact

Allows users to contact other users via email

=cut

sub contact : Local Args(1) Form
{
    my ($self, $c, $user_name) = @_;

    $c->forward('login');

    my $user = $c->model('User')->load({ username => $user_name });

    if (!defined $user)
    {
        $c->response->status(404);
        $c->error("User with user name $user_name not found");
        $c->detach;
    }

    unless ($user->CheckEMailAddress) {
        die "User has not got an email address attached to their account";
    }

    $c->stash->{user} = $user;

    return unless $self->submit_and_validate($c);

    my $form = $self->form;
    my $reveal_address = $form->value('reveal_address');

    $c->stash->{message}        = $form->value('body');
    $c->stash->{reveal_address} = $reveal_address;
    
    $c->stash->{email} = {
        to      => $user->email,
        sender  => 'MusicBrainz Server <webserver@musicbrainz.org>',
        subject => $form->value('subject'),
        
        template => 'email/internal_email.tt',
    };

    if ($reveal_address)
    {
        $c->stash->{email}->{from} = sprintf("%s <%s>", $c->user->name, $c->user->email);
    }
    else
    {
        $c->stash->{email}->{header} = {
            'Reply-To' => 'Nobody <noreply@musicbrainz.org>',
        };
        $c->stash->{email}->{from} = sprintf('%s <%s@users.musicbrainz.org>', $c->user->name, $c->user->name);
    }
    
    $c->forward($c->view('Email::Template'));
    $c->stash->{template} = 'user/email_sent.tt';
}

=head2 subscriptions

View all subscriptions

=cut

sub subscriptions : Local
{
    my ($self, $c, $type) = @_;

    $c->forward('/user/login');

    $type ||= 'artist';

    my $page = $c->req->query_params->{page} || 1;
    my ($entities, $pager) = $c->model('Subscription')->users_subscribed_entities($c->user, $type, $page);

    $c->stash->{type}     = $type;
    $c->stash->{entities} = $entities;
    $c->stash->{pager}    = $pager;

    $c->stash->{artist_count} = $c->model('Subscription')->user_artist_count($c->user);
    $c->stash->{label_count } = $c->model('Subscription')->user_label_count($c->user);
    $c->stash->{editor_count} = $c->model('Subscription')->user_editor_count($c->user);

    return unless $c->form_posted;

    # Make sure we have a list of IDs
    my $ids = $c->req->params->{id};
    $ids    = ref $ids ? $ids : [ $ids ];

    my @entities = map
        {
            my $class = "MusicBrainz::Server::" . ucfirst($type);
            my $obj = $class->new($c->mb->{dbh});
            $obj->id($_);

            $obj;
        } @$ids;

    use Switch;
    switch($type)
    {
        case ('artist') {
            $c->model('Subscription')->unsubscribe_from_artists($c->user, [ @entities ]);
        }
        
        case ('label') {
            $c->model('Subscription')->unsubscribe_from_labels($c->user, [ @entities ]);
        }
    }

    $c->response->redirect($c->req->uri);
}

=head2 logout

Logout the current user. Has no effect if the user is already logged out.

=cut

sub logout : Local
{
    my ($self, $c) = @_;

    if ($c->user_exists)
    {
        $c->user->ClearPermanentCookie($c);
        $c->logout;

        delete $c->session->{orig_privs};
        delete $c->session->{session_privs};
    }

    $c->response->redirect($c->uri_for('/'));
}

=head2 preferences

Change the users preferences

=cut

sub preferences : Local Form
{
    my ($self, $c) = @_;

    $c->forward('login');

    my $prefs = UserPreference->newFromUser($c->mb->dbh, $c->user->id);
    $prefs->load;

    my $form = $self->form;
    $form->init($prefs);

    return unless $self->submit_and_validate($c);

    $form->update_from_form($c->req->params);
    $c->user->preferences($prefs);
    $c->persist_user;
}

=head2 donate

Check the status of donations and ask for one.

=cut

sub donate : Local
{
    my ($self, $c) = @_;

    $c->forward('login');

    my $user = $c->user;
    my @donateinfo = MusicBrainz::Server::Editor::NagCheck($user);

    $c->stash->{nag} = $donateinfo[0];
    $c->stash->{days} = int($donateinfo[1]);
    $c->stash->{template} = 'user/donate.tt';
}

=head2 adjust_flags

Allow a user to adjust their user flags (only works on test servers)

=cut

sub adjust_flags : Local Form
{
    my ($self, $c) = @_;

    use MusicBrainz::Server::Replication ':replication_type';
    use DBDefs;
    $c->detach('/error_404')
        unless (DBDefs::REPLICATION_TYPE == RT_STANDALONE);

    $c->forward('/user/login');

    my $form = $self->form;
    $c->user->Refresh;
    $form->init($c->user);

    return unless $self->submit_and_validate($c);

    $c->user->SetUserInfo(
        privs =>
            ($form->value('auto_editor') && &MusicBrainz::Server::Editor::AUTOMOD_FLAG) |
            ($form->value('untrusted') && &MusicBrainz::Server::Editor::UNTRUSTED_FLAG) |
            ($form->value('bot') && &MusicBrainz::Server::Editor::BOT_FLAG) |
            ($form->value('link_editor') && &MusicBrainz::Server::Editor::LINK_MODERATOR_FLAG) |
            ($form->value('wiki_transcluder') && &MusicBrainz::Server::Editor::WIKI_TRANSCLUSION_FLAG) |
            ($form->value('mbid_submitter') && &MusicBrainz::Server::Editor::MBID_SUBMITTER_FLAG)
    );
}

=head1 LICENSE

This software is provided "as is", without warranty of any kind, express or
implied, including  but not limited  to the warranties of  merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or  copyright  holders be  liable for any claim,  damages or  other
liability, whether  in an  action of  contract, tort  or otherwise, arising
from,  out of  or in  connection with  the software or  the  use  or  other
dealings in the software.

GPL - The GNU General Public License    http://www.gnu.org/licenses/gpl.txt
Permits anyone the right to use and modify the software without limitations
as long as proper  credits are given  and the original  and modified source
code are included. Requires  that the final product, software derivate from
the original  source or any  software  utilizing a GPL  component, such  as
this, is also licensed under the GPL license.

=cut

1;
