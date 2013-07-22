package MusicBrainz::Server::Controller::Artist;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'Artist',
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::IPI';
with 'MusicBrainz::Server::Controller::Role::ISNI';
with 'MusicBrainz::Server::Controller::Role::Relationship';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::Subscribe';
with 'MusicBrainz::Server::Controller::Role::Cleanup';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';

use Data::Page;
use HTTP::Status qw( :constants );
use MusicBrainz::Server::Data::Utils qw( is_special_artist );
use MusicBrainz::Server::Constants qw(
    $DARTIST_ID
    $VARTIST_ID
    $EDITOR_MODBOT
    $EDIT_ARTIST_MERGE
    $EDIT_ARTIST_CREATE
    $EDIT_ARTIST_EDIT
    $EDIT_ARTIST_DELETE
    $EDIT_ARTIST_EDITCREDIT
    $EDIT_RELATIONSHIP_DELETE
    $ARTIST_ARTIST_COLLABORATION
);
use MusicBrainz::Server::ControllerUtils::Release qw( load_release_events );
use MusicBrainz::Server::Form::Artist;
use MusicBrainz::Server::Form::Confirm;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::FilterUtils qw(
    create_artist_release_groups_form
    create_artist_releases_form
    create_artist_recordings_form
);
use Sql;

use List::AllUtils qw( any );

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
    $c->model('Area')->load($artist);
    $c->model('Area')->load_codes($artist->area);

    $c->stash(
        watching_artist =>
            $c->user_exists && $c->model('WatchArtist')->is_watching(
                editor_id => $c->user->id, artist_id => $artist->id
            )
    );
};

after 'aliases' => sub
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $artist_credits = $c->model('ArtistCredit')->find_by_artist_id($artist->id);
    $c->stash( artist_credits => $artist_credits );
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

=head2 show

Shows an artist's main landing page.

This page shows the main releases (by default) of an artist, along with a
summary of advanced relations this artist is involved in. It also shows
folksonomy information (tags).

=cut

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $release_groups;
    if ($c->stash->{artist}->id == $VARTIST_ID)
    {
        my $index = $c->req->query_params->{index};
        if ($index) {
            $release_groups = $self->_load_paged($c, sub {
                $c->model('ReleaseGroup')->find_by_name_prefix_va($index, shift,
                                                                  shift);
            });
        }
        $c->stash(
            template => 'artist/browse_various.tt',
            index    => $index,
        );
    }
    else
    {
        my %filter = %{ $self->process_filter($c, sub {
            return create_artist_release_groups_form($c, $artist->id);
        }) };

        my $method = 'find_by_artist';
        my $show_va = $c->req->query_params->{va};
        if ($show_va) {
            $method = 'find_by_track_artist';
        }

        $release_groups = $self->_load_paged($c, sub {
                $c->model('ReleaseGroup')->$method($c->stash->{artist}->id, shift, shift, filter => \%filter);
            });

        my $pager = $c->stash->{pager};
        if (!$show_va && !%filter && $pager->total_entries == 0) {
            $release_groups = $self->_load_paged($c, sub {
                    $c->model('ReleaseGroup')->find_by_track_artist($c->stash->{artist}->id, shift, shift, filter => \%filter);
                });
            $c->stash(
                va_only => 1
            );
        }

        $c->stash(
            show_va => $show_va,
            template => 'artist/index.tt'
        );
    }

    if ($c->user_exists) {
        $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, @$release_groups);
    }

    $c->model('ArtistCredit')->load(@$release_groups);
    $c->model('ReleaseGroupType')->load(@$release_groups);
    $c->stash(
        release_groups => $release_groups,
        show_artists => scalar grep {
            $_->artist_credit->name ne $artist->name
        } @$release_groups,
    );
}

=head2 works

Shows all works of an artist. For various artists, the results would be
browsable (not just paginated)

=cut

