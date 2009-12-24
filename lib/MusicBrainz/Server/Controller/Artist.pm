package MusicBrainz::Server::Controller::Artist;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Annotation';
with 'MusicBrainz::Server::Controller::Alias';
with 'MusicBrainz::Server::Controller::RelationshipRole';
with 'MusicBrainz::Server::Controller::RatingRole';
with 'MusicBrainz::Server::Controller::TagRole';
with 'MusicBrainz::Server::Controller::EditListingRole';

__PACKAGE__->config(
    model       => 'Artist',
    entity_name => 'artist',
);

use Data::Page;
use MusicBrainz::Server::Constants qw( $DARTIST_ID $VARTIST_ID $EDIT_ARTIST_MERGE );
use MusicBrainz::Server::Adapter qw(Google);
use ModDefs;
use UserSubscription;

use MusicBrainz::Server::Constants qw( $EDIT_ARTIST_CREATE $EDIT_ARTIST_EDIT $EDIT_ARTIST_DELETE );
use MusicBrainz::Server::Form::Artist;
use MusicBrainz::Server::Form::Confirm;
use Sql;

=head1 NAME

MusicBrainz::Server::Controller::Artist - Catalyst Controller for working
with Artist entities

=head1 DESCRIPTION

The artist controller is used for interacting with
L<MusicBrainz::Server::Artist> entities - both read and write. It provides
views to the artist data itself, and a means to navigate to a release
that is attributed to a certain artist.

=head1 ACTIONS

=head2 READ ONLY PAGES

The follow pages can are all read only.

=head2 base

Base action to specify that all actions live in the C<artist>
namespace

=cut

sub base : Chained('/') PathPart('artist') CaptureArgs(0) { }

=head2 artist

Extends loading by disallowing the access of the special artist
C<DELETED_ARTIST>, and fetching any extra data required in
the artist header.

=cut

after 'load' => sub
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    if ($artist->id == $DARTIST_ID)
    {
        $c->detach('/error_404');
    }

    my $artist_model = $c->model('Artist');
    $artist_model->load_meta($artist);
    if ($c->user_exists) {
        $artist_model->rating->load_user_ratings($c->user->id, $artist);

        $c->stash->{subscribed} = $artist_model->subscription->check_subscription(
            $c->user->id, $artist->id);
    }
    $c->model('ArtistType')->load($artist);
    $c->model('Gender')->load($artist);
    $c->model('Country')->load($artist);
};

=head2 similar

Display artists similar to this artist

=cut

sub similar : Chained('load')
{
    my ($self, $c) = @_;
    my $artist = $self->entity;

    $c->stash->{similar_artists} = $c->model('Artist')->find_similar_artists($artist);
}

=head2 google

Search Google for this artist

=cut

sub google : Chained('load')
{
    my ($self, $c) = @_;
    my $artist = $self->entity;

    $c->response->redirect(Google($artist->name));
}

=head2 relations

Shows all the entities (except track) that this artist is related to.

=cut

sub relations : Chained('load')
{
    my ($self, $c) = @_;
    my $artist = $self->entity;

    $c->stash->{relations} = $c->model('Relation')->load_relations($artist, to_type => [ 'artist', 'url', 'label', 'album' ]);
}

=head2 appearances

Display a list of releases that an artist appears on via advanced
relations.

=cut

sub appearances : Chained('load')
{
    my ($self, $c) = @_;
    my $artist = $self->entity;

    $c->stash->{releases} = $c->model('Release')->find_linked_albums($artist);
}

=head2 perma

Display the perma-link for a given artist.

=cut

# Empty because everything we need is in added to the stash with sub artist.
sub perma : Chained('load') { }

=head2 details

Display detailed information about a specific artist.

=cut

# Empty because everything we need is in added to the stash with sub artist.
sub details : Chained('load') { }

=head2 nats

Show all this artists non-album tracks

=cut

