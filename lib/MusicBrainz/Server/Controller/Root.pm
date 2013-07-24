package MusicBrainz::Server::Controller::Root;
use Moose;
BEGIN { extends 'Catalyst::Controller' }

# Import MusicBrainz libraries
use DBDefs;
use HTTP::Status qw( :constants );
use ModDefs;
use MusicBrainz::Server::Data::Utils qw( model_to_type );
use MusicBrainz::Server::Log qw( log_debug );
use MusicBrainz::Server::Replication ':replication_type';
use aliased 'MusicBrainz::Server::Translation';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

with 'MusicBrainz::Server::Controller::Role::Profile' => {
    threshold => DBDefs->PROFILE_SITE()
};

=head1 NAME

MusicBrainz::Server::Controller::Root - Root Controller for musicbrainz

=head1 DESCRIPTION

This controller handles application wide logic for the MusicBrainz website.

=head1 METHODS

=head2 index

Render the standard MusicBrainz welcome page, which is mainly static,
other than the blog feed.

=cut

sub index : Path Args(0)
{
    my ($self, $c) = @_;

    my @newest_releases = $c->model('Release')->newest_releases_with_artwork;
    $c->model('ArtistCredit')->load(map { $_->{release} } @newest_releases);

    $c->stash(
        blog => $c->model('Blog')->get_latest_entries,
        template => 'main/index.tt',
        releases => \@newest_releases
    );
}

=head2 set_language

Sets the language; designed to be used from the language switcher

=cut

sub set_language : Path('set-language') Args(1)
{
    my ($self, $c, $lang) = @_;
    if ($lang eq 'unset') {
        # force the cookie to expire
        $c->res->cookies->{lang} = { 'value' => '', 'path' => '/', 'expires' => time()-86400 };
    } else {
        # set the cookie to expire in a year
        $c->set_language_cookie($lang);
    }
    $c->res->redirect($c->req->referer || $c->uri_for('/'));
    $c->detach;
}

=head2 set_beta_preference

Sets the preference for using the beta site, used from the footer.

=cut

sub set_beta_preference : Path('set-beta-preference') Args(0)
{
    my ($self, $c) = @_;
    if (DBDefs->BETA_REDIRECT_HOSTNAME) {
        my $new_url;
        # Set URL to go to
        if (DBDefs->IS_BETA) {
            $new_url = $c->uri_for('/') . '?unset_beta=1';
        } elsif (!DBDefs->IS_BETA) {
            $new_url = $c->req->referer || $c->uri_for('/');
            # 1 year
            $c->res->cookies->{beta} = { 'value' => 'on', 'path' => '/', 'expires' => time()+31536000 };
        }
        # Munge URL to redirect server
        my $ws = DBDefs->WEB_SERVER;
        $new_url =~ s/$ws/DBDefs->BETA_REDIRECT_HOSTNAME/e;
        $c->res->redirect($new_url);
        $c->detach;
    }
}

=head2 default

Handle any pages not matched by a specific controller path. In our case,
this means serving a 404 error page.

=cut

sub default : Path
{
    my ($self, $c) = @_;
    $c->detach('/error_404');
}

sub error_400 : Private
{
    my ($self, $c) = @_;

    $c->response->status(400);
    $c->stash->{template} = 'main/400.tt';
    $c->detach;
}

sub error_401 : Private
{
    my ($self, $c) = @_;

    $c->response->status(401);
    $c->stash->{template} = 'main/401.tt';
    $c->detach;
}

sub error_403 : Private
{
    my ($self, $c) = @_;

    $c->response->status(403);
    $c->stash->{template} = 'main/403.tt';
}

sub error_404 : Private
{
    my ($self, $c) = @_;

    $c->response->status(404);
    $c->stash->{template} = 'main/404.tt';
}

sub error_500 : Private
{
    my ($self, $c) = @_;

    $c->response->status(500);
    $c->stash->{template} = 'main/500.tt';
    $c->detach;
}

