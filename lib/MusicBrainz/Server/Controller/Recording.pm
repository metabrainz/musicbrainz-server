package MusicBrainz::Server::Controller::Recording;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Annotation';
with 'MusicBrainz::Server::Controller::DetailsRole';
with 'MusicBrainz::Server::Controller::RelationshipRole';
with 'MusicBrainz::Server::Controller::RatingRole';
with 'MusicBrainz::Server::Controller::TagRole';
with 'MusicBrainz::Server::Controller::EditListingRole';

__PACKAGE__->config(
    entity_name => 'recording',
    model       => 'Recording',
);

use MusicBrainz::Server::Constants qw( $EDIT_RECORDING_EDIT );

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

after 'load' => sub
{
    my ($self, $c) = @_;

    my $recording = $c->stash->{recording};
    $c->model('Recording')->load_meta($recording);
    if ($c->user_exists) {
        $c->model('Recording')->rating->load_user_ratings($c->user->id, $recording);
    }
    my @isrcs = $c->model('ISRC')->find_by_recording($recording->id);
    $c->stash( isrcs => \@isrcs );
};

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

after 'details' => sub
{
    my ($self, $c) = @_;
    # XXX Load PUID count?
    my $recording = $c->stash->{recording};
    $c->model('ArtistCredit')->load($recording);
};

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
    $c->model('ReleaseLabel')->load(@releases);
    $c->model('Label')->load(map { $_->all_labels } @releases);
    $c->stash(
        tracks   => $tracks,
        template => 'recording/index.tt',
    );
}

sub puids : Chained('load') PathPart('puids')
{
    my ($self, $c) = @_;

    my $recording = $c->stash->{recording};
    my @puids = $c->model('RecordingPUID')->find_by_recording($recording->id);
    $c->model('ArtistCredit')->load($recording);
    $c->stash(
        puids    => \@puids,
        template => 'recording/puids.tt',
    );
}

=head2 DESTRUCTIVE METHODS

This methods alter data

=head2 edit

Edit recording details (sequence number, recording time and title)

=cut

sub edit : Chained('load') RequireAuth
{
    my ($self, $c) = @_;
    
    my $recording = $c->stash->{recording};
    $c->model('ArtistCredit')->load($recording);

    $self->edit_action($c, 
        form => 'Recording',
        item => $recording,
        type => $EDIT_RECORDING_EDIT,
        edit_args => { recording => $recording },
        on_creation => sub {
            $c->response->redirect(
                $c->uri_for_action('/recording/show', [ $recording->gid ]));
        }
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
