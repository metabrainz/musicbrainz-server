package MusicBrainz::Server::Controller::Release;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::Relationship';
with 'MusicBrainz::Server::Controller::Role::EditListing';

__PACKAGE__->config(
    entity_name => 'release',
    model       => 'Release',
);

use MusicBrainz::Server::Controller::Role::Tag;

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_EDIT
    $EDIT_TRACK_EDIT
    $EDIT_TRACKLIST_DELETETRACK
    $EDIT_TRACKLIST_ADDTRACK
    $EDIT_TRACKLIST_CREATE
    $EDIT_MEDIUM_CREATE
    $EDIT_MEDIUM_DELETE
    $EDIT_MEDIUM_EDIT
);

# A duration lookup has to match within this many milliseconds
use constant DURATION_LOOKUP_RANGE => 10000;

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
        $MusicBrainz::Server::Controller::Role::Tag::TOP_TAGS_COUNT);
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

sub discids : Chained('load')
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};
    $c->model('Medium')->load_for_releases($release);
    $c->model('MediumFormat')->load($release->all_mediums);
    my @medium_cdtocs = $c->model('MediumCDTOC')->load_for_mediums($release->all_mediums);
    $c->model('CDTOC')->load(@medium_cdtocs);
    $c->stash( has_cdtocs => scalar(@medium_cdtocs) > 0 );
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

    my @tracklists = grep { defined } map { $_->tracklist } @mediums;
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

=head2 show

Lookup a CD

Given a TOC, carry out a fuzzy TOC lookup and display the matches in a table

=cut

sub medium_sort
{
    ($a->medium->format_id || 99) <=> ($b->medium->format_id || 99)
        or
    ($a->medium->release->release_group->type_id || 99) <=> ($b->medium->release->release_group->type_id || 99)
        or
    ($a->medium->release->status_id || 99) <=> ($b->medium->release->status_id || 99)
        or
    ($a->medium->release->date->year || 9999) <=> ($b->medium->release->date->year || 9999)
        or
    ($a->medium->release->date->month || 12) <=> ($b->medium->release->date->month || 12)
        or
    ($a->medium->release->date->day || 31) <=> ($b->medium->release->date->day || 31)
}

sub lookup : Local
{
    my ($self, $c) = @_;

    my $toc = $c->req->query_params->{toc};
    $c->stash->{toc} = $toc;

    my $results = $c->model('DurationLookup')->lookup($toc, DURATION_LOOKUP_RANGE);
    if (defined $results)
    {
        $c->model('Release')->load(map { $_->medium } @{$results});
        if (scalar(@{$results}) == 1)
        {
             $c->response->redirect($c->uri_for("/release/" . $results->[0]->medium->release->gid));
        }
        else
        {
            $c->model('ReleaseGroup')->load(map { $_->medium->release } @{$results});
            $c->model('ReleaseGroupType')->load(map { $_->medium->release->release_group } @{$results});
            $c->model('ReleaseStatus')->load(map { $_->medium->release } @{$results});
            $c->model('MediumFormat')->load(map { $_->medium } @{$results});
            $c->model('ArtistCredit')->load(map { $_->medium->release } @{$results});
            my @sorted = sort medium_sort @{$results};
            $c->stash->{results} = \@sorted;
        }
    }
    else
    {
        $c->stash->{results} = [];
    }
}

=head2 WRITE METHODS

Edit a release in release editor

=cut

