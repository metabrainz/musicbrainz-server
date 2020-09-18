package MusicBrainz::Server::Controller::Root;
use Digest::MD5 qw( md5_hex );
use Moose;
use Try::Tiny;
use List::Util qw( max );
use Readonly;
use URI::QueryParam;

BEGIN { extends 'Catalyst::Controller' }

# Import MusicBrainz libraries
use DBDefs;
use MusicBrainz::Server::Constants qw( $VARTIST_GID $CONTACT_URL );
use MusicBrainz::Server::ControllerUtils::SSL qw( ensure_ssl );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json type_to_model );
use MusicBrainz::Server::Log qw( log_debug );
use MusicBrainz::Server::Replication ':replication_type';
use aliased 'MusicBrainz::Server::Translation';
use MusicBrainz::Server::Translation 'l';

Readonly my $IP_STORE_EXPIRES => (60 * 60 * 24 * 30 * 6); # 6 months

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
        current_view => 'Node',
        component_path => 'main/index.js',
        component_props => {
            blogEntries => $c->model('Blog')->get_latest_entries,
            newestReleases => \@newest_releases,
        },
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
    $c->redirect_back;
}

=head2 set_beta_preference

Sets the preference for using the beta site, used from the footer.

=cut

sub set_beta_preference : Path('set-beta-preference') Args(0)
{
    my ($self, $c) = @_;
    if (DBDefs->BETA_REDIRECT_HOSTNAME) {
        my $is_beta = DBDefs->IS_BETA;
        if (!$is_beta) {
            # 1 year
            $c->res->cookies->{beta} = {
                'value' => 'on',
                'path' => '/',
                'expires' => time()+31536000,
                $c->req->secure ? (
                    'samesite' => 'None',
                    'secure' => '1',
                ) : (),
            };
        }
        $c->redirect_back(
            callback => sub {
                my $returnto = shift;
                # Munge URL to redirect server
                $returnto->authority(DBDefs->BETA_REDIRECT_HOSTNAME);
                if ($is_beta) {
                    $returnto->query_param(unset_beta => 1);
                }
            },
        );
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

    my %props = (
        hostname => $c->stash->{hostname},
        message => $c->stash->{message},
        useLanguages => boolean_to_json($c->stash->{use_languages}),
    );

    $c->stash(
        component_path => 'main/error/400',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub error_401 : Private
{
    my ($self, $c) = @_;

    $c->response->status(401);
    $c->stash->{template} = 'main/401.tt';
}

sub error_403 : Private
{
    my ($self, $c) = @_;

    $c->response->status(403);
    $c->stash->{template} = 'main/403.tt';
}

sub error_404 : Private {
    my ($self, $c, $message) = @_;

    $c->response->status(404);
    $c->stash->{current_view} = 'Node';
    $c->stash->{component_props} = {
        message => $message,
    };
    $c->stash->{component_path} = 'main/error/404';
}

sub error_500 : Private
{
    my ($self, $c) = @_;

    $c->response->status(500);
    $c->stash->{template} = 'main/500.tt';
}

sub error_503 : Private
{
    my ($self, $c) = @_;

    $c->response->status(503);
    $c->stash->{template} = 'main/503.tt';
}

sub error_mirror : Private
{
    my ($self, $c) = @_;

    $c->response->status(403);
    $c->stash->{template} = 'main/mirror.tt';
}

sub error_mirror_404 : Private
{
    my ($self, $c) = @_;

    $c->response->status(404);
    $c->stash->{template} = 'main/mirror_404.tt';
}

sub begin : Private
{
    my ($self, $c) = @_;

    my $attributes = $c->action->attributes;

    ensure_ssl($c) if $attributes->{RequireSSL};

    if (exists $attributes->{SecureForm}) {
        $c->set_csp_headers;
    }

    $c->stats->enable(1) if DBDefs->DEVELOPMENT_SERVER;

    # Can we automatically login?
    if (!$c->user) {
        $c->forward('/user/cookie_login');
    }

    # Allow browsers to report MB pages as referrers, even when going from
    # HTTPS to an HTTP page.
    $c->res->header('Referrer-Policy' => 'unsafe-url');

    my $alert = '';
    my $alert_mtime;
    my @alert_cache_keys = DBDefs->IS_BETA
        ? qw( beta:alert beta:alert_mtime )
        : qw( alert alert_mtime );

    my ($new_edit_notes, $new_edit_notes_mtime);
    try {
        my $store = $c->model('MB')->context->store;

        if ($c->user_exists) {
            if (!DBDefs->DB_STAGING_SERVER ||
                !DBDefs->DB_STAGING_SERVER_SANITIZED)
            {
                my $ip_md5 = md5_hex($c->req->address);
                my $user_id = $c->user->id;

                $store->set_add("ipusers:$ip_md5", $user_id);
                $store->expire("ipusers:$ip_md5", $IP_STORE_EXPIRES);

                $store->set_add("userips:$user_id", $ip_md5);
                $store->expire("userips:$user_id", $IP_STORE_EXPIRES);
            }

            if ($c->action->name ne 'notes_received') {
                my $user_name = $c->user->name;
                push @alert_cache_keys, (
                    "edit_notes_received_last_viewed:$user_name",
                    "edit_notes_received_last_updated:$user_name",
                );
            }
        }

        my ($notes_viewed, $notes_updated);
        ($alert, $alert_mtime, $notes_viewed, $notes_updated) =
            @{$store->get_multi(@alert_cache_keys)}{@alert_cache_keys};

        if ($notes_updated && (!defined($notes_viewed) || $notes_updated > $notes_viewed)) {
            $new_edit_notes = 1;
            $new_edit_notes_mtime = $notes_updated;
        }
    } catch {
        $alert = l('Our Redis server appears to be down; some features may not work as intended or expected.');
        warn "Redis connection to get alert failed: $_";
    };
    if ($c->user_exists && $c->user->is_banner_editor) {
        # For banner editors, show a dismissed banner again after 20 hours (MBS-8940)
        $alert_mtime = max($alert_mtime // 0, time()-20*60*60);
    }

    # For displaying which git branch is active as well as last commit information
    # (only shown on staging servers)
    my %git_info;
    if (DBDefs->DB_STAGING_SERVER) {
        $git_info{branch} = DBDefs->GIT_BRANCH;
        $git_info{sha} = DBDefs->GIT_SHA;
        $git_info{msg} = DBDefs->GIT_MSG;
    }

    $c->stash(
        wiki_server => DBDefs->WIKITRANS_SERVER,
        server_languages => Translation->instance->all_languages,
        server_details => {
            staging_server => DBDefs->DB_STAGING_SERVER,
            testing_features => DBDefs->DB_STAGING_TESTING_FEATURES,
            is_slave_db    => DBDefs->REPLICATION_TYPE == RT_SLAVE,
            read_only      => DBDefs->DB_READ_ONLY,
            alert => $alert,
            alert_mtime => $alert_mtime,
            git => \%git_info,
        },
        new_edit_notes => $new_edit_notes,
        new_edit_notes_mtime => $new_edit_notes_mtime,
        contact_url => $CONTACT_URL,
        component_props => {},
    );

    # Setup the searches on the sidebar.
    $c->form(sidebar_search => 'Search::Search');

    # NOTE: The following checks are not applied to /ws/js/edit. If you change
    # anything here, make sure it is reflected there, too (if applicable).

    # Edit implies RequireAuth
    if (!exists $attributes->{RequireAuth} && exists $attributes->{Edit}) {
        $attributes->{RequireAuth} = 1;
    }

    # Returns a special 404 for areas of the site that shouldn't exist on a slave (e.g. /user pages)
    if (exists $attributes->{HiddenOnSlaves}) {
        $c->detach('/error_mirror_404') if ($c->stash->{server_details}->{is_slave_db});
    }

    # Anything that requires authentication isn't allowed on a mirror server (e.g. editing, registering)
    if (exists $attributes->{RequireAuth} || $attributes->{ForbiddenOnSlaves}) {
        $c->detach('/error_mirror') if ($c->stash->{server_details}->{is_slave_db});
    }

    if (exists $attributes->{RequireAuth})
    {
        if ($c->form_posted && $c->is_cross_origin) {
            my $post_params = $c->req->body_params;
            if (defined $post_params && scalar(%$post_params)) {
                my $external_origin = $c->req->header('Origin');
                $c->set_csp_headers;
                $c->stash(
                    current_view => 'Node',
                    component_path => 'main/ConfirmSeed',
                    component_props => {
                        origin => $external_origin,
                        postParameters => $post_params,
                    },
                );
                $c->detach;
            }
        }
        $c->stash->{current_action_requires_auth} = 1;
        $c->forward('/user/do_login');
        my $privs = $attributes->{RequireAuth};
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

    if (exists $attributes->{Edit} && $c->user_exists &&
        (!$c->user->has_confirmed_email_address || $c->user->is_editing_disabled))
    {
        $c->detach('/error_401');
    }

    if (DBDefs->DB_READ_ONLY && (exists $attributes->{Edit} ||
                                 exists $attributes->{DenyWhenReadonly})) {
        $c->stash( message => 'The server is currently in read only mode and is not accepting edits');
        $c->detach('/error_400');
    }

    # Update the tagger port
    if (defined $c->req->query_params->{tport}) {
        my ($tport) = $c->req->query_params->{tport} =~ /^([0-9]{1,5})$/
            or $c->detach('/error_400');
        $c->session->{tport} = $tport;
    }

    # Merging
    if (my $merger = $c->try_get_session('merger')) {
        my $model = $c->model(type_to_model($merger->type));
        my @merge = values %{
            $model->get_by_ids($merger->all_entities)
        };
        $c->model('ArtistCredit')->load(@merge);

        my @areas = ();
        push @areas, @merge if $merger->type eq 'area';
        push @areas, $c->model('Area')->load(@merge) if $merger->type eq 'place';
        $c->model('Area')->load_containment(@areas);

        $c->stash(
            to_merge => [ @merge ],
            merger => $merger,
            merge_link => $c->uri_for_action($merger->type . '/merge'),
        );
    }

    if (DBDefs->REPLICATION_TYPE == RT_SLAVE) {
        my $last_replication_date = $c->model('Replication')->last_replication_date;
        defined $last_replication_date or die 'Replication info missing on a slave server';
        $c->stash( last_replication_date => $last_replication_date );
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

    my $attrs = $c->action->attributes;

    $c->stash->{server_details} = {
        %{ $c->stash->{server_details} // {} },
        staging_server_description => DBDefs->DB_STAGING_SERVER_DESCRIPTION,
        is_sanitized               => DBDefs->DB_STAGING_SERVER_SANITIZED,
        development_server         => DBDefs->DEVELOPMENT_SERVER,
        beta_redirect              => DBDefs->BETA_REDIRECT_HOSTNAME,
        is_beta                    => DBDefs->IS_BETA
    };

    $c->stash->{various_artist_mbid} = $VARTIST_GID;

    $c->stash->{wiki_server} = DBDefs->WIKITRANS_SERVER;
}

if ($ENV{MUSICBRAINZ_RUNNING_TESTS}) {
    # Test method for t::MusicBrainz::Server::Controller::Errors
    my $method = sub { die 'die die' };
    __PACKAGE__->meta->add_method(die_die_die => $method);
    __PACKAGE__->meta->register_method_attributes(
        $method,
        [q[Path('die-die-die')]],
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