sub error_503 : Private
{
    my ($self, $c) = @_;

    $c->response->status(503);
    $c->stash->{template} = 'main/503.tt';
    $c->detach;
}

sub error_mirror : Private
{
    my ($self, $c) = @_;

    $c->response->status(403);
    $c->stash->{template} = 'main/mirror.tt';
    $c->detach;
}

sub error_mirror_404 : Private
{
    my ($self, $c) = @_;

    $c->response->status(404);
    $c->stash->{template} = 'main/mirror_404.tt';
    $c->detach;
}

sub _ssl_redirect
{
    my ($self, $c) = @_;

    return unless DBDefs->SSL_REDIRECTS_ENABLED;

    if (exists $c->action->attributes->{RequireSSL} && !$c->request->secure)
    {
        $c->response->cookies->{return_to_http} = { value => 1 };
        $c->response->redirect(
            "https://".DBDefs->WEB_SERVER_SSL.$c->request->env->{REQUEST_URI});
        return 1;
    }

    if (!exists $c->action->attributes->{RequireSSL}
        && $c->request->secure
        && $c->request->cookie ('return_to_http'))
    {
        # expire in the past == delete cookie
        $c->response->cookies->{return_to_http} = { value => 1, expires => '-1m' };
        $c->response->redirect(
            "http://".DBDefs->WEB_SERVER.$c->request->env->{REQUEST_URI});
        return 1;
    }

    return 0;
}

sub begin : Private
{
    my ($self, $c) = @_;

    return if exists $c->action->attributes->{Minimal};

    return if $self->_ssl_redirect ($c);

    $c->stats->enable(1) if DBDefs->DEVELOPMENT_SERVER;

    # if no javascript cookie is set we don't know if javascript is enabled or not.
    my $jscookie = $c->request->cookie('javascript');
    my $js = $jscookie ? $jscookie->value : "unknown";
    $c->response->cookies->{javascript} = { value => ($js eq "unknown" ? "false" : $js) };

    $c->stash(
        javascript => $js,
        no_javascript => $js eq "false",
        wiki_server => DBDefs->WIKITRANS_SERVER,
        server_languages => Translation->instance->all_languages(),
        server_details => {
            staging_server => DBDefs->DB_STAGING_SERVER,
            testing_features => DBDefs->DB_STAGING_TESTING_FEATURES,
            is_slave_db    => DBDefs->REPLICATION_TYPE == RT_SLAVE,
            read_only      => DBDefs->DB_READ_ONLY
        },
    );

    # Setup the searchs on the sidebar
    $c->form( sidebar_search => 'Search::Search' );

    # Returns a special 404 for areas of the site that shouldn't exist on a slave (e.g. /user pages)
    if (exists $c->action->attributes->{HiddenOnSlaves}) {
        $c->detach('/error_mirror_404') if ($c->stash->{server_details}->{is_slave_db});
    }

    # Anything that requires authentication isn't allowed on a mirror server (e.g. editing, registering)
    if (exists $c->action->attributes->{RequireAuth} || $c->action->attributes->{ForbiddenOnSlaves}) {
        $c->detach('/error_mirror') if ($c->stash->{server_details}->{is_slave_db});
    }

    # Can we automatically login?
    if (!$c->user_exists) {
        $c->forward('/user/cookie_login');
    }

    if (exists $c->action->attributes->{RequireAuth})
    {
        $c->forward('/user/do_login');
        my $privs = $c->action->attributes->{RequireAuth};
        if ($privs && ref($privs) eq "ARRAY") {
            foreach my $priv (@$privs) {
                last unless $priv;
                my $accessor = "is_$priv";
                if (!$c->user->$accessor) {
                    $c->detach('/error_403');
                }
            }
        }
    }

    if (exists $c->action->attributes->{Edit} && $c->user_exists &&
        !$c->user->has_confirmed_email_address)
    {
        $c->forward('/error_401');
    }

    if (DBDefs->DB_READ_ONLY && (exists $c->action->attributes->{Edit} ||
                                 exists $c->action->attributes->{DenyWhenReadonly})) {
        $c->stash( message => 'The server is currently in read only mode and is not accepting edits');
        $c->forward('/error_400');
    }

    # Update the tagger port
    if (exists $c->req->query_params->{tport})
    {
        $c->session->{tport} = $c->req->query_params->{tport};
    }

    # Merging
    if (my $merger = $c->try_get_session('merger')) {
        my $model = $c->model($merger->type);
        my @merge = values %{
            $model->get_by_ids($merger->all_entities)
        };
        $c->model('ArtistCredit')->load(@merge);

        $c->stash(
            to_merge => [ @merge ],
            merger => $merger,
            merge_link => $c->uri_for_action(
                model_to_type($merger->type) . '/merge',
            )
        );
    }

    my $r = $c->model('RateLimiter')->check_rate_limit('frontend ip=' . $c->req->address);
    if ($r && $r->is_over_limit) {
        $c->response->status(HTTP_SERVICE_UNAVAILABLE);
        $c->res->headers->header(
            'X-Rate-Limited' => sprintf('%.1f %.1f %d', $r->rate, $r->limit, $r->period)
        );
        $c->stash(
            template => 'main/rate_limited.tt',
            rl_response => $r
        );
        $c->detach;
    }
}