sub edit : Chained('load') RequireAuth Edit
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};
    $c->model('ReleaseLabel')->load($release);
    $c->model('Label')->load(@{ $release->labels });
    $c->model('Medium')->load_for_releases($release);

    my @mediums = $release->all_mediums;
    my @tracklists = grep { defined } map { $_->tracklist } @mediums;

    $c->model('MediumFormat')->load(@mediums);
    $c->model('Track')->load_for_tracklists(@tracklists);

    my @tracks = map { $_->all_tracks } @tracklists;

    $c->model('ArtistCredit')->load(@tracks, $release);

    $c->stash( medium_formats => [ $c->model('MediumFormat')->get_all ] );

    my $form = $c->form(form => 'Release', init_object => $release);
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $release_edit = $self->_create_edit($c, $EDIT_RELEASE_EDIT,
            $form => [qw( name comment packaging_id status_id script_id language_id
                         country_id barcode artist_credit date )],
            to_edit => $release,
        ),

        my %track_id = map { $_->id => $_ } @tracks;
        my %medium_id = map { $_->id => $_ } @mediums;

        for my $medium_field ($form->field('mediums')->fields) {
            # Editing mediums
            # First check if we need to create a new tracklist
            my $tracklist_id = $medium_field->field('tracklist')->field('id')->value;

            # Editing tracks
            for my $track_field ($medium_field->field('tracklist')->field('tracks')->fields) {
                if ($track_field->field('id')->has_value) {
                    my $track = $track_id{ $track_field->field('id')->value };
                    if ($track_field->field('deleted')->value) {
                        $c->model('Edit')->create(
                            editor_id => $c->user->id,
                            edit_type => $EDIT_TRACKLIST_DELETETRACK,
                            track => $track
                        );
                    }
                    else {
                        # Editing an existing track
                        $self->_create_edit($c, $EDIT_TRACK_EDIT,
                            $track_field => [qw( position name artist_credit length )],
                            to_edit => $track,
                        );
                    }
                }
                elsif ($tracklist_id) {
                    # We are creating a new track (and not a new tracklist)
                    $self->_create_edit($c, $EDIT_TRACKLIST_ADDTRACK,
                        $track_field => [qw( position name artist_credit )],
                        tracklist_id => $tracklist_id,
                    );
                }
            }

            my $has_tracks = $medium_field->field('tracklist')->field('tracks')->has_fields;
            if(!$tracklist_id && $has_tracks) {
                # We have some tracks but no tracklist ID - so create a new tracklist
                my @tracks = map { +{
                    name          => $_->field('name')->value,
                    position      => $_->field('position')->value,
                    artist_credit => $_->field('artist_credit')->value,
                } } $medium_field->field('tracklist')->field('tracks')->fields;

                my $create_tl = $c->model('Edit')->create(
                    editor_id => $c->user->id,
                    edit_type => $EDIT_TRACKLIST_CREATE,
                    tracks    => \@tracks,
                );

                $tracklist_id = $create_tl->tracklist_id;
            }

            if($medium_field->field('id')->has_value) {
                my $medium = $medium_id{ $medium_field->field('id')->value };
                # Edit existing medium
                if($medium_field->field('deleted')->value) {
                    $c->model('Edit')->create(
                        editor_id => $c->user->id,
                        edit_type => $EDIT_MEDIUM_DELETE,
                        medium => $medium
                    );
                }
                else {
                    $self->_create_edit(
                        $c, $EDIT_MEDIUM_EDIT,
                        $medium_field => [qw( name format_id position )],
                        to_edit => $medium
                    );
                }
            }
            else {
                # Create a new medium
                $self->_create_edit($c, $EDIT_MEDIUM_CREATE,
                    $medium_field => [qw( name format_id position )],
                    tracklist_id => $tracklist_id,
                    release_id => $release->id
                );
            }
        }

        $c->response->redirect($c->uri_for_action('/release/show', [ $release->gid ]));
        $c->detach;
    }
}

sub _create_edit {
    my ($self, $c, $type, $parent, $fields, %extra) = @_;

    my %args = map { $_ => $parent->field($_)->value }
        grep { $parent->field($_)->has_value }
            @$fields;

    return unless %args;

    $args{$_} = $extra{$_} for keys %extra;

    $c->model('Edit')->create(
        edit_type => $type,
        editor_id => $c->user->id,
        %args,
    );
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
