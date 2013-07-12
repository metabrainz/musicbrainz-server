package MusicBrainz::Server::Controller::Recording;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    entity_name => 'recording',
    model       => 'Recording',
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::Relationship';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::EditListing';

use MusicBrainz::Server::Constants qw(
    $EDIT_RECORDING_CREATE
    $EDIT_RECORDING_DELETE
    $EDIT_RECORDING_EDIT
    $EDIT_RECORDING_MERGE
    $EDIT_RECORDING_ADD_ISRCS
    $EDIT_RECORDING_REMOVE_ISRC
    $EDIT_PUID_DELETE
);
use MusicBrainz::Server::ControllerUtils::Release qw( load_release_events );
use MusicBrainz::Server::Entity::Util::Release qw(
    group_by_release_status_nested
);

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use List::AllUtils qw( any );
use MusicBrainz::Server::Entity::Recording;
use MusicBrainz::Server::Translation qw( l );
use Set::Scalar;

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
    $c->model('ISRC')->load_for_recordings($recording);
    $c->model('ArtistCredit')->load($recording);
};

sub _row_id_to_gid
{
    my ($self, $c, $track_id) = @_;
    my $track = $c->model('Track')->get_by_id($track_id) or return;
    $c->model('Recording')->load($track);
    return $track->recording->gid;
}

after 'tags' => sub
{
    my ($self, $c) = @_;
    my $recording = $c->stash->{recording};
};

after 'relationships' => sub {
    my ($self, $c) = @_;

    my $recording = $c->stash->{recording};
    $c->model('Relationship')->load($recording->related_works);
};

=head2 details

Show details of a recording

=cut

after 'details' => sub
{
    my ($self, $c) = @_;
    # XXX Load PUID count?
    my $recording = $c->stash->{recording};
};

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;
    my $recording = $c->stash->{recording};
    my $tracks = $self->_load_paged($c, sub {
        $c->model('Track')->find_by_recording($recording->id, shift, shift);
    });

    my @releases = map { $_->medium->release } @$tracks;
    $c->model('ArtistCredit')->load($recording, @$tracks, @releases);
    load_release_events($c, @releases);
    $c->model('ReleaseLabel')->load(@releases);
    $c->model('Label')->load(map { $_->all_labels } @releases);
    $c->model('ReleaseStatus')->load(@releases);

    $self->relationships($c);
    $c->stash(
        tracks =>
            group_by_release_status_nested(
                sub { shift->medium->release },
                @$tracks),
        template => 'recording/index.tt',
    );
}

sub fingerprints : Chained('load') PathPart('fingerprints')
{
    my ($self, $c) = @_;

    my $recording = $c->stash->{recording};
    my @puids = $c->model('RecordingPUID')->find_by_recording($recording->id);
    $c->stash(
        puids    => \@puids,
        template => 'recording/fingerprints.tt',
    );
}

=head2 DESTRUCTIVE METHODS

This methods alter data

=head2 edit

Edit recording details (sequence number, recording time and title)

=cut

with 'MusicBrainz::Server::Controller::Role::IdentifierSet' => {
    entity_type => 'recording',
    identifier_type => 'isrc',
    add_edit => $EDIT_RECORDING_ADD_ISRCS,
    remove_edit => $EDIT_RECORDING_REMOVE_ISRC,
    include_source => 1
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'Recording',
    edit_type      => $EDIT_RECORDING_EDIT,
    edit_arguments => sub {
        my ($self, $c, $recording) = @_;

        return (
            post_creation => $self->edit_with_identifiers($c, $recording)
        );
    }
};

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_RECORDING_MERGE,
    search_template => 'recording/merge_search.tt',
    confirmation_template => 'recording/merge_confirm.tt'
};

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Recording::Standalone',
    edit_type => $EDIT_RECORDING_CREATE,
    edit_arguments => sub {
        my ($self, $c) = @_;
        my $artist_gid = $c->req->query_params->{artist};
        my %ret;
        if ( my $artist = $c->model('Artist')->get_by_gid($artist_gid) ) {
            my $rg = MusicBrainz::Server::Entity::Recording->new(
                artist_credit => ArtistCredit->from_artist($artist)
            );
            $c->stash( initial_artist => $artist );
            $ret{item} = $rg;
        }
        $ret{post_creation} = $self->create_with_identifiers($c);
        return %ret;
    }
};

before '_merge_confirm' => sub {
    my ($self, $c) = @_;
    if ($c->stash->{to_merge}) {
        my @recordings = @{ $c->stash->{to_merge} };
        $c->model('ISRC')->load_for_recordings(@recordings);

        my @recordings_with_isrcs = grep { $_->all_isrcs > 0 } @recordings;
        if (@recordings_with_isrcs > 1) {
            my ($comparator, @tail) = @recordings_with_isrcs;
            my $get_isrc_set = sub { Set::Scalar->new(map { $_->isrc } shift->all_isrcs) };
            my $expect = $get_isrc_set->($comparator);
            $c->stash(
                isrcs_differ => any { $get_isrc_set->($_) != $expect } @tail
            );
        }
    }
};

around '_merge_search' => sub {
    my $orig = shift;
    my ($self, $c, $query) = @_;

    my $results = $self->$orig($c, $query);
    $c->model('ArtistCredit')->load(map { $_->entity } @$results);
    return $results;
};

sub delete_puid : Chained('load') PathPart('remove-puid') RequireAuth Edit
{
    my ($self, $c) = @_;
    my $puid_str = $c->req->query_params->{puid};
    my $recording = $c->stash->{recording};
    my $puid = $c->model('RecordingPUID')->get_by_recording_puid($recording->id, $puid_str);

    if (!$puid) {
        $c->stash( message => 'Not a valid PUID' );
        $c->detach('/error_500');
    }
    else
    {
        $c->stash( puid => $puid );

        $self->edit_action($c,
            form => 'Confirm',
            type => $EDIT_PUID_DELETE,
            edit_args => {
                puid => $puid,
            },
            on_creation => sub {
                $c->response->redirect(
                    $c->uri_for_action('/recording/fingerprints', [ $recording->gid ]));
            }
        );
    }
}

with 'MusicBrainz::Server::Controller::Role::Delete' => {
    edit_type => $EDIT_RECORDING_DELETE,
};

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
