package MusicBrainz::Server::Controller::User;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use DateTime;
use DBDefs;
use Digest::SHA qw(sha1_base64);
use Encode;
use HTTP::Status qw( :constants );
use List::Util 'sum';
use MusicBrainz::Server::Authentication::User;
use MusicBrainz::Server::ControllerUtils::SSL qw( ensure_ssl );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Log qw( log_debug );
use MusicBrainz::Server::Translation qw( l ln );
use Try::Tiny;

with 'MusicBrainz::Server::Controller::Role::Subscribe';

use MusicBrainz::Server::Constants qw(
    $BOT_FLAG
    $AUTO_EDITOR_FLAG
    $WIKI_TRANSCLUSION_FLAG
    $RELATIONSHIP_EDITOR_FLAG
    $LOCATION_EDITOR_FLAG
    $BANNER_EDITOR_FLAG
    $ACCOUNT_ADMIN_FLAG
    entities_with
);

with 'MusicBrainz::Server::Controller::Role::Load' => {
    entity_name => 'user',
    model => 'Editor'
};

__PACKAGE__->config(
    paging_limit => 25,
);

use Try::Tiny;

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

    # Can't set an attribute on a private action; manually inserting detatch code.
    $c->detach('/error_mirror_404') if ($c->stash->{server_details}->{is_slave_db});

    $c->forward('login');
    $c->detach('/user/profile', [ $c->user->name ]);
}

sub _perform_login {
    my ($self, $c, $user_name, $password) = @_;

    if ( !$c->authenticate({ username => $user_name, password => $password }) )
    {
        # Bad username / password combo
        $c->stash( bad_login => 1 );
        return 0;
    }
    else {
        if ($c->user->requires_password_reset) {
            $c->response->redirect($c->uri_for_action('/account/change_password', {
                username => $c->user->name,
                mandatory => 1
            } ));
            $c->logout;
            $c->detach;
        }
        else {
            $c->model('Editor')->update_last_login_date($c->user->id)
                unless DBDefs->DB_READ_ONLY;

            return 1;
        }
    }
}

sub do_login : Private
{
    my ($self, $c) = @_;
    return 1 if $c->user_exists;

    my $form = $c->form(form => 'User::Login');
    my $redirect = $c->req->query_params->{uri} // $c->relative_uri;

    if ($c->form_posted && $form->process(params => $c->req->params))
    {
        if ($self->_perform_login($c, $form->field("username")->value, $form->field("password")->value)) {
            if ($form->field('remember_me')->value) {
                $self->_renew_login_cookie($c, $form->field('username')->value);
            }

            # Logged in OK
            $c->response->redirect($redirect);
            $c->detach;
        }
    }

    # Form not even posted
    ensure_ssl($c);

    $c->stash(
        login_action => $c->req->uri_with({ uri => $redirect }),
        template => 'user/login.tt',
        login_form => $form
    );

    $c->stash->{required_login} = 1
        unless exists $c->stash->{required_login};

    $c->detach;
}

sub login : Path('/login') ForbiddenOnSlaves RequireSSL
{
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->response->redirect($c->uri_for_action('/user/profile',
                                                 [ $c->user->name ]));
        $c->detach;
    }

    $c->stash( required_login => 0 );
    $c->forward('/user/do_login');
}

sub logout : Path('/logout')
{
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $self->_consume_remember_me_cookie($c, $c->user->name);
        $c->logout;
        $c->delete_session;
    }

    $self->redirect_back($c, '/logout', '/');
}

sub cookie_login : Private
{
    my ($self, $c) = @_;

    return if $c->user_exists;

    if (my $user_name = $self->_consume_remember_me_cookie($c)) {
        $self->_renew_login_cookie($c, $user_name);
        $c->set_authenticated($c->find_user({ username => $user_name }));
    }
}

sub _consume_remember_me_cookie {
    my ($self, $c) = @_;

    my $cookie = $c->req->cookie('remember_login') or return;
    return unless $cookie->value;

    my $value = decode('utf-8', $cookie->value);
    $self->_clear_login_cookie($c);

    if ($value =~ /^3\t(.*?)\t(.*)$/) {
        my ($user_name, $token) = ($1, $2);

        if ($c->model('Editor')->consume_remember_me_token($user_name, $token)) {
            return $user_name;
        }
    }

    return;
}

sub _clear_login_cookie
{
    my ($self, $c) = @_;
    $c->res->cookies->{remember_login} = {
        value => '',
        expires => '+1y',
    };
}

sub _renew_login_cookie
{
    my ($self, $c, $user_name) = @_;
    my ($normalized_name, $token) = $c->model('Editor')->allocate_remember_me_token($user_name);
    my $cookie_version = 3;
    $c->res->cookies->{remember_login} = {
        expires => '+1y',
        name => 'remember_me',
        value => $token
            ? encode('utf-8', join("\t", $cookie_version, $normalized_name, $token))
            : ''
    };
}

sub base : Chained PathPart('user') CaptureArgs(0) HiddenOnSlaves { }

