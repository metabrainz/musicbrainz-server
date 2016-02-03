package MusicBrainz::Server::Controller::Root;
use Moose;
use Try::Tiny;
BEGIN { extends 'Catalyst::Controller' }

# Import MusicBrainz libraries
use DBDefs;
use HTTP::Status qw( :constants );
use ModDefs;
use MusicBrainz::Server::Constants qw( $CONTACT_URL );
use MusicBrainz::Server::ControllerUtils::SSL qw( ensure_ssl );
use MusicBrainz::Server::Data::Utils qw( model_to_type );
use MusicBrainz::Server::Entity::URL::Sidebar qw( FAVICON_CLASSES );
use MusicBrainz::Server::Log qw( log_debug );
use MusicBrainz::Server::Replication ':replication_type';
use aliased 'MusicBrainz::Server::Translation';
use MusicBrainz::Server::Translation 'l';

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
        blog_entries => $c->model('Blog')->get_latest_entries,
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
        $c->flash->{message} =
            l('Language set. If you find any problems with the translation, please {url|help us improve it}!',
              {url => {href => 'https://www.transifex.com/musicbrainz/musicbrainz/', target => '_blank'}});
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

sub default : Path {
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

sub error_404 : Private {
    my ($self, $c) = @_;

    $c->response->status(404);
    $c->stash->{current_view} = 'Node';
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

sub begin : Private
{
    my ($self, $c) = @_;

    return if exists $c->action->attributes->{Minimal};

    ensure_ssl($c) if $c->action->attributes->{RequireSSL};

    $c->stats->enable(1) if DBDefs->DEVELOPMENT_SERVER;

    # Can we automatically login?
    if (!$c->user) {
        $c->forward('/user/cookie_login');
    }

    my $alert = '';
    my $alert_mtime;
    my ($new_edit_notes, $new_edit_notes_mtime);
    try {
        my $redis = $c->model('MB')->context->redis;

        my @cache_keys = qw( alert alert_mtime );

        if ($c->user_exists && $c->action->name ne 'notes_received') {
            my $user_name = $c->user->name;
            push @cache_keys, (
                "edit_notes_received_last_viewed:$user_name",
                "edit_notes_received_last_updated:$user_name",
            );
        }

        my ($notes_viewed, $notes_updated);
        ($alert, $alert_mtime, $notes_viewed, $notes_updated) = $redis->mget(@cache_keys);

        if ($notes_updated && (!defined($notes_viewed) || $notes_updated > $notes_viewed)) {
            $new_edit_notes = 1;
            $new_edit_notes_mtime = $notes_updated;
        }
    } catch {
        $alert = l('Our Redis server appears to be down; some features may not work as intended or expected.');
        warn "Redis connection to get alert failed: $_";
    };

    # For displaying which git branch is active as well as last commit information
    # (only shown on staging servers)
    my ($git_branch, $git_sha, $git_msg) = DBDefs->GIT_BRANCH;

    $c->stash(
        wiki_server => DBDefs->WIKITRANS_SERVER,
        server_languages => Translation->instance->all_languages(),
        server_details => {
            staging_server => DBDefs->DB_STAGING_SERVER,
            testing_features => DBDefs->DB_STAGING_TESTING_FEATURES,
            is_slave_db    => DBDefs->REPLICATION_TYPE == RT_SLAVE,
            read_only      => DBDefs->DB_READ_ONLY,
            alert => $alert,
            alert_mtime => $alert_mtime,
            git => {
                branch => $git_branch,
                sha => $git_sha,
                msg => $git_msg,
            },
        },
        favicon_css_classes => FAVICON_CLASSES,
        new_edit_notes => $new_edit_notes,
        new_edit_notes_mtime => $new_edit_notes_mtime,
        contact_url => $CONTACT_URL,
    );

    # Setup the searches on the sidebar.
    $c->form(sidebar_search => 'Search::Search');

    # Edit implies RequireAuth
    if (!exists $c->action->attributes->{RequireAuth} && exists $c->action->attributes->{Edit}) {
        $c->action->attributes->{RequireAuth} = 1;
    }

    # Returns a special 404 for areas of the site that shouldn't exist on a slave (e.g. /user pages)
    if (exists $c->action->attributes->{HiddenOnSlaves}) {
        $c->detach('/error_mirror_404') if ($c->stash->{server_details}->{is_slave_db});
    }

    # Anything that requires authentication isn't allowed on a mirror server (e.g. editing, registering)
    if (exists $c->action->attributes->{RequireAuth} || $c->action->attributes->{ForbiddenOnSlaves}) {
        $c->detach('/error_mirror') if ($c->stash->{server_details}->{is_slave_db});
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
        (!$c->user->has_confirmed_email_address || $c->user->is_editing_disabled))
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

        my @areas = ();
        push @areas, @merge if $merger->type eq 'Area';
        push @areas, $c->model('Area')->load(@merge) if $merger->type eq 'Place';
        $c->model('Area')->load_containment(@areas);

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

    if (DBDefs->REPLICATION_TYPE == RT_SLAVE) {
        $c->stash( last_replication_date => $c->model('Replication')->last_replication_date );
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
        %{ $c->stash->{server_details} // {} },
        staging_server_description => DBDefs->DB_STAGING_SERVER_DESCRIPTION,
        is_sanitized               => DBDefs->DB_STAGING_SERVER_SANITIZED,
        developement_server        => DBDefs->DEVELOPMENT_SERVER,
        beta_redirect              => DBDefs->BETA_REDIRECT_HOSTNAME,
        is_beta                    => DBDefs->IS_BETA
    };

    $c->stash->{google_analytics_code} = DBDefs->GOOGLE_ANALYTICS_CODE;

    $c->stash->{various_artist_mbid} = ModDefs::VARTIST_MBID;

    $c->stash->{wiki_server} = DBDefs->WIKITRANS_SERVER;

    $c->stash->{mapbox_map_id} = DBDefs->MAPBOX_MAP_ID;
    $c->stash->{mapbox_access_token} = DBDefs->MAPBOX_ACCESS_TOKEN;
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
