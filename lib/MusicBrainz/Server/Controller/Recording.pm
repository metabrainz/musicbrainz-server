package MusicBrainz::Server::Controller::Recording;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Annotation';

__PACKAGE__->config(
    entity_name => 'recording',
    model       => 'Recording',
);

use MusicBrainz::Server::Adapter qw(Google);

=head1 NAME

MusicBrainz::Server::Controller::Recording

=head1 DESCRIPTION

Handles user interaction with C<MusicBrainz::Server::Entity::Recording> entities.

=head1 METHODS

=head2 READ ONLY METHODS

=head2 base

Base action to specify that all actions live in the C<recording>
namespace

=cut

sub base : Chained('/') PathPart('recording') CaptureArgs(0) { }

=head2 relations

Shows all relations to a given recording

=cut

sub relations : Chained('load')
{
    my ($self, $c, $mbid) = @_;
    $c->stash->{relations} = $c->model('Relation')->load_relations($self->entity);
}

=head2 details

Show details of a recording

=cut

sub details : Chained('load')
{
    my ($self, $c) = @_;

    my $recording = $self->entity;
    $c->stash(
        relations    => $c->model('Relation')->load_relations($recording),
        tags         => $c->model('Tag')->top_tags($recording),
        release      => $c->model('Release')->load($recording->release),
        show_ratings => $c->user_exists ? $c->user->preferences->get("show_ratings") : 1,
        puids        => $c->model('PUID')->new_from_recording($recording),
        rating       => $c->model('Rating')->get_rating({
            entity_type => 'recording',
            entity_id   => $recording->id,
            user_id     => $c->user_exists ? $c->user->id : 0,
        }),
        template     => 'recording/details.tt',
    );
}

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $recording = $c->stash->{recording};
    my $tracks = $self->_load_paged($c, sub {
        $c->model('Track')->find_by_recording($recording->id, shift, shift);
    });
    my @releases = map { $_->tracklist->medium->release } @$tracks;
    $c->model('ArtistCredit')->load($recording, @$tracks, @releases);
    $c->model('Country')->load(@releases);
    $c->stash(
        tracks   => $tracks,
        template => 'recording/index.tt',
    );
}

sub tags : Chained('load')
{
    my ($self, $c, $mbid) = @_;
    $c->forward('/tags/entity', [ $self->entity ]);
}

sub google : Chained('load')
{
    my ($self, $c) = @_;
    $c->response->redirect(Google($self->entity->name));
}

=head2 DESTRUCTIVE METHODS

This methods alter data

=head2 edit

Edit recording details (sequence number, recording time and title)

=cut

sub edit : Chained('load') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $recording = $self->entity;

    my $form = $self->form;
    $form->init($recording);

    return unless $self->submit_and_validate($c);

    $form->edit;

    $c->flash->{ok} = "Thank you, your edits have been added to the queue";
    $c->response->redirect($c->entity_url($recording, 'show'));
}

sub remove : Chained('load') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $recording = $self->entity;

    my $form = $self->form;
    $form->init($recording);

    return unless $self->submit_and_validate($c);

    my $release = $c->model('Release')->load($recording->release);

    $form->remove_from_release($release);

    $c->flash->{ok} = "Thanks, your recording edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($release, 'show'));
}

sub change_artist : Chained('load')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');
    $c->forward('/search/filter_artist');

    my $result = $c->stash->{search_result};
    if (defined $result)
    {
        my $recording = $self->entity;
        $c->response->redirect($c->entity_url($recording, 'confirm_change_artist',
					      $result->id));
    }
    else
    {
        $c->stash->{template} = 'recording/change_artist_search.tt';
    }
}

sub confirm_change_artist : Chained('load') Args(1)
    Form('Recording::ChangeArtist')
{
    my ($self, $c, $new_artist_id) = @_;

    $c->forward('/user/login');

    my $recording      = $self->entity;
    my $new_artist = $c->model('Artist')->load($new_artist_id);
    $c->stash->{new_artist} = $new_artist;

    my $form = $self->form;
    $form->init($recording);

    $c->stash->{template} = 'recording/change_artist.tt';

    return unless $self->submit_and_validate($c);

    my $release = $c->model('Release')->load($recording->release);

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
