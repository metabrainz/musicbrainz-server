package MusicBrainz::Server::Controller::Artist;

use utf8;

use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'Artist',
    relationships   => {
        all         => ['relationships'],
        cardinal    => ['edit'],
        subset      => { split => ['artist'], show => ['artist', 'url'] },
        default     => ['url']
    },
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::IPI';
with 'MusicBrainz::Server::Controller::Role::ISNI';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::Subscribe';
with 'MusicBrainz::Server::Controller::Role::Cleanup';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';
with 'MusicBrainz::Server::Controller::Role::CommonsImage';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';
with 'MusicBrainz::Server::Controller::Role::JSONLD' => {
    endpoints => {show => {copy_stash => [{from => 'release_groups_jsonld', to => 'release_groups'},
                                          {from => 'recordings_jsonld', to => 'recordings'},
                                          {from => 'identities', to => 'identities'},
                                          {from => 'legal_name', to => 'legal_name'},
                                          {from => 'other_identities', to => 'other_identities'}]},
                  recordings => {copy_stash => [{from => 'recordings_jsonld', to => 'recordings'}]},
                  relationships => {},
                  aliases => {copy_stash => ['aliases']}}
};
with 'MusicBrainz::Server::Controller::Role::Collection' => {
    entity_type => 'artist'
};

use Data::Page;
use HTTP::Status qw( :constants );
use MusicBrainz::Server::Data::Utils qw( is_special_artist );
use MusicBrainz::Server::Constants qw(
    $DARTIST_ID
    $EDITOR_MODBOT
    $EDIT_ARTIST_MERGE
    $EDIT_ARTIST_CREATE
    $EDIT_ARTIST_EDIT
    $EDIT_ARTIST_DELETE
    $EDIT_ARTIST_EDITCREDIT
    $EDIT_RELATIONSHIP_DELETE
    $ARTIST_ARTIST_COLLABORATION
);
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Form::Artist;
use MusicBrainz::Server::Form::Confirm;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::FilterUtils qw(
    create_artist_release_groups_form
    create_artist_releases_form
    create_artist_recordings_form
);
use Sql;

use List::AllUtils qw( any uniq );
use List::UtilsBy qw( sort_by );

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
    my $returning_jsonld = $self->should_return_jsonld($c);

    if ($artist->id == $DARTIST_ID) {
        $c->detach('/error_404');
    }

    my $artist_model = $c->model('Artist');

    unless ($returning_jsonld) {
        $artist_model->load_meta($artist);

        if ($c->user_exists) {
            $artist_model->rating->load_user_ratings($c->user->id, $artist);

            $c->stash->{subscribed} = $artist_model->subscription->check_subscription(
                $c->user->id,
                $artist->id,
            );
        }

        $c->stash(
            watching_artist => $c->user_exists && $c->model('WatchArtist')->is_watching(
                editor_id => $c->user->id,
                artist_id => $artist->id,
            )
        );
    }

    $c->model('ArtistType')->load($artist, map { $_->target } @{ $artist->relationships_by_type('artist') });
    $c->model('Gender')->load($artist);
    $c->model('Area')->load($artist);
    $c->model('Area')->load_containment($artist->area, $artist->begin_area, $artist->end_area);
};

