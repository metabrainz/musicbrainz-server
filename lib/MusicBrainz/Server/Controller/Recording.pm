package MusicBrainz::Server::Controller::Recording;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    entity_name     => 'recording',
    model           => 'Recording',
    relationships   => { all => ['show'], cardinal => ['edit'], default => ['url'] },
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';
with 'MusicBrainz::Server::Controller::Role::JSONLD' => {
    endpoints => {show => {copy_stash => ['top_tags']}, aliases => {copy_stash => ['aliases']}}
};
with 'MusicBrainz::Server::Controller::Role::Collection' => {
    entity_type => 'recording'
};

use MusicBrainz::Server::Constants qw(
    $EDIT_RECORDING_CREATE
    $EDIT_RECORDING_DELETE
    $EDIT_RECORDING_EDIT
    $EDIT_RECORDING_MERGE
    $EDIT_RECORDING_ADD_ISRCS
    $EDIT_RECORDING_REMOVE_ISRC
);
use MusicBrainz::Server::Entity::Util::Release qw(
    group_by_release_status_nested
);

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use List::AllUtils qw( any );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
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
    my $returning_jsonld = $self->should_return_jsonld($c);

    unless ($returning_jsonld) {
        $c->model('Recording')->load_meta($recording);
        $c->model('Recording')->load_first_release_date($recording);

        if ($c->user_exists) {
            $c->model('Recording')->rating->load_user_ratings($c->user->id, $recording);
        }
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

sub show : Chained('load') PathPart('') {
    my ($self, $c) = @_;
    my $recording = $c->stash->{recording};

    $c->model('Relationship')->load($recording->related_works);

    my $tracks = $self->_load_paged($c, sub {
        $c->model('Track')->find_by_recording($recording->id, shift, shift);
    });

    my @releases = map { $_->medium->release } @$tracks;
    $c->model('ArtistCredit')->load($recording, @$tracks, @releases);
    $c->model('Release')->load_release_events(@releases);
    $c->model('ReleaseLabel')->load(@releases);
    $c->model('Label')->load(map { $_->all_labels } @releases);
    $c->model('ReleaseStatus')->load(@releases);
    $c->model('ReleaseGroup')->load(@releases);
    $c->model('ReleaseGroupType')->load(map { $_->release_group }
        @releases);

    my %props = (
        numberOfRevisions => $c->stash->{number_of_revisions},
        pager             => serialize_pager($c->stash->{pager}),
        recording         => $c->stash->{recording},
        tracks            => group_by_release_status_nested(
                                sub { shift->medium->release },
                                @$tracks),
    );
    $c->stash(
        component_path => 'recording/RecordingIndex',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub fingerprints : Chained('load') PathPart('fingerprints') {
    my ($self, $c) = @_;

    $c->stash(
        component_path => 'recording/RecordingFingerprints',
        component_props => { recording => $c->stash->{recording} },
        current_view => 'Node',
    );
}

# Stuff that has the sidebar and needs collection info
after [qw( show collections details tags aliases fingerprints )] => sub {
    my ($self, $c) = @_;
    $self->_stash_collections($c);
};

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

        my (undef, $track_count) = $c->model('Track')->find_by_recording(
            $recording->id, 1, 0
        );

        return (
            post_creation => $self->edit_with_identifiers($c, $recording),
            form_args => {
                used_by_tracks => $track_count > 0
            }
        );
    }
};

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_RECORDING_MERGE,
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
        $ret{form_args} = { used_by_tracks => 0 };
        return %ret;
    },
    dialog_template => 'recording/edit_form.tt',
};

sub _merge_load_entities {
    my ($self, $c, @recordings) = @_;
    $c->model('ArtistCredit')->load(@recordings);
    $c->model('ISRC')->load_for_recordings(@recordings);

    my @recordings_with_isrcs = grep { $_->all_isrcs > 0 } @recordings;
    if (@recordings_with_isrcs > 1) {
        my ($comparator, @tail) = @recordings_with_isrcs;
        my $get_isrc_set = sub { Set::Scalar->new(map { $_->isrc } shift->all_isrcs) };
        my $expect = $get_isrc_set->($comparator);
        $c->stash(
            isrcs_differ => (any { $get_isrc_set->($_) != $expect } @tail),
        );
    }
};

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
