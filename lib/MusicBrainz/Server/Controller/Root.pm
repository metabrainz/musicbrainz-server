package MusicBrainz::Server::Controller::Root;

use strict;
use warnings;

use base 'Catalyst::Controller';

# Import MusicBrainz libraries
use DBDefs;
use ModDefs;
use MusicBrainz::Server::Replication ':replication_type';
use UserPreference;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

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

    $c->stash->{template} = 'main/index.tt';
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

sub js_text_strings : Path('/text.js') {
    my ($self, $c) = @_;
    $c->res->content_type('text/javascript');
    $c->stash->{template} = 'scripts/text_strings.tt';
}

sub js_unit_tests : Path('/unit_tests') {
    my ($self, $c) = @_;
    $c->stash->{template} = 'scripts/unit_tests.tt';
}

sub begin : Private
{
    my ($self, $c) = @_;

    return if exists $c->action->attributes->{Minimal};

    if ($c->user_exists) {
        if (exists $c->session->{collection}) {
            $c->stash->{user_collection} = $c->session->{collection};
        }
        else {
            my $id = $c->model('Collection')->find_collection($c->user);
            $c->stash->{user_collection} = $id;
            $c->session->{collection} = $id;
        }
    }

    if ($c->req->user_agent && $c->req->user_agent =~ /MSIE/i) {
        $c->stash->{looks_like_ie} = 1;
        $c->stash->{needs_chrome} = !($c->req->user_agent =~ /chromeframe/i);
    }

    # Setup the searchs on the sidebar
    $c->form( sidebar_search => 'Search::Search' );

    if (exists $c->action->attributes->{RequireAuth})
    {
        $c->forward('/user/do_login');
        my $privs = $c->action->attributes->{RequireAuth};
        if ($privs && ref($privs) eq "ARRAY") {
            foreach my $priv (@$privs) {
                last unless $priv;
                my $accessor = "is_$priv";
                if (!$c->user->$accessor) {
                    $c->detach('/error_404'); # XXX use 403
                }
            }
        }
    }

    if (exists $c->action->attributes->{Edit} && $c->user_exists)
    {
        $c->forward('/error_401') unless $c->user->has_confirmed_email_address;
    }

    # Load current relationship
    my $rel = $c->session->{current_relationship};
    if ($rel)
    {
    $c->stash->{current_relationship} = $c->model(ucfirst $rel->{type})->load($rel->{id});
    }

    # Update the tagger port
    if (exists $c->req->query_params->{tport})
    {
        $c->session->{tport} = $c->req->query_params->{tport};
    }

    $c->stash(
        staging_server => DBDefs::DB_STAGING_SERVER(),
        wiki_server    => DBDefs::WIKITRANS_SERVER(),
    );
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
        is_slave_db    => &DBDefs::REPLICATION_TYPE == RT_SLAVE,
        staging_server => &DBDefs::DB_STAGING_SERVER,
    };

    # Determine which server version to display. If the DBDefs string is empty
    # attempt to display the current subversion revision
    if (&DBDefs::VERSION)
    {
        $c->stash->{server_details}->{version} = &DBDefs::VERSION;
    }

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

    $c->stash->{wiki_server} = &DBDefs::WIKITRANS_SERVER;
}

sub chrome_frame : Local
{
    my ($self, $c) = @_;
    $c->stash( template => 'main/frame.tt' );
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