sub works : Chained('load')
{
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};
    my $works = $self->_load_paged($c, sub {
        $c->model('Work')->find_by_artist($c->stash->{artist}->id, shift, shift);
    });
    $c->model('Work')->load_writers(@$works);
    $c->model('Work')->load_recording_artists(@$works);
    $c->model('ISWC')->load_for_works(@$works);
    $c->model('WorkType')->load(@$works);
    $c->model('Language')->load(@$works);
    if ($c->user_exists) {
        $c->model('Work')->rating->load_user_ratings($c->user->id, @$works);
    }
    $c->stash( works => $works );
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
        my $index = $c->req->query_params->{index};
        if ($index) {
            $recordings = $self->_load_paged($c, sub {
                $c->model('Recording')->find_by_name_prefix_va($index, shift, shift);
            });
        }
        $c->stash(
            template => 'artist/browse_various_recordings.tt',
            index    => $index,
        );
    }
    else
    {
        my %filter = %{ $self->process_filter($c, sub {
            return create_artist_recordings_form($c, $artist->id);
        }) };

        if ($c->req->query_params->{standalone}) {
            $recordings = $self->_load_paged($c, sub {
                $c->model('Recording')->find_standalone($artist->id, shift, shift);
            });
            $c->stash( standalone_only => 1 );
        }
        else {
            $recordings = $self->_load_paged($c, sub {
                $c->model('Recording')->find_by_artist($artist->id, shift, shift, filter => \%filter);
            });
        }

        $c->model('Recording')->load_meta(@$recordings);

        if ($c->user_exists) {
            $c->model('Recording')->rating->load_user_ratings($c->user->id, @$recordings);
        }

        $c->stash( template => 'artist/recordings.tt' );
    }

    $c->model('ISRC')->load_for_recordings(@$recordings);
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
        my $index = $c->req->query_params->{index};
        if ($index) {
            $releases = $self->_load_paged($c, sub {
                $c->model('Release')->find_by_name_prefix_va($index, shift,
                                                                  shift);
            });
        }
        $c->stash(
            template => 'artist/browse_various_releases.tt',
            index    => $index,
        );
    }
    else
    {
        my %filter = %{ $self->process_filter($c, sub {
            return create_artist_releases_form($c, $artist->id);
        }) };

        my $method = 'find_by_artist';
        my $show_va = $c->req->query_params->{va};
        if ($show_va) {
            $method = 'find_by_track_artist';
            $c->stash( show_va => 1 );
        }

        $releases = $self->_load_paged($c, sub {
                $c->model('Release')->$method($artist->id, shift, shift, filter => \%filter);
            });

        my $pager = $c->stash->{pager};
        if (!$show_va && $pager->total_entries == 0) {
            $releases = $self->_load_paged($c, sub {
                    $c->model('Release')->find_by_track_artist($c->stash->{artist}->id, shift, shift, filter => \%filter);
                });
            $c->stash(
                va_only => 1,
                show_va => 1
            );
        }

        $c->stash( template => 'artist/releases.tt' );
    }

    $c->model('ArtistCredit')->load(@$releases);
    $c->model('Medium')->load_for_releases(@$releases);
    $c->model('MediumFormat')->load(map { $_->all_mediums } @$releases);
    load_release_events($c, @$releases);
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

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Artist',
    edit_type => $EDIT_ARTIST_CREATE,
};

=head2 edit

Allows users to edit the data about this artist.

When viewed with a GET request, the user is displayed a form filled with
the current artist data. When a POST request is received, the data is
validated and if it passed validation is the updated data is entered
into the MusicBrainz database.

=cut

sub edit : Chained('load') RequireAuth Edit {
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};

    my $artist_credits =$c->model('ArtistCredit')->find_by_artist_id($artist->id);
    $c->stash( artist_credits => $artist_credits );

    my @default_artist_credits =
        grep { $_ } map {
            my @found = grep { $_->name eq $artist->name } $_->all_names;
            scalar(@found) ? $_->id : undef;
        } @$artist_credits;

    $self->edit_action(
        $c,
        form        => 'ArtistEdit',
        form_args   => { artist_credits => $artist_credits,
                         default_artist_credits => \@default_artist_credits },
        type        => $EDIT_ARTIST_EDIT,
        item        => $artist,
        edit_args   => { to_edit => $artist },
        on_creation => sub {
            my ($edit, $form) = @_;

            my $editid = $edit->id;
            my $name = $form->field('name')->value;
            if ($name ne $artist->name) {
                my %rename = %{ $form->rename_artist_credit_set };
                for my $old_ac (@$artist_credits) {
                    next unless $rename{$old_ac->id};
                    my $ac = $old_ac->change_artist_name($artist, $name);
                    next if $ac == $old_ac;
                    my $ac_edit = $c->model('Edit')->create(
                        edit_type     => $EDIT_ARTIST_EDITCREDIT,
                        editor_id     => $c->user->id,
                        to_edit       => $old_ac,
                        artist_credit => $ac,
                    );
                    $c->model('EditNote')->add_note(
                        $ac_edit->id,
                        {
                            text => "The artist name has been changed in edit #$editid.",
                            editor_id => $EDITOR_MODBOT
                        }
                    );
                }
            }

            $c->res->redirect(
                $c->uri_for_action('/artist/show', [ $artist->gid ]));
        }
    );
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

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_ARTIST_MERGE,
    merge_form => 'Merge::Artist'
};

around _validate_merge => sub {
    my ($orig, $self, $c, $form, $merger) = @_;
    return unless $self->$orig($c, $form, $merger);
    my $target = $form->field('target')->value;
    if (grep { is_special_artist($_) && $target != $_ } $merger->all_entities) {
        $form->field('target')->add_error(l('You cannot merge a special purpose artist into another artist'));
        return 0;
    }

    if (any { $_ == $DARTIST_ID } $merger->all_entities) {
        $form->field('target')->add_error(l('You cannot merge into Deleted Artist'));
        return 0;
    }

    return 1;
};

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