sub nats : Chained('load')
{
    my ($self, $c) = @_;

    $c->stash->{release} = $c->model('Release')->nat_release($self->entity);

    if ($c->stash->{release})
    {
        $c->stash->{release_artist} = $self->entity;
        $c->forward('/release/show');
    }
    else
    {
        $c->stash->{template} = 'artist/no_nats.tt';
    }
}

=head2 show

Shows an artist's main landing page.

This page shows the main releases (by default) of an artist, along with a
summary of advanced relations this artist is involved in. It also shows
folksonomy information (tags).

=cut

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    my $release_groups;
    if ($c->stash->{artist}->id == $VARTIST_ID)
    {
        $c->stash( template => 'artist/browse_various.tt' );
    }
    else
    {
        $release_groups = $self->_load_paged($c, sub {
                $c->model('ReleaseGroup')->find_by_artist($c->stash->{artist}->id, shift, shift);
            });
        if ($c->user_exists) {
            $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, @$release_groups);
        }

        $c->stash( template => 'artist/index.tt' );
    }

    $c->model('ArtistCredit')->load(@$release_groups);
    $c->model('ReleaseGroupType')->load(@$release_groups);
    $c->stash( release_groups => $release_groups );
}

=head2 works

Shows all works of an artist. For various artists, the results would be
browsable (not just paginated)

=cut

sub works : Chained('load')
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $works;

    if ($artist->id == $VARTIST_ID)
    {
        # TBD
    }
    else
    {
        $works = $self->_load_paged($c, sub {
                $c->model('Work')->find_by_artist($artist->id, shift, shift);
            });

        $c->stash( template => 'artist/works.tt' );
    }

    $c->model('ArtistCredit')->load(@$works);
    $c->stash(
        works => $works,
        show_artists => scalar grep {
            $_->artist_credit->name ne $artist->name
        } @$works,
    );
}

=head2 recordings

Shows all recordings of an artist. For various artists, the results would be
browsable (not just paginated)

=cut

sub recordings : Chained('load')
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $recordings;

    if ($artist->id == $VARTIST_ID)
    {
        # TBD
    }
    else
    {
        $recordings = $self->_load_paged($c, sub {
                $c->model('Recording')->find_by_artist($artist->id, shift, shift);
            });

        $c->stash( template => 'artist/recordings.tt' );
    }

    $c->model('ArtistCredit')->load(@$recordings);
    $c->stash(
        recordings => $recordings,
        show_artists => scalar grep {
            $_->artist_credit->name ne $artist->name
        } @$recordings,
    );
}

=head2 releases

Shows all releases of an artist.

=cut

sub releases : Chained('load')
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $releases;

    if ($artist->id == $VARTIST_ID)
    {
        # TBD
    }
    else
    {
        $releases = $self->_load_paged($c, sub {
                $c->model('Release')->find_by_artist($artist->id, shift, shift);
            });

        $c->stash( template => 'artist/releases.tt' );
    }

    $c->model('ArtistCredit')->load(@$releases);
    $c->model('Medium')->load_for_releases(@$releases);
    $c->model('MediumFormat')->load(map { $_->all_mediums } @$releases);
    $c->model('Country')->load(@$releases);
    $c->model('ReleaseLabel')->load(@$releases);
    $c->model('Label')->load(map { $_->all_labels } @$releases);
    $c->stash(
        releases => $releases,
        show_artists => scalar grep {
            $_->artist_credit->name ne $artist->name
        } @$releases,
    );
}

=head2 WRITE METHODS

These methods write to the database (create/update/delete)

=head2 create

When given a GET request this displays a form allowing the user to enter
data, creating a new artist. If a POST request is received, the data
is validated and if validation succeeds, the artist is entered into the
MusicBrainz database.

The heavy work validating the form and entering data into the database
is done via L<MusicBrainz::Server::Form::Artist>

=cut