sub _load
{
    my ($self, $c, $user_name) = @_;

    my $user = $c->model('Editor')->get_by_name($user_name) or return;
    $c->stash->{viewing_own_profile} = $c->user_exists && $c->user->id == $user->id;

    return $user;
}

after 'load' => sub {
    my ($self, $c) = @_;

    my $user = $c->stash->{entity};

    $c->model('Area')->load($user);
    $c->model('Area')->load_containment($user->area);
};

sub _check_for_confirmed_email {
    my ($c) = @_;

    unless ($c->user->has_confirmed_email_address) {
        $c->stash(
            title    => l('Send Email'),
            message  => l('You cannot contact other users because you have not {url|confirmed your email address}.',
                          {url => $c->uri_for_action('/account/resend_verification')}),
            template => 'user/message.tt',
        );
        $c->detach;
    }
}

=head2 contact

Allows users to contact other users via email

=cut

sub contact : Chained('load') RequireAuth HiddenOnSlaves
{
    my ($self, $c) = @_;

    my $editor = $c->stash->{user};
    unless ($editor->email) {
        $c->stash(
            title    => l('Send Email'),
            message  => l('The editor {name} has no email address attached to their account.',
                         { name => $editor->name }),
            template => 'user/message.tt',
        );
        $c->detach;
    }

    _check_for_confirmed_email($c);

    if (exists $c->req->params->{sent}) {
        $c->stash( template => 'user/email_sent.tt' );
        $c->detach;
    }

    my $form = $c->form( form => 'User::Contact' );
    if ($c->form_posted && $form->process( params => $c->req->params )) {

        my $result;
        try {
            $result = $c->model('Email')->send_message_to_editor(
                from           => $c->user,
                to             => $editor,
                subject        => $form->value->{subject},
                message        => $form->value->{body},
                reveal_address => $form->value->{reveal_address},
                send_to_self   => $form->value->{send_to_self},
            );
        }
        catch {
            log_debug { "Couldn't send email: $_" } $_;
            $c->flash->{message} = l('Your message could not be sent');
        };

        $c->res->redirect($c->uri_for_action('/user/contact', [ $editor->name ], { sent => $result }));
        $c->detach;
    }
}

sub collections : Chained('load') PathPart('collections')
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};
    my $viewing_own_profile = $c->stash->{viewing_own_profile};
    my $no_collections = 1;

    my ($collections) = $c->model('Collection')->find_by({
        editor_id => $user->id,
        show_private => $viewing_own_profile ? $user->id : undef,
    });
    $c->model('Collection')->load_entity_count(@$collections);
    $c->model('CollectionType')->load(@$collections);

    $no_collections = 0 if ($no_collections && @$collections);

    for my $collection (@$collections) {
        if ($c->user_exists) {
            $collection->{'subscribed'} =
                $c->model('Collection')->subscription->check_subscription($c->user->id, $collection->id);
        }
        push @{ $c->stash->{collections}{$collection->type->entity_type} }, $collection;
    }

    $c->stash(user => $user, no_collections => $no_collections);
}

sub profile : Chained('load') PathPart('') HiddenOnSlaves
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    my $subscr_model = $c->model('Editor')->subscription;
    $c->stash->{subscribed}       = $c->user_exists && $subscr_model->check_subscription($c->user->id, $user->id);
    $c->stash->{subscriber_count} = $subscr_model->get_subscribed_editor_count($user->id);
    $c->stash->{votes}            = $c->model('Vote')->editor_statistics($user);

    $c->model('Gender')->load($user);
    $c->model('EditorLanguage')->load_for_editor($user);

    $c->stash(
        user     => $user,
        template => 'user/profile.tt',
        last_day_count => $c->model('Editor')->last_24h_edit_count($user->id),
        open_count => $c->model('Editor')->open_edit_count($user->id),
        cancelled_count => $c->model('Editor')->cancelled_edit_count($user->id)
    );
}

sub rating_summary : Chained('load') PathPart('ratings') Args(0) HiddenOnSlaves
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    if (!defined $c->user || $c->user->id != $user->id)
    {
        $c->model('Editor')->load_preferences($user);
        $c->detach('/error_403')
            unless $user->preferences->public_ratings;
    }

    my $ratings = $c->model('Editor')->summarize_ratings($user,
                        $c->stash->{viewing_own_profile});
    $c->model('ArtistCredit')->load(map { @$_ } values %$ratings);

    $c->stash(
        ratings => $ratings,
        template => 'user/ratings_summary.tt',
    );
}

sub ratings : Chained('load') PathPart('ratings') Args(1) HiddenOnSlaves
{
    my ($self, $c, $type) = @_;

    my $model = try { type_to_model($type) };

    if (!$model || !$c->model($model)->can('rating')) {
        $c->stash(
            message  => l(
                "'{type}' is not an entity type that can have ratings.",
                { type => $type }
            )
        );
        $c->detach('/error_400');
    }

    my $user = $c->stash->{user};
    if (!defined $c->user || $c->user->id != $user->id) {
        $c->model('Editor')->load_preferences($user);
        $c->detach('/error_403')
            unless $user->preferences->public_ratings;
    }

    my $ratings = $self->_load_paged($c, sub {
        $c->model($model)->rating->find_editor_ratings(
            $user->id, $c->user_exists && $user->id == $c->user->id, shift, shift)
    }, limit => 100);
    $c->model('ArtistCredit')->load(@$ratings);

    $c->stash(
        ratings => $ratings,
        type => $type
    );
}

