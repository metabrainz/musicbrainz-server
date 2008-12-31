package MusicBrainz::Server::Controller::Root;

use strict;
use warnings;

use base 'Catalyst::Controller';

# Import MusicBrainz libraries
use DBDefs;
use MusicBrainz::Server::Adapter qw( EntityUrl );
use MusicBrainz::Server::Cache;
use MusicBrainz::Server::Replication ':replication_type';
use Statistic;

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

    $c->stash->{server_details} = {
        is_slave_db    => &DBDefs::REPLICATION_TYPE == RT_SLAVE,
        staging_server => &DBDefs::DB_STAGING_SERVER,
    };

    # Load the blog for the sidebar
    #
    $c->stash->{blog} = $c->model('Feeds')->get_cached('musicbrainz', 'http://blog.musicbrainz.org/?feed=rss2');

    $c->stash->{template} = 'main/index.tt';
}

=head2 default

Handle any pages not matched by a specific controller path. In our case,
this means serving a 404 error page.

=cut

sub default : Path
{
    my ($self, $c) = @_;

    $c->response->status(404);
    $c->stash->{template} = 'main/404.tt';
}

sub begin : Private
{
    my ($self, $c) = @_;

    # Load current relationship
    my $rel = $c->session->{current_relationship};
    if ($rel)
    {
	$c->stash->{current_relationship} = $c->model($rel->{type})->load($rel->{id});
    }

    # Update volatile user preferences
    if ($c->user_exists)
    {
        if (!defined $c->session->{orig_privs})
        {
            $c->session->{orig_privs} = $c->user->privs;
        }

        if ($c->user->IsAutoEditor($c->session->{orig_privs}) &&
                defined $c->session->{session_privs})
        {
            $c->user->privs($c->session->{session_privs});
        }
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

    # Setup the searchs on the sidebar
    use MusicBrainz::Server::Form::Search::Simple;
    my $simpleSearch = new MusicBrainz::Server::Form::Search::Simple;
    $simpleSearch->field('type')->value($c->session->{last_simple_search} || 'artist');
    $c->stash->{sidebar_search} = $simpleSearch;

    # Voters
    my $voters = MusicBrainz::Server::Cache->get('sidebar-voters');

    if (!$voters)
    {
        $voters = $c->model('Moderation')->top_voters(5);
        MusicBrainz::Server::Cache->set('sidebar-voters', $voters);
    }

    $c->stash->{'top_voters'} = $voters;

    # Sidebar stats
    my $stats = MusicBrainz::Server::Cache->get('sidebar-statistics');

    if (!$stats)
    {
        my $stat  = Statistic->new($c->mb->{DBH});
        $stats = $stat->FetchAllAsHashRef;
        MusicBrainz::Server::Cache->set('sidebar-statistics', $stats);
    }

    $c->stash->{'server_stats'} = {
        artists  => $stats->{'count.artist'},
        releases => $stats->{'count.album'},
        labels   => $stats->{'count.label'},
        tracks   => $stats->{'count.track'},
        links    => $stats->{'count.ar.links'},
        disc_ids => $stats->{'count.discid'},
        puids    => $stats->{'count.puid'},
        edits    => $stats->{'count.moderation'},
        editors  => $stats->{'count.moderator'},
    };

    # For linking to entities
    $c->stash(entity_url => sub { EntityUrl($c, @_); }); 
    $c->stash->{server_details}->{version} = &DBDefs::VERSION;

    # Effectivly a date filter:
    $c->stash->{user_date} = sub {
        return unless ('' ne $_[0]);

        use UserPreference;

        my ($date_time_format, $time_zone);

        if ($c->user_exists)
        {
            my $prefs = $c->model('User')->get_preferences_hash($c->user);
            $prefs->load;

            $date_time_format = $prefs->get('datetimeformat');
            $time_zone        = $prefs->get('timezone');
        }

        MusicBrainz::Server::DateTime::format_datetime( {
            datetimeformat => $date_time_format,
            tz             => $time_zone,
        }, @_);
    };

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

    $c->stash->{date} = \&MusicBrainz::Server::Validation::MakeDisplayDateStr;
    
    $c->stash->{vote} = \&ModDefs::vote_name;

    $c->stash->{release_format} = \&MusicBrainz::Server::ReleaseEvent::release_format_name;
}

=head css

"Static" action which allows us to build a CSS file using templates

=cut

sub css : Path('main.css')
{
    my ($self, $c) = @_;

    $c->response->content_type('text/css');
    $c->stash->{template} = 'css/main.tt';
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