sub create : Local RequireAuth
{
    my ($self, $c) = @_;

    my $form = $c->form(form => 'Artist');
    if ($c->form_posted && $form->submitted_and_valid($c->req->params))
    {
        my %edit = map { $_ => $form->field($_)->value }
            qw( name sort_name gender_id type_id country_id begin_date end_date comment);

        my $edit = $c->model('Edit')->create(
            edit_type => $EDIT_ARTIST_CREATE,
            editor_id => $c->user->id,
            %edit
        );

        if ($edit->artist)
        {
            $c->response->redirect($c->uri_for_action('/artist/show', [ $edit->artist->gid ]));
            $c->detach;
        }
    }
}

=head2 edit

Allows users to edit the data about this artist.

When viewed with a GET request, the user is displayed a form filled with
the current artist data. When a POST request is received, the data is
validated and if it passed validation is the updated data is entered
into the MusicBrainz database.

=cut

sub edit : Chained('load') RequireAuth
{
    my ($self, $c, $mbid) = @_;

    my $form = $c->form( form => 'Artist', item => $c->stash->{artist});
    if ($c->form_posted && $form->submitted_and_valid($c->req->params))
    {
        my %edit = map { $_ => $form->field($_)->value }
            qw( name sort_name gender_id type_id country_id begin_date end_date comment);

        my $edit = $c->model('Edit')->create(
            edit_type => $EDIT_ARTIST_EDIT,
            editor_id => $c->user->id,
            artist => $c->stash->{artist},
            %edit
        );

        if ($edit->artist)
        {
            $c->response->redirect($c->uri_for_action('/artist/show', [ $edit->artist->gid ]));
            $c->detach;
        }
    }
}

=head2 add_release

Add a new release to this artist.

=cut

sub add_release : Chained('load')
{
    my ($self, $c) = @_;
    $c->forward('/user/login');
    $c->forward('/release_editor/add_release');
}

=head2 merge

Merge 2 artists into a single artist

=cut

sub merge : Chained('load') RequireAuth
{
    my ($self, $c) = @_;
    my $old_artist = $c->stash->{artist};

    my $new_artist;
    unless ($new_artist = $c->model('Artist')->get_by_gid($c->req->query_params->{gid}))
    {
        $c->stash( template => 'artist/merge_search.tt' );
        $new_artist = $c->controller('Search')->filter($c, 'artist', 'Artist', $old_artist->id);
    }

    my $form = $c->form( form => 'Confirm' );
    $c->stash(
        template => 'artist/merge_confirm.tt',
        old_artist => $old_artist,
        new_artist => $new_artist
    );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params))
    {
        my $edit = $c->model('Edit')->create(
            editor_id => $c->user->id,
            edit_type => $EDIT_ARTIST_MERGE,
            old_artist_id => $old_artist->id,
            new_artist_id => $new_artist->id
        );

        $c->response->redirect($c->uri_for_action('/artist/show', [ $new_artist->gid ]));
    }
}

=head2 rating

Rate an artist

=cut

sub rating : Chained('load') Args(2)
{
    my ($self, $c, $entity, $new_vote) = @_;
    #Need more validation here

    $c->forward('/user/login');
    $c->forward('/rating/do_rating', ['artist', $entity, $new_vote] );
    $c->response->redirect($c->entity_url($self->entity, 'show'));
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

sub add_non_album : Chained('load') Form
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $artist = $self->entity;

    my $form = $self->form;
    $form->init($artist);

    return unless $self->submit_and_validate($c);

    $form->add_track;

    $c->flash->{ok} = 'Thanks, your edit has been entered into the moderation queue';

    $c->response->redirect($c->entity_url($artist, 'show'));
}

=head2 change_quality

Change the data quality of this artist

=cut

sub change_quality : Chained('load') Form('DataQuality')
{
    my ($self, $c) = @_;

    $c->forward('/user/login');

    my $artist = $self->entity;

    my $form = $self->form;
    $form->init($artist);

    return unless $self->submit_and_validate($c);

    $form->change_quality($c->model('Artist'));

    $c->flash->{ok} = "Thanks, your artist edit has been entered " .
                      "into the moderation queue";

    $c->response->redirect($c->entity_url($artist, 'show'));
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