=head2 end

Attempt to render a view, if needed. This will also set up some global variables in the
context containing important information about the server used on the majority of templates,
and also the current user.

=cut

sub end : ActionClass('RenderView')
{
    my ($self, $c) = @_;

    return if exists $c->action->attributes->{Minimal};

    $c->stash->{server_details} = {
        staging_server             => DBDefs->DB_STAGING_SERVER,
        staging_server_description => DBDefs->DB_STAGING_SERVER_DESCRIPTION,
        testing_features           => DBDefs->DB_STAGING_TESTING_FEATURES,
        is_slave_db                => DBDefs->REPLICATION_TYPE == RT_SLAVE,
        is_sanitized               => DBDefs->DB_STAGING_SERVER_SANITIZED,
        developement_server        => DBDefs->DEVELOPMENT_SERVER,
        beta_redirect              => DBDefs->BETA_REDIRECT_HOSTNAME,
        is_beta                    => DBDefs->IS_BETA
    };

    # For displaying which git branch is active as well as last commit information
    # (only shown on staging servers)
    my ($git_branch, $git_sha, $git_msg) = DBDefs->GIT_BRANCH;
    $c->stash->{server_details}->{git}->{branch} = $git_branch;
    $c->stash->{server_details}->{git}->{sha}    = $git_sha;
    $c->stash->{server_details}->{git}->{msg}    = $git_msg;

    $c->stash->{google_analytics_code} = DBDefs->GOOGLE_ANALYTICS_CODE;

    # For displaying release attributes
    $c->stash->{release_attribute}        = \&MusicBrainz::Server::Release::attribute_name;
    $c->stash->{plural_release_attribute} = \&MusicBrainz::Server::Release::attribute_name_as_plural;

    # Working with quality levels
    $c->stash->{data_quality} = \&ModDefs::GetQualityText;

    # Displaying track lengths
    $c->stash->{track_length} =\&MusicBrainz::Server::Track::FormatTrackLength;

    $c->stash->{artist_type} = \&MusicBrainz::Server::Artist::type_name;
    $c->stash->{begin_date_name} = \&MusicBrainz::Server::Artist::begin_date_name;
    $c->stash->{end_date_name  } = \&MusicBrainz::Server::Artist::end_date_name;

    $c->stash->{vote} = \&ModDefs::vote_name;

    $c->stash->{release_format} = \&MusicBrainz::Server::ReleaseEvent::release_format_name;

    $c->stash->{various_artist_mbid} = ModDefs::VARTIST_MBID;

    $c->stash->{wiki_server} = DBDefs->WIKITRANS_SERVER;
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
