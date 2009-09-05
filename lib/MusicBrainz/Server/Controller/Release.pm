package MusicBrainz::Server::Controller::Release;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

with 'MusicBrainz::Server::Controller::Annotation';
with 'MusicBrainz::Server::Controller::RelationshipRole';
with 'MusicBrainz::Server::Controller::EditListingRole';

__PACKAGE__->config(
    entity_name => 'release',
    model       => 'Release',
);

use MusicBrainz::Server::Adapter qw(Google);
use MusicBrainz::Server::Controller::TagRole;

use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_EDIT );
use MusicBrainz::Server::Edit::Release::Edit;

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

after 'load' => sub
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};
    $c->model('Release')->load_meta($release);

    # Load release group
    $c->model('ReleaseGroup')->load($release);
    $c->model('ReleaseGroup')->load_meta($release->release_group);
    if ($c->user_exists) {
        $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, $release->release_group);
    }

    # Load release group tags
    my $entity = $c->stash->{$self->{entity_name}};
    my @tags = $c->model('ReleaseGroup')->tags->find_top_tags(
        $release->release_group->id,
        $MusicBrainz::Server::Controller::TagRoleTOP_TAGS_COUNT);
    $c->stash->{top_tags} = \@tags;

    # Check user's collection
    if ($c->user_exists) {
        my $in_collection = 0;
        if ($c->stash->{user_collection}) {
            $in_collection = $c->model('Collection')->check_release(
                $c->stash->{user_collection}, $release->id);
        }
        $c->stash->{in_collection} = $in_collection;
    }

    # We need to load more artist credits in 'show'
    if ($c->action->name ne 'show') {
        $c->model('ArtistCredit')->load($release);
    }
};

=head2 perma

Display permalink information for a release

=cut

sub perma : Chained('load') { }

=head2 details

Display detailed information about a release

=cut

sub details : Chained('load') { }

sub discids : Chained('load')
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};
    $c->model('Medium')->load_for_releases($release);
    my @medium_cdtocs = $c->model('MediumCDTOC')->load_for_mediums($release->all_mediums);
    $c->model('CDTOC')->load(@medium_cdtocs);
    $c->stash( has_cdtocs => scalar(@medium_cdtocs) > 0 );
}

=head2 google

Redirect to Google and search for this release's name.

=cut

sub google : Chained('load')
{
    my ($self, $c) = @_;
    $c->response->redirect(Google($self->entity->name));
}

=head2 tags

Show all of this release's tags

=cut

sub tags : Chained('load')
{
    my ($self, $c) = @_;
    $c->forward('/tags/entity', [ $self->entity ]);
}

=head2 relations

Show all relationships attached to this release

=cut

sub relations : Chained('load')
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

sub show : Chained('load') PathPart('')
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};
    $c->model('ReleaseStatus')->load($release);
    $c->model('ReleasePackaging')->load($release);
    $c->model('Country')->load($release);
    $c->model('Language')->load($release);
    $c->model('Script')->load($release);
    $c->model('ReleaseLabel')->load($release);
    $c->model('Label')->load(@{ $release->labels });
    $c->model('ReleaseGroupType')->load($release->release_group);
    $c->model('Medium')->load_for_releases($release);

    my @mediums = $release->all_mediums;
    $c->model('MediumFormat')->load(@mediums);

    my @tracklists = map { $_->tracklist } @mediums;
    $c->model('Track')->load_for_tracklists(@tracklists);

    my @tracks = map { $_->all_tracks } @tracklists;
    my @recordings = $c->model('Recording')->load(@tracks);
    $c->model('Recording')->load_meta(@recordings);
    if ($c->user_exists) {
        $c->model('Recording')->rating->load_user_ratings($c->user->id, @recordings);
    }
    $c->model('ArtistCredit')->load($release, @tracks);

    $c->stash(
        template     => 'release/index.tt',
        show_artists => $release->has_multiple_artists,
    );
}

=head2 WRITE METHODS

=head2 change_quality

Change the data quality of a release

=cut

sub change_quality : Chained('load') Form('DataQuality')
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

sub edit_title : Chained('load') Form
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

=head2 edit

Edit a release in release editor

=cut

sub edit : Chained('load') RequireAuth
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};
    my $form = $c->form(form => 'Release', item => $release);

    if ($form->submitted_and_valid($c->req->params)) {
        my %args = map { $_ => $form->field($_)->value }
            qw( name comment packaging_id status_id script_id language_id
                country_id barcode artist_credit date );

        my $edit = $c->model('Edit')->create(
            edit_type => $EDIT_RELEASE_EDIT,
            editor_id => $c->user->id,
            release => $release,
            %args
        );

        $c->response->redirect($c->uri_for_action('/release/show', [ $release->gid ]));
        $c->detach;
    }
}

=head2 duplicate

Duplicate a release into the add release editor

=cut

sub duplicate : Chained('load')
{
    my ($self, $c) = @_;
    $c->forward('/user/login');
    $c->forward('_load_related');
    $c->forward('/release_editor/duplicate_release');
}

sub _load_related : Private
{
    my ($self, $c) = @_;
    
    my $release = $self->entity;
    $c->stash->{artist}         = $c->model('Artist')->load($release->artist);
    $c->stash->{tracks}         = $c->model('Track')->load_from_release($release);
    $c->stash->{release_events} = $c->model('Release')->load_events($release, country_id => 1);
}

sub move : Chained('load')
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

sub move_to : Chained('load') Args(1) Form('Release::Move')
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

sub rating : Chained('load') Args(2)
{
    my ($self, $c, $entity, $new_vote) = @_;
    #Need more validation here

    $c->forward('/user/login');
    $c->forward('/rating/do_rating', ['artist', $entity, $new_vote]);
    $c->response->redirect($c->entity_url($self->entity, 'show'));
}

sub remove : Chained('load') Form
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

sub convert_to_single_artist : Chained('load')
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

sub confirm_convert_to_single_artist : Chained('load') Args(1)
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

sub edit_attributes : Chained('load') Form
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
