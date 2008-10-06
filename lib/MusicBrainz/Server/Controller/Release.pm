package MusicBrainz::Server::Controller::Release;

use strict;
use warnings;

use base 'Catalyst::Controller';

use MusicBrainz::Server::Adapter qw(Google);

=head1 NAME

MusicBrainz::Server::Controller::Release - Catalyst Controller for
working with Release entities

=head1 DESCRIPTION

This controller handles user interaction, both read and write, with
L<MusicBrainz::Server::Release> objects. This includes displaying
releases, editing releases and creating new releases.

=head1 METHODS

=head2 release

Chained action to load the release

=cut

sub release : Chained CaptureArgs(1)
{
    my ($self, $c, $mbid) = @_;

    my $release = $c->model('Release')->load($mbid);

    $c->stash->{release}        = $release;
    $c->stash->{release_artist} = $c->model('Artist')->load($release->artist); 
}

=head2 perma

Display permalink information for a release

=cut

sub perma : Chained('release') { }

=head2 details

Display detailed information about a release

=cut

sub details : Chained('release') { }

=head2 google

Redirect to Google and search for this release's name.

=cut

sub google : Chained('release')
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};

    $c->response->redirect(Google($release->name));
}

=head2 tags

Show all of this release's tags

=cut

sub tags : Chained('release')
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};

    $c->stash->{tagcloud} = $c->model('Tag')->generate_tag_cloud($release);
}

=head2 relations

Show all relationships attached to this release

=cut

sub relations : Chained('release')
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};

    $c->stash->{relations}      = $c->model('Relation')->load_relations($release);
}

=head2 show

Display a release to the user.

This loads a release from the database (given a valid MBID or database row
ID) and displays it in full, including a summary of advanced relations,
tags, tracklisting, release events, etc.

=cut

sub show : Chained('release') PathPart('')
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};

    my $show_rels = $c->req->query_params->{rel} || 1;

    $c->stash->{show_artists}       = $c->req->query_params->{artist};
    $c->stash->{show_relationships} = defined $show_rels ? $show_rels : 1;

    $c->stash->{artist}         = $c->model('Artist')->load($release->artist); 
    $c->stash->{relations}      = $c->model('Relation')->load_relations($release);
    $c->stash->{tags}           = $c->model('Tag')->top_tags($release);
    $c->stash->{disc_ids}       = $c->model('CdToc')->load_for_release($release);
    $c->stash->{release_events} = $c->model('Release')->load_events($release);

    # Load the tracks, and relationships for tracks if we need them
    my $releases = $c->model('Track')->load_from_release($release);
    $c->stash->{tracks} = [ map {
        if ($show_rels) { $_->{relations} = $c->model('Relation')->load_relations($_); }

        $_;
    } @$releases ];
}

=head2 WRITE METHODS

=head2 change_quality

Change the data quality of a release

=cut

sub change_quality : Chained('release')
{
    my ($self, $c, $mbid) = @_;

    $c->forward('/user/login');

    my $release = $c->stash->{release};

    my $form = $c->form($release, 'Release::DataQuality');
    $form->context($c);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->update_model;

    $c->flash->{ok} = "Thanks, your release edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($release, 'show'));
}

sub edit_title : Chained('release')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $release = $c->stash->{release};

    my $form = $c->form($release, 'Release::Title');
    $form->context($c);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->update_model;
    
    $c->flash->{ok} = "Thanks, your release edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($release, 'show'));
}

sub move : Chained('release')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');
    $c->forward('/search/filter_artist');
}

sub move_to : Chained('release') Args(1)
{
    my ($self, $c, $new_artist) = @_;

    $c->forward('/user/login');

    my $release = $c->stash->{release};

    my $old_artist = $c->model('Artist')->load($release->artist);
    my $new_artist = $c->model('Artist')->load($new_artist);
    $c->stash->{new_artist} = $new_artist;

    my $form = $c->form($release, 'Release::Move');
    $form->context($c);

    $c->stash->{template} = 'release/confirm_move.tt';

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->move($new_artist);

    $c->response->redirect($c->entity_url($release, 'show'));
}

sub remove : Chained('release')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $release = $c->stash->{release};

    my $form = $c->form($release, 'Release::Remove');
    $form->context($c);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->remove_release;

    $c->response->redirect($c->entity_url($release, 'show'));
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
