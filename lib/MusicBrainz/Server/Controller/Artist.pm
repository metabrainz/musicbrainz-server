package MusicBrainz::Server::Controller::Artist;

use strict;
use warnings;

use base 'Catalyst::Controller';

use MusicBrainz::Server::Adapter qw(Google);
use ModDefs;

=head1 NAME

MusicBrainz::Server::Controller::Artist - Catalyst Controller for working
with Artist entities

=head1 DESCRIPTION

The artist controller is used for interacting with
L<MusicBrainz::Server::Artist> entities - both read and write. It provides
views to the artist data itself, and a means to navigate to a release
that is attributed to a certain artist.

=head1 METHODS

=head2 READ ONLY PAGES

The follow pages can are all read only.

=head2 artist

Private chained action for loading enough information on the artist header

=cut

sub artist : Chained('/') CaptureArgs(1)
{
    my ($self, $c, $mbid) = @_;

    if (defined $mbid)
    {
        my $artist = $c->model('Artist')->load($mbid);

        if ($artist->id == ModDefs::DARTIST_ID)
        {
            $c->error("You cannot view the special artist 'DELETED ARTIST'");
            $c->detach;
        }

        $c->stash->{artist} = $artist;
    }
    else
    {
        $c->error("No MBID/row ID given.");
        $c->detach;
    }
}

=head2 similar

Display artists similar to this artist

=cut

sub similar : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};

    $c->stash->{similar_artists} = $c->model('Artist')->find_similar_artists($artist);
    $c->stash->{template}        = 'artist/similar.tt';
}

=head2 google

Search Google for this artist

=cut

sub google : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};

    $c->response->redirect(Google($artist->name));
}

=head2 tags

Show all of this artists tags

=cut

sub tags : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};

    $c->stash->{tagcloud} = $c->model('Tag')->generate_tag_cloud($artist);
    $c->stash->{template} = 'artist/tags.tt';
}

=head2 relations

Shows all the entities (except track) that this artist is related to.

=cut

sub relations : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};

    $c->stash->{relations} = $c->model('Relation')->load_relations($artist, to_type => [ 'artist', 'url', 'label', 'album' ]);
    $c->stash->{template}  = 'artist/relations.tt';
}

=head2 appearances

Display a list of releases that an artist appears on via advanced
relations.

=cut

sub appearances : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};

    $c->stash->{releases} = $c->model('Release')->find_linked_albums($artist);
    $c->stash->{template} = 'artist/appearances.tt';
}

=head2 perma

Display the perma-link for a given artist.

=cut

sub perma : Chained('artist')
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'artist/perma.tt';
}

=head2 details

Display detailed information about a specific artist.

=cut

sub details : Chained('artist')
{
    my ($self, $c) = @_;
    $c->stash->{template} = 'artist/details.tt';
}

=head2 aliases

Display all aliases of an artist, along with usage information.

=cut

sub aliases : Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};

    $c->stash->{aliases}  = $c->model('Alias')->load_for_entity($artist);
    $c->stash->{template} = 'artist/aliases.tt';
}

=head2 show

Shows an artist's main landing page.

This page shows the main releases (by default) of an artist, along with a
summary of advanced relations this artist is involved in. It also shows
folksonomy information (tags).

=cut

sub show : PathPart('') Chained('artist')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};

    my $show_all = $c->req->query_params->{show_all} || 0;

    $c->stash->{tags}       = $c->model('Tag')->top_tags($artist);
    $c->stash->{releases}   = $c->model('Release')->load_for_artist($artist, $show_all);
    $c->stash->{relations}  = $c->model('Relation')->load_relations($artist, to_type => [ 'artist', 'url', 'label', 'album' ]);
    $c->stash->{annotation} = $c->model('Annotation')->load_latest_annotation($artist);

    # Decide how to display the data
    $c->stash->{template} = defined $c->request->query_params->{full} ? 
                                'artist/full.tt' :
                                'artist/compact.tt';
}


=head2 WRITE METHODS

These methods write to the database (create/update/delete)

=head2 create

When given a GET request this displays a form allowing the user to enter
data, creating a new artist. If a POST request is received, the data
is validated and if validation succeeds, the artist is entered into the
MusicBrainz database.

The heavy work validating the form and entering data into the database
is done via L<MusicBrainz::Server::Form::Artist;

=cut

sub create : Local
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    use MusicBrainz::Server::Form::Artist;

    my $form = new MusicBrainz::Server::Form::Artist;
    $form->context($c);

    $c->stash->{form} = $form;

    if ($c->form_posted)
    {
        if (my $mods = $form->update_from_form($c->req->params))
        {
            $c->flash->{ok} = "Thanks! The artist has been added to the " .
                              "database, and we have redirected you to " .
                              "their landing page";

            # Make sure that the moderation did go through, and redirect to
            # the new artist
            my $addmod = grep { $_->Type eq ModDefs::MOD_ADD_ARTIST } @$mods;

            $c->detach('/artist/show', $addmod->row_id)
                if $addmod;
        }
    }

    $c->stash->{template} = 'artist/create.tt';
}

=head2 edit

Allows users to edit the data about this artist.

When viewed with a GET request, the user is displayed a form filled with
the current artist data. When a POST request is received, the data is
validated and if it passed validation is the updated data is entered
into the MusicBrainz database.

=cut 

sub edit : Chained('artist')
{
    my ($self, $c, $mbid) = @_;
    
    $c->forward('/user/login');

    my $artist = $c->stash->{artist};

    use MusicBrainz::Server::Form::Artist;

    my $form = new MusicBrainz::Server::Form::Artist($artist->id);
    $form->context($c);

    $c->stash->{form} = $form;

    if ($c->form_posted)
    {
        if ($form->update_from_form($c->req->params))
        {
            $c->flash->{ok} = "Thanks, your artist edit has been entered " .
                              "into the moderation queue";

            $c->detach('/artist/show', $mbid);
        }
    }

    $c->stash->{template} = 'artist/edit.tt';
}

=head2 merge

Merge 2 artists into a single artist

=cut

sub merge : Local
{
    my ($self, $c) = @_;
    die "This is a stub method";
}

=head2 subscribe

Allow a moderator to subscribe to this artist

=cut

sub subscribe : Local
{
    my ($self, $c) = @_;
    die "This is a stub method";
}

=head2 add_release

Add a release to this artist

=cut

sub add_release : Local
{
    my ($self, $c) = @_;
    die "This is a stub method";
}

=head2 import

Import a release from another source (such as FreeDB)

=cut

sub import : Local
{
    my ($self, $c) = @_;
    die "This is a stub method";
}

=head2 add_non_album

Add non-album tracks to this artist (creating the special non-album
release if necessary)

=cut

sub add_non_album : Local
{
    my ($self, $c) = @_;
    die "This is a stub method";
}

=head2 change_quality

Change the data quality of this artist

=cut

sub change_quality : Chained('artist')
{
    my ($self, $c, $mbid) = @_;

    $c->forward('/user/login');

    my $artist = $c->stash->{artist};

    use MusicBrainz::Server::Form::DataQuality;

    my $form = new MusicBrainz::Server::Form::DataQuality($artist->id);
    $form->context($c);

    $c->stash->{form} = $form;

    if ($c->form_posted)
    {
        if ($form->update_from_form($c->req->params))
        {
            $c->flash->{ok} = "Thanks, your artist edit has been entered " .
                              "into the moderation queue";

            $c->detach('/artist/show', $mbid);
        }
    }

    $c->stash->{template} = 'artist/quality.tt';
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