around $_ => sub {
    my $orig = shift;
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    if ($artist->is_special_purpose) {
        $c->stash( template => 'artist/special_purpose.tt' );
        $c->response->status(HTTP_FORBIDDEN);
        $c->detach;
    }
    else {
        $self->$orig($c);
    }
} for qw( edit );

sub watch : Chained('load') RequireAuth {
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    $c->model('WatchArtist')->watch_artist(
        artist_id => $artist->id,
        editor_id => $c->user->id
    ) if $c->user_exists;

    $c->response->redirect(
        $c->req->referer || $c->uri_for_action('/artist/show', [ $artist->gid ]));
}

sub stop_watching : Chained('load') RequireAuth {
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    $c->model('WatchArtist')->stop_watching_artist(
        artist_ids => [ $artist->id ],
        editor_id => $c->user->id
    ) if $c->user_exists;

    $c->response->redirect(
        $c->req->referer || $c->uri_for_action('/artist/show', [ $artist->gid ]));
}

sub split : Chained('load') Edit {
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};
    $c->model('Relationship')->load($artist);

    if (!can_split($artist)) {
        $c->stash( template => 'artist/cannot_split.tt' );
        $c->detach;
    }

    my $ac = $c->model('ArtistCredit')->find_for_artist($artist);

    $c->stash(
        in_use => $c->model('ArtistCredit')->in_use($ac)
    );

    my $edit = $self->edit_action(
        $c,
        form        => 'EditArtistCredit',
        type        => $EDIT_ARTIST_EDITCREDIT,
        item        => { artist_credit => $ac },
        edit_args   => { to_edit => $ac },
        on_creation => sub {
            my ($edit) = @_;

            my $editid = $edit->id;
            my %artists = map { $_ => 1 } $edit->new_artist_ids;

            # Delete any collaboration relationships that the artist being split
            # was involved in.
            for my $relationship (
                grep {
                    $_->link->type->gid == $ARTIST_ARTIST_COLLABORATION &&
                    exists $artists{$_->entity0_id} &&
                    $_->entity1_id == $artist->id
                } $artist->all_relationships
            ) {
                my $rem = $c->model('Edit')->create(
                    edit_type    => $EDIT_RELATIONSHIP_DELETE,
                    editor_id    => $c->user->id,
                    type0        => 'artist',
                    type1        => 'artist',
                    relationship => $relationship
                );

                $c->model('EditNote')->add_note(
                    $rem->id,
                    {
                        text => "This collaboration has been split in edit #$editid.",
                        editor_id => $c->user->id
                    }
                );
            }

            $c->res->redirect(
                $c->uri_for_action('/artist/show', [ $artist->gid ]))
        }
    );
}

sub can_split {
    my $artist = shift;
    return (grep {
        $_->link->type->gid != $ARTIST_ARTIST_COLLABORATION
    } $artist->all_relationships) == 0;
}

sub credit : Chained('load') PathPart('credit') CaptureArgs(1) {
    my ($self, $c, $ac_id) = @_;
    my $ac = $c->model('ArtistCredit')->get_by_id($ac_id)
        or $c->detach('/error_404');
    $c->stash( ac => $ac );
}

sub edit_credit : Chained('credit') PathPart('edit') RequireAuth Edit {
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};
    my $ac = $c->stash->{ac};

    my $edit = $self->edit_action(
        $c,
        form        => 'EditArtistCredit',
        type        => $EDIT_ARTIST_EDITCREDIT,
        item        => { artist_credit => $ac },
        edit_args   => { to_edit => $ac },
        on_creation => sub {
            $c->res->redirect(
                $c->uri_for_action('/artist/aliases', [ $artist->gid ]));
        }
    );
}

=head2 process_filter

Utility function for dynamically loading the filter form.

=cut

sub process_filter
{
    my ($self, $c, $create_form) = @_;

    my %filter;
    unless (exists $c->req->params->{'filter.cancel'}) {
        my $cookie = $c->req->cookies->{filter};
        my $has_filter_params = grep(/^filter\./, keys %{ $c->req->params });
        if ($has_filter_params || ($cookie && defined($cookie->value) && $cookie->value eq '1')) {
            my $filter_form = $create_form->();
            if ($filter_form->submitted_and_valid($c->req->params)) {
                for my $name ($filter_form->filter_field_names) {
                    my $value = $filter_form->field($name)->value;
                    if ($value) {
                        $filter{$name} = $value;
                    }

                }
                $c->res->cookies->{filter} = { value => '1', path => '/' };
            }
        }
    }
    else {
        $c->res->cookies->{filter} = { value => '', path => '/' };
    }

    return \%filter;
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
