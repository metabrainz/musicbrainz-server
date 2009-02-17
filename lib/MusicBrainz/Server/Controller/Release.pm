package MusicBrainz::Server::Controller::Release;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

__PACKAGE__->config(
    entity_name => 'release',
    model       => 'Release',
);

use MusicBrainz::Server::Adapter qw(Google);

=head1 NAME

MusicBrainz::Server::Controller::Release - Catalyst Controller for
working with Release entities

=head1 DESCRIPTION

This controller handles user interaction, both read and write, with
L<MusicBrainz::Server::Release> objects. This includes displaying
releases, editing releases and creating new releases.

=head1 METHODS

=head2 base

Base action to specify that all actions live in the C<label>
namespace

=cut

sub base : Chained('/') PathPart('release') CaptureArgs(0) { }

=head2 release

Chained action to load the release and artist

=cut

sub release : Chained('load') PathPart('') CaptureArgs(0)
{
    my ($self, $c) = @_;
    $c->stash->{release_artist} = $c->model('Artist')->load($self->entity->artist); 
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
    $c->response->redirect(Google($self->entity->name));
}

=head2 tags

Show all of this release's tags

=cut

sub tags : Chained('release')
{
    my ($self, $c) = @_;
    $c->forward('/tags/entity', [ $self->entity ]);
}

=head2 relations

Show all relationships attached to this release

=cut

sub relations : Chained('release')
{
    my ($self, $c) = @_;
    $c->stash->{relations} = $c->model('Relation')->load_relations($self->entity);
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
    my $release = $self->entity || $c->stash->{release};

    my $show_rels  = $c->req->query_params->{rel};
    my $show_discs = $c->req->query_params->{discids};

    $c->stash->{show_artists}       = $c->req->query_params->{artist} || $release->has_multiple_track_artists;
    $c->stash->{show_relationships} = defined $show_rels ? $show_rels : 1;
    $c->stash->{show_discids}       = defined $show_discs ? $show_discs : 1;

    $c->stash->{artist}         = $c->model('Artist')->load($release->artist); 
    $c->stash->{relations}      = $c->model('Relation')->load_relations($release);
    $c->stash->{tags}           = $c->model('Tag')->top_tags($release);
    $c->stash->{disc_ids}       = $c->model('CdToc')->load_for_release($release);
    $c->stash->{release_events} = $c->model('Release')->load_events($release);
    $c->stash->{annotation}     = $c->model('Annotation')->load_latest($release);

    my $id = $c->user_exists ? $c->user->id : 0;
    $c->stash->{show_ratings} = $id ? $c->user->preferences->get("show_ratings") : 1;
    # Load the tracks, and relationships for tracks if we need them
    my $tracks = $c->model('Track')->load_from_release($release);

    if ($c->stash->{show_ratings})
    {
        $c->stash->{release_rating} = $c->model('Rating')->get_rating({
            entity_type => 'release', 
            entity_id   => $release->id, 
            user_id     => $id
        });

        $c->stash->{artist_rating} = $c->model('Rating')->get_rating({
            entity_type => 'artist', 
            entity_id   => $c->stash->{artist}->id,
            user_id     => $id
        });

        MusicBrainz::Server::Rating::LoadUserRatingForEntities("track", $tracks, $id);
    }

    $c->stash->{tracks} = [ map {
        if ($show_rels) { $_->{relations} = $c->model('Relation')->load_relations($_); }

        $_;
    } @$tracks ];

    $c->stash->{template} = 'release/nats.tt'
        if ($release->IsNonAlbumTracks);
}

=head2 WRITE METHODS

=head2 change_quality

Change the data quality of a release

=cut

sub change_quality : Chained('release') Form('DataQuality')
{
    my ($self, $c, $mbid) = @_;

    $c->forward('/user/login');

    my $release = $self->entity;

    my $form = $self->form;
    $form->init($release);

    return unless $self->submit_and_validate($c);

    $form->change_quality($c->model('Release'));

    $c->flash->{ok} = "Thanks, your release edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($release, 'show'));
}

sub edit_title : Chained('release') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $release = $self->entity;

    my $form = $self->form;
    $form->init($release);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->edit_title;
    
    $c->flash->{ok} = "Thanks, your release edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($release, 'show'));
}

sub move : Chained('release')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');
    $c->forward('/search/filter_artist');

    my $result = $c->stash->{search_result};
    if (defined $result)
    {
        my $release = $self->entity;
        $c->response->redirect($c->entity_url($release, 'move_to', $result->id));
    }
}

sub move_to : Chained('release') Args(1) Form('Release::Move')
{
    my ($self, $c, $new_artist) = @_;

    $c->forward('/user/login');

    my $release = $self->entity;

    my $old_artist = $c->model('Artist')->load($release->artist);
    $new_artist = $c->model('Artist')->load($new_artist);
    $c->stash->{new_artist} = $new_artist;

    my $form = $self->form;
    $form->init($release);

    $c->stash->{template} = 'release/confirm_move.tt';

    return unless $self->submit_and_validate($c);

    $form->move($old_artist, $new_artist);

    $c->response->redirect($c->entity_url($release, 'show'));
}

=head2 rating

Rate a release

=cut

sub rating : Chained('release') Args(2)
{
    my ($self, $c, $entity, $new_vote) = @_;
    #Need more validation here

    $c->forward('/user/login');
    $c->forward('/rating/do_rating', ['artist', $entity, $new_vote]);
    $c->response->redirect($c->entity_url($self->entity, 'show'));
}

sub remove : Chained('release') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $release = $self->entity;

    my $form = $self->form;
    $form->init($release);

    return unless $self->submit_and_validate($c);

    $form->remove;

    $c->response->redirect($c->entity_url($release, 'show'));
}

sub convert_to_single_artist : Chained('release')
{
    my ($self, $c) = @_;

    $c->stash->{template} = 'release/convert_to_single_search.tt';

    $c->forward('/user/login');
    $c->forward('/search/filter_artist');

    my $result = $c->stash->{search_result};
    if (defined $result)
    {
        my $release = $self->entity;
        $c->response->redirect($c->entity_url($release,
					      'confirm_convert_to_single_artist',
					      $result->id));
    }
}

sub confirm_convert_to_single_artist : Chained('release') Args(1)
    Form('Release::ConvertToSingleArtist')
{
    my ($self, $c, $new_artist) = @_;

    $c->forward('/user/login');

    $c->stash->{template} = 'release/convert_to_single_artist.tt';

    my $release    = $self->entity;
    $new_artist = $c->model('Artist')->load($new_artist);
    $c->stash->{new_artist} = $new_artist;

    my $form = $self->form;
    $form->init($release);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->convert($new_artist);

    $c->response->redirect($c->entity_url($release, 'show'));
}

sub edit_attributes : Chained('release') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $release = $self->entity;

    my $form = $self->form;
    $form->init($release);

    return unless $c->form_posted && $form->validate($c->req->params);

    $form->update_model;

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
