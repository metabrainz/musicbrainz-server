package MusicBrainz::Server::Controller::Track;

use strict;
use warnings;

use base 'MusicBrainz::Server::Controller';

__PACKAGE__->config(
    entity_name => 'track',
    model       => 'Track',
);

use MusicBrainz::Server::Adapter qw(Google);
use MusicBrainz::Server::Track;

=head1 NAME

MusicBrainz::Server::Controller::Track

=head1 DESCRIPTION

Handles user interaction with C<MusicBrainz::Server::Track> entities.

=head1 METHODS

=head2 READ ONLY METHODS

=head2 base

Base action to specify that all actions live in the C<label>
namespace

=cut

sub base : Chained('/') PathPart('track') CaptureArgs(0) { }

=head2 track

Chained action to load a track and it's artist.

=cut

sub track : Chained('load') PathPart('') CaptureArgs(0)
{
    my ($self, $c, $mbid) = @_;
    $c->stash->{artist} = $c->model('Artist')->load($self->entity->artist->id);
}

=head2 relations

Shows all relations to a given track

=cut

sub relations : Chained('track')
{
    my ($self, $c, $mbid) = @_;
    $c->stash->{relations} = $c->model('Relation')->load_relations($self->entity);
}

=head2 details

Show details of a track

=cut

sub details : Chained('track')
{
    my ($self, $c) = @_;

    my $track = $self->entity;
    $c->stash(
        relations    => $c->model('Relation')->load_relations($track),
        tags         => $c->model('Tag')->top_tags($track),
        release      => $c->model('Release')->load($track->release),
        show_ratings => $c->user_exists ? $c->user->preferences->get("show_ratings") : 1,
        puids        => $c->model('PUID')->new_from_track($track),
        rating       => $c->model('Rating')->get_rating({
            entity_type => 'track',
            entity_id   => $track->id,
            user_id     => $c->user_exists ? $c->user->id : 0,
        }),
        template     => 'track/details.tt',
    );
}

sub show : Chained('track') PathPart('')
{
    my ($self, $c) = @_;
    $c->detach('details');
}

sub tags : Chained('track')
{
    my ($self, $c, $mbid) = @_;
    $c->forward('/tags/entity', [ $self->entity ]);
}

sub google : Chained('track')
{
    my ($self, $c) = @_;
    $c->response->redirect(Google($self->entity->name));
}

=head2 DESTRUCTIVE METHODS

This methods alter data

=head2 edit

Edit track details (sequence number, track time and title)

=cut

sub edit : Chained('track') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $track = $self->entity;

    my $form = $self->form;
    $form->init($track);

    return unless $self->submit_and_validate($c);

    $form->edit;

    $c->flash->{ok} = "Thank you, your edits have been added to the queue";
    $c->response->redirect($c->entity_url($track, 'show'));
}

sub remove : Chained('track') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $track = $self->entity;

    my $form = $self->form;
    $form->init($track);

    return unless $self->submit_and_validate($c);

    my $release = $c->model('Release')->load($track->release);

    $form->remove_from_release($release);

    $c->flash->{ok} = "Thanks, your track edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($release, 'show'));
}

sub change_artist : Chained('track')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');
    $c->forward('/search/filter_artist');

    my $result = $c->stash->{search_result};
    if (defined $result)
    {
        my $track = $self->entity;
        $c->response->redirect($c->entity_url($track, 'confirm_change_artist',
					      $result->id));
    }
    else
    {
        $c->stash->{template} = 'track/change_artist_search.tt';
    }
}

sub confirm_change_artist : Chained('track') Args(1)
    Form('Track::ChangeArtist')
{
    my ($self, $c, $new_artist_id) = @_;

    $c->forward('/user/login');

    my $track      = $self->entity;
    my $new_artist = $c->model('Artist')->load($new_artist_id);
    $c->stash->{new_artist} = $new_artist;

    my $form = $self->form;
    $form->init($track);

    $c->stash->{template} = 'track/change_artist.tt';

    return unless $self->submit_and_validate($c);

    my $release = $c->model('Release')->load($track->release);

    $form->change_artist($new_artist);

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