sub tags : Chained('load') PathPart('tags')
{
    my ($self, $c) = @_;

    my $user = $c->stash->{user};

    if (!defined $c->user || $c->user->id != $user->id)
    {
        $c->model('Editor')->load_preferences($user);
        $c->detach('/error_403')
            unless $user->preferences->public_tags;
    }

    my $tags = $c->model('Editor')->get_tags($user);

    $c->stash(
        user => $user,
        tags => $tags,
        tag_max_count => sum(map { $_->{count} } @{ $tags->{tags} }),
        template => 'user/tags.tt',
    );
}

sub tag : Chained('load') PathPart('tag') Args(1)
{
    my ($self, $c, $tag_name) = @_;
    my $user = $c->stash->{user};
    my $tag = $c->model('Tag')->get_by_name($tag_name);
    my %tags = ();
    my $tag_in_use = 0;
    my @entities_with_tags = sort { $a cmp $b } entities_with('tags');

    # Determine whether this tag exists in the database
    if ($tag) {
        %tags = map {
            $_ => [ $c->model(type_to_model($_))
                        ->tags->find_editor_entities($user->id, $tag->id)
                    ]
        } @entities_with_tags;

        foreach my $entity_tags (values %tags) {
            $tag_in_use = 1 if @$entity_tags;
        }
    }
    $c->model('ArtistCredit')->load(map { @$_ } values %tags);

    $c->stash(
        tag_name => $tag_name,
        tags => \%tags,
        tag_in_use => $tag_in_use,
        entities_with_tags => \@entities_with_tags
    );
}

sub privileged : Path('/privileged')
{
    my ($self, $c) = @_;

    my @bots = $c->model('Editor')->find_by_privileges($BOT_FLAG);
    my @auto_editors = $c->model('Editor')->find_by_privileges($AUTO_EDITOR_FLAG);
    my @transclusion_editors = $c->model('Editor')->find_by_privileges($WIKI_TRANSCLUSION_FLAG);
    my @relationship_editors = $c->model('Editor')->find_by_privileges($RELATIONSHIP_EDITOR_FLAG);
    my @location_editors = $c->model('Editor')->find_by_privileges($LOCATION_EDITOR_FLAG);
    my @banner_editors = $c->model('Editor')->find_by_privileges($BANNER_EDITOR_FLAG);
    my @account_admins = $c->model('Editor')->find_by_privileges($ACCOUNT_ADMIN_FLAG);

    $c->model('Editor')->load_preferences(@bots);
    $c->model('Editor')->load_preferences(@auto_editors);
    $c->model('Editor')->load_preferences(@transclusion_editors);
    $c->model('Editor')->load_preferences(@relationship_editors);
    $c->model('Editor')->load_preferences(@location_editors);
    $c->model('Editor')->load_preferences(@banner_editors);
    $c->model('Editor')->load_preferences(@account_admins);

    $c->stash(
        bots => [ @bots ],
        auto_editors => [ @auto_editors ],
        transclusion_editors => [ @transclusion_editors ],
        relationship_editors => [ @relationship_editors ],
        location_editors => [ @location_editors ],
        banner_editors => [ @banner_editors ],
        account_admins => [ @account_admins ],
        template => 'user/privileged.tt',
    );
}

sub report : Chained('load') RequireAuth HiddenOnSlaves {
    my ($self, $c) = @_;

    my $reporter = $c->user;
    my $reported_user = $c->stash->{user};

    if ($reporter->id == $reported_user->id) {
        # A user can't report themselves
        $c->response->redirect($c->uri_for_action('/user/profile', [ $reported_user->name ]));
        $c->detach;
    }

    _check_for_confirmed_email($c);

    my $form = $c->form(form => 'User::Report');
    if ($c->form_posted && $form->process(params => $c->req->params)) {
        my @account_admins = $c->model('Editor')->find_by_privileges($ACCOUNT_ADMIN_FLAG);
        my $result;
        try {
            $result = $c->model('Email')->send_editor_report(
                reporter        => $reporter,
                reported_user   => $reported_user,
                admins          => \@account_admins,
                reason          => $form->value->{reason},
                message         => $form->value->{message},
                reveal_address  => $form->value->{reveal_address},
            );
        } catch {
            log_debug { "Couldn't send email: $_" } $_;
            $c->flash->{message} = l('An error occurred while trying to send your report.');
        };

        if ($result) {
            $c->flash->{message} = l('Your report has been sent.');
        }

        $c->detach('/user/profile', [$reported_user->name]);
    }
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles
Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