after 'aliases' => sub
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $artist_credits = $c->model('ArtistCredit')->find_by_artist_id($artist->id);
    $c->stash->{component_props}{artistCredits} = [map { $_->TO_JSON } @{$artist_credits}];
};

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
    my $recordings;
    my %filter = %{ $self->process_filter($c, sub {
        return create_artist_release_groups_form($c, $artist->id);
    }) };

    if (%filter) {
        $c->stash( has_filter => 1 );
    }

    my $show_va = $c->req->query_params->{va};
    my $show_all = $c->req->query_params->{all};

    my $make_attempt = sub {
        my ($all, $va) = @_;
        my $method = $va ? 'find_by_track_artist' : 'find_by_artist';
        return $self->_load_paged($c, sub {
            $c->model('ReleaseGroup')->$method($c->stash->{artist}->id, $all, shift, shift, filter => \%filter);
        });
    };

    # Attempt from official non-va, to all non-va, to official va, to all va;
    # filter out any attempt that contradicts a preference from a query param
    my @attempts = grep { ($_->[0] || !$show_all) && ($_->[1] || !$show_va) } ([0,0], [1,0], [0,1], [1,1]);
    for my $attempt (@attempts) {
        my $all = $attempt->[0];
        my $va = $attempt->[1];
        $release_groups = $make_attempt->($all, $va);
        # If filtering, only make one attempt
        # otherwise, attempt until we find RGs or exhaust the possibilities
        if (scalar @$release_groups || %filter) {
            $c->stash(
                including_all => $all,
                including_va => $va
            );
            last;
        }
    }

    # If there is no expressed preference (va, filter) and no RGs, find recordings
    if (!$show_va && !%filter && scalar @$release_groups == 0) {
        $recordings = $self->_load_paged($c, sub {
            $c->model('Recording')->find_standalone($artist->id, shift, shift);
        });
        $c->model('ArtistCredit')->load(@$recordings);
    }

    $c->stash(
        show_va => $show_va,
        show_all => $show_all,
        template => 'artist/index.tt'
    );

    if ($c->user_exists) {
        $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, @$release_groups);
    }

    $c->model('ArtistCredit')->load(@$release_groups);
    $c->model('ArtistType')->load(map { map { $_->artist } $_->artist_credit->all_names} @$release_groups);
    $c->model('ReleaseGroupType')->load(@$release_groups);
    $c->stash(
        recordings => $recordings,
        recordings_jsonld => {items => $recordings},
        release_groups => $release_groups,
        release_groups_jsonld => {items => $release_groups},
        show_artists => scalar grep {
            $_->artist_credit->name ne $artist->name
        } @$release_groups,
    );

    my $coll = $c->get_collator();
    my @identities;
    my ($legal_name) = map { $_->target }
                       grep { $_->direction == $MusicBrainz::Server::Entity::Relationship::DIRECTION_BACKWARD }
                       grep { $_->link->type->gid eq 'dd9886f2-1dfe-4270-97db-283f6839a666' } @{ $artist->relationships };
    if (defined $legal_name) {
        $c->model('Relationship')->load_subset(['artist'], $legal_name);
        $c->stash( legal_name => $legal_name );
        my $aliases = $c->model('Artist')->alias->find_by_entity_id($legal_name->id);
        $c->model('Artist')->alias_type->load(@$aliases);
        my @aliases = map { $_->name }
                      sort_by { $coll->getSortKey($_->name) }
                      uniq
                      # An alias equal to the artist name already shown isn't useful
                      grep { ($_->name) ne $legal_name->name }
                      grep { ($_->type_name // "") eq 'Legal name' } @$aliases;
        $c->stash( legal_name_artist_aliases => \@aliases );
        push(@identities, $legal_name);
    } else {
        my $aliases = $c->model('Artist')->alias->find_by_entity_id($artist->id);
        $c->model('Artist')->alias_type->load(@$aliases);
        my @aliases = map { $_->name }
                      sort_by { $coll->getSortKey($_->name) }
                      uniq
                      grep { ($_->type_name // "") eq 'Legal name' } @$aliases;
        $c->stash( legal_name_aliases => \@aliases );
    }
    $legal_name //= $artist;
    my @other_identities = sort_by { $coll->getSortKey($_->name) }
                           grep { $_->id != $artist->id }
                           uniq
                           map { $_->target }
                           grep { $_->direction == $MusicBrainz::Server::Entity::Relationship::DIRECTION_FORWARD }
                           grep { $_->link->type->gid eq 'dd9886f2-1dfe-4270-97db-283f6839a666' } @{ $legal_name->relationships };
    push(@identities, @other_identities);
    $c->stash(other_identities => \@other_identities,
              identities => \@identities);
}

sub relationships : Chained('load') PathPart('relationships') {}

=head2 works

Shows all works of an artist.

=cut

sub works : Chained('load')
{
    my ($self, $c) = @_;
    my $works = $self->_load_paged($c, sub {
        $c->model('Work')->find_by_artist($c->stash->{artist}->id, shift, shift);
    });
    $c->model('Work')->load_related_info(@$works);
    $c->model('Work')->rating->load_user_ratings($c->user->id, @$works) if $c->user_exists;
    $c->stash( works => $works );
}

=head2 recordings

Shows all recordings of an artist.

=cut

sub recordings : Chained('load')
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $recordings;

    my %filter = %{ $self->process_filter($c, sub {
        return create_artist_recordings_form($c, $artist->id);
    }) };

    if ($c->req->query_params->{standalone}) {
        $recordings = $self->_load_paged($c, sub {
            $c->model('Recording')->find_standalone($artist->id, shift, shift);
        });
        $c->stash( standalone_only => 1 );
    }
    elsif ($c->req->query_params->{video}) {
        $recordings = $self->_load_paged($c, sub {
            $c->model('Recording')->find_video($artist->id, shift, shift);
        });
        $c->stash( video_only => 1 );
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

    $c->model('ISRC')->load_for_recordings(@$recordings);
    $c->model('ArtistCredit')->load(@$recordings);

    $c->stash(
        recordings => $recordings,
        recordings_jsonld => {items => $recordings},
        show_artists => scalar(grep {
            $_->artist_credit->name ne $artist->name
        } @$recordings),
    );
}

=head2 events

Shows all events of an artist.

=cut

sub events : Chained('load')
{
    my ($self, $c) = @_;
    my $events = $self->_load_paged($c, sub {
        $c->model('Event')->find_by_artist($c->stash->{artist}->id, shift, shift);
    });
    $c->model('Event')->load_related_info(@$events);
    $c->model('Event')->load_areas(@$events);
    $c->model('Event')->rating->load_user_ratings($c->user->id, @$events) if $c->user_exists;

    my %props = (
        artist       => $c->stash->{artist},
        events       => $events,
        pager        => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path  => 'artist/ArtistEvents.js',
        component_props => \%props,
        current_view    => 'Node',
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

    $c->model('ArtistCredit')->load(@$releases);
    $c->model('Release')->load_related_info(@$releases);
    $c->stash(
        releases => $releases,
        show_artists => scalar grep {
            $_->artist_credit->name ne $artist->name
        } @$releases,
    );
}

after [qw( show collections details tags aliases releases recordings works events relationships )] => sub {
    my ($self, $c) = @_;
    $self->_stash_collections($c);
};

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
    dialog_template => 'artist/edit_form.tt',
};

=head2 edit

Allows users to edit the data about this artist.

When viewed with a GET request, the user is displayed a form filled with
the current artist data. When a POST request is received, the data is
validated and if it passed validation is the updated data is entered
into the MusicBrainz database.

=cut

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form      => 'ArtistEdit',
    edit_type => $EDIT_ARTIST_EDIT,

    edit_arguments => sub {
        my ($self, $c) = @_;

        my $artist = $c->stash->{artist};
        my $artist_credits = $c->model('ArtistCredit')->find_by_artist_id($artist->id);
        $c->stash( artist_credits => $artist_credits );

        return (
            form_args   => { artist_credits => $artist_credits },
            on_creation => sub {
                my ($edit, $form) = @_;

                my $editid = $edit->id;
                my $artistname = $artist->name;
                my $name = $form->field('name')->value;
                if ($name ne $artist->name) {
                    my %rename = %{ $form->rename_artist_credit_set };
                    for my $old_ac (@$artist_credits) {
                        next unless $rename{$old_ac->id};
                        my $ac = $old_ac->change_artist_name($artist, $name);
                        next if $ac == $old_ac;
                        my $ac_edit = $c->model('Edit')->create(
                            edit_type     => $EDIT_ARTIST_EDITCREDIT,
                            editor        => $c->user,
                            to_edit       => $old_ac,
                            artist_credit => $ac,
                        );
                        $c->model('EditNote')->add_note(
                            $ac_edit->id,
                            {
                                text => "This credit is being changed because the main name for the artist \“$artistname\” is being modified by edit #$editid.",
                                editor_id => $EDITOR_MODBOT
                            }
                        );
                    }
                }
            },
            redirect => sub {
                $c->res->redirect(
                    $c->uri_for_action('/artist/show', [ $artist->gid ]));
            },
        );
    }
};

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
    my ($orig, $self, $c, $form) = @_;
    return unless $self->$orig($c, $form);
    my $target = $form->field('target')->value;
    my @all = map { $_->value } $form->field('merging')->fields;
    if (grep { is_special_artist($_) && $target != $_ } @all) {
        $form->field('target')->add_error(l('You cannot merge a special purpose artist into another artist'));
        return 0;
    }

    if (any { $_ == $DARTIST_ID } @all) {
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

around $_ => sub {
    my $orig = shift;
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    if ($artist->is_special_purpose) {
        my %props = (
            artist => $artist,
        );
        $c->stash(
            component_path => 'artist/SpecialPurpose.js',
            component_props => \%props,
            current_view => 'Node',
        );
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

    if (!can_split($artist)) {
        my %props = (
            artist => $artist,
        );
        $c->stash(
            component_path => 'artist/CannotSplit.js',
            component_props => \%props,
            current_view => 'Node',
        );
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
                    $_->link->type->gid eq $ARTIST_ARTIST_COLLABORATION &&
                    exists $artists{$_->entity0_id} &&
                    $_->entity1_id == $artist->id
                } $artist->all_relationships
            ) {
                my $rem = $c->model('Edit')->create(
                    edit_type    => $EDIT_RELATIONSHIP_DELETE,
                    editor       => $c->user,
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
        $_->link->type->gid ne $ARTIST_ARTIST_COLLABORATION
    } $artist->all_relationships) == 0;
}

sub credit : Chained('load') PathPart('credit') CaptureArgs(1) {
    my ($self, $c, $ac_id) = @_;
    my $ac = $c->model('ArtistCredit')->get_by_id($ac_id)
        or $c->detach('/error_404');
    $c->stash( ac => $ac );
}

sub edit_credit : Chained('credit') PathPart('edit') Edit {
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
