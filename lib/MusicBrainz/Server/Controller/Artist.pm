package MusicBrainz::Server::Controller::Artist;

use utf8;

use Moose;
use namespace::autoclean;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'Artist',
    relationships   => {
        cardinal    => ['edit'],
        subset => {
            split => ['artist'],
            show => ['artist', 'url'],
            relationships => [qw( area artist event instrument label place series url )],
        },
        default     => ['url'],
        paged_subset => {
            relationships => [qw( recording release release_group work )],
        },
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
                                          {from => 'other_identities', to => 'other_identities'},
                                          'top_tags']},
                  recordings => {copy_stash => [{from => 'recordings_jsonld', to => 'recordings'}]},
                  relationships => {},
                  aliases => {copy_stash => ['aliases']}}
};
with 'MusicBrainz::Server::Controller::Role::Collection' => {
    entity_type => 'artist'
};

use Data::Page;
use HTTP::Status qw( :constants );
use MusicBrainz::Server::Data::Utils qw(
    boolean_to_json
    is_special_artist
);
use MusicBrainz::Server::Constants qw(
    :direction
    $DARTIST_ID
    $EDITOR_MODBOT
    $EDIT_ARTIST_MERGE
    $EDIT_ARTIST_CREATE
    $EDIT_ARTIST_EDIT
    $EDIT_ARTIST_EDITCREDIT
    $EDIT_RELATIONSHIP_DELETE
    $ARTIST_ARTIST_COLLABORATION
    $ARTIST_RENAME_LINK_TYPE
);
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
use MusicBrainz::Server::Form::Artist;
use MusicBrainz::Server::Form::Confirm;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::FilterUtils qw(
    create_artist_events_form
    create_artist_release_groups_form
    create_artist_releases_form
    create_artist_recordings_form
    create_artist_works_form
);
use Sql;

use List::AllUtils qw( any sort_by uniq );

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
    $c->stash->{component_props}{artistCredits} = to_json_array($artist_credits);
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
    my $has_filter = %filter ? 1 : 0;

    my $has_default = $c->model('ReleaseGroup')->has_by_artist($artist->id, 0);
    my $has_extra = $c->model('ReleaseGroup')->has_by_artist($artist->id, 1);
    my $has_va = $c->model('ReleaseGroup')->has_by_track_artist($artist->id, 0);
    my $has_va_extra = $c->model('ReleaseGroup')->has_by_track_artist($artist->id, 1);

    my $want_va_only = $c->req->query_params->{va};
    my $want_all_statuses = $c->req->query_params->{all};
    my $including_all_statuses;
    my $showing_va_only;

    my $has_release_groups = $has_default || $has_extra || $has_va || $has_va_extra;
    my $force_release_groups = $want_va_only || $want_all_statuses || %filter;

    my $make_attempt = sub {
        my ($all, $va) = @_;
        my $method = $va ? 'find_by_track_artist' : 'find_by_artist';
        return $self->_load_paged($c, sub {
            if (!$all && !$va) {
                return ([], 0) unless $has_default;
            } elsif ($all && !$va) {
                return ([], 0) unless ($has_default || $has_extra);
            } elsif (!$all && $va) {
                return ([], 0) unless $has_va;
            } elsif ($all && $va) {
                return ([], 0) unless ($has_va || $has_va_extra);
            }
            return $c->model('ReleaseGroup')->$method($c->stash->{artist}->id, $all, shift, shift, filter => \%filter);
        });
    };

    if ($has_release_groups || $force_release_groups) {
        # Attempt from official non-va, to all non-va, to official va, to all va;
        # filter out any attempt that contradicts a preference from a query param
        my @attempts = grep {
            ($_->[0] || !$want_all_statuses) &&
            ($_->[1] || !$want_va_only)
        } ([0,0], [1,0], [0,1], [1,1]);

        for my $attempt (@attempts) {
            my $all = $attempt->[0];
            my $va = $attempt->[1];
            $release_groups = $make_attempt->($all, $va);
            $including_all_statuses = $all;
            $showing_va_only = $va;
            # If filtering, only make one attempt
            # otherwise, attempt until we find RGs or exhaust the possibilities
            if (scalar @$release_groups || %filter) {
                last;
            }
        }
    } else {
        # If there is no expressed preference (va, filter) and no RGs, find recordings
        $recordings = $self->_load_paged($c, sub {
            $c->model('Recording')->find_standalone($artist->id, shift, shift);
        });
        $c->model('ArtistCredit')->load(@$recordings);
        $c->model('Recording')->load_meta(@$recordings);
        $c->model('ISRC')->load_for_recordings(@$recordings);
        if ($c->user_exists) {
            $c->model('Recording')->rating->load_user_ratings($c->user->id, @$recordings);
        }
    }

    if ($c->user_exists) {
        $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, @$release_groups);
    }

    $c->model('ReleaseGroup')->load_has_cover_art(@$release_groups);

    $c->model('ArtistCredit')->load(@$release_groups);
    $c->model('ArtistType')->load(map { map { $_->artist } $_->artist_credit->all_names} @$release_groups);
    $c->model('ReleaseGroupType')->load(@$release_groups);
    $c->stash(
        recordings => $recordings,
        recordings_jsonld => {items => $recordings},
        release_groups_jsonld => {items => $release_groups},
    );

    my $coll = $c->get_collator();
    my @identities;
    my $base_name_legal_name_aliases;
    my $legal_name_aliases;
    my ($base_name) = map { $_->target }
                       grep { $_->direction == $DIRECTION_BACKWARD }
                       grep { $_->link->type->gid eq 'dd9886f2-1dfe-4270-97db-283f6839a666' } @{ $artist->relationships };
    if (defined $base_name) {
        $c->model('Relationship')->load_subset(['artist'], $base_name);
        $c->stash( legal_name => $base_name );
        my $aliases = $c->model('Artist')->alias->find_by_entity_id($base_name->id);
        $c->model('Artist')->alias_type->load(@$aliases);
        my @aliases = uniq map { $_->name }
                      sort_by { $coll->getSortKey($_->name) }
                      # An alias equal to the artist name already shown isn't useful
                      grep { ($_->name) ne $base_name->name }
                      # A legal name alias marked ended isn't a current legal name
                      grep { !($_->ended) }
                      grep { ($_->type_name // '') eq 'Legal name' } @$aliases;
        $c->stash( legal_name_artist_aliases => \@aliases );
        $base_name_legal_name_aliases = \@aliases;
        push(@identities, $base_name);
    } else {
        my $aliases = $c->model('Artist')->alias->find_by_entity_id($artist->id);
        $c->model('Artist')->alias_type->load(@$aliases);
        my @aliases = uniq map { $_->name }
                      sort_by { $coll->getSortKey($_->name) }
                      # A legal name alias marked ended isn't a current legal name
                      grep { !($_->ended) }
                      grep { ($_->type_name // '') eq 'Legal name' } @$aliases;
        $c->stash( legal_name_aliases => \@aliases );
        $legal_name_aliases = \@aliases;
    }

    my (@renamed_from, @renamed_into);

    for my $rel (@{ $artist->relationships }) {
        if ($rel->link->type->gid eq $ARTIST_RENAME_LINK_TYPE) {
            if ($rel->direction == $DIRECTION_FORWARD) {
                push @renamed_into, $rel->target;
            } else {
                push @renamed_from, $rel->target;
            }
        }
    }

    if (@renamed_from || @renamed_into) {
        $c->model('Relationship')->load_subset(
            ['artist'],
            @renamed_from, @renamed_into,
        );
    }

    my @other_identities = sort_by { $coll->getSortKey($_->name) }
                           grep { $_->id != $artist->id }
                           uniq
                           map { $_->target }
                           grep { $_->direction == $DIRECTION_FORWARD }
                           grep { $_->link->type->gid eq 'dd9886f2-1dfe-4270-97db-283f6839a666' }
                           @{ ($base_name // $artist)->relationships };
    push(@identities, @other_identities);
    $c->stash(other_identities => \@other_identities,
              identities => \@identities);

    $c->stash(
        current_view => 'Node',
        component_path => 'artist/ArtistIndex',
        component_props => {
            ajaxFilterFormUrl => '' . $c->uri_for_action('/ajax/filter_artist_release_groups_form', { artist_id => $artist->id }),
            artist => $artist->TO_JSON,
            filterForm => to_json_object($c->stash->{filter_form}),
            hasDefault => boolean_to_json($has_default),
            hasExtra => boolean_to_json($has_extra),
            hasFilter => boolean_to_json($has_filter),
            hasVariousArtists => boolean_to_json($has_va),
            hasVariousArtistsExtra => boolean_to_json($has_va_extra),
            includingAllStatuses => boolean_to_json($including_all_statuses),
            baseName => to_json_object($base_name),
            baseNameLegalNameAliases => to_json_array($base_name_legal_name_aliases),
            legalNameAliases => to_json_array($legal_name_aliases),
            numberOfRevisions => $c->stash->{number_of_revisions},
            otherIdentities => to_json_array(\@other_identities),
            pager => serialize_pager($c->stash->{pager}),
            recordings => to_json_array($recordings),
            releaseGroups => to_json_array($release_groups),
            renamedFrom       => to_json_array(\@renamed_from),
            renamedInto       => to_json_array(\@renamed_into),
            showingVariousArtistsOnly => boolean_to_json($showing_va_only),
            wikipediaExtract => to_json_object($c->stash->{wikipedia_extract}),
        },
    );
}

sub relationships : Chained('load') PathPart('relationships') {
    my ($self, $c) = @_;

    my $stash = $c->stash;
    my $pager = defined $stash->{pager}
        ? serialize_pager($stash->{pager})
        : undef;
    $c->stash(
        component_path => 'artist/ArtistRelationships',
        component_props => {
            artist => $stash->{artist}->TO_JSON,
            pagedLinkTypeGroup => to_json_object($stash->{paged_link_type_group}),
            pager => $pager,
        },
        current_view => 'Node',
    );
}

=head2 works

Shows all works of an artist.

=cut

sub works : Chained('load')
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $filter = $self->process_filter($c, sub {
            return create_artist_works_form($c, $artist->id);
        });
    my $has_filter = %$filter ? 1 : 0;

    my $works = $self->_load_paged($c, sub {
        $c->model('Work')->find_by_artist(
            $c->stash->{artist}->id,
            shift,
            shift,
            filter => $filter
        );
    });
    $c->model('Work')->load_related_info(@$works);
    $c->model('Work')->load_meta(@$works);
    $c->model('Work')->rating->load_user_ratings($c->user->id, @$works) if $c->user_exists;

    my %props = (
        ajaxFilterFormUrl => '' . $c->uri_for_action(
                                 '/ajax/filter_artist_works_form',
                                 { artist_id => $artist->id }
                             ),
        artist            => $c->stash->{artist}->TO_JSON,
        filterForm        => to_json_object($c->stash->{filter_form}),
        hasFilter         => boolean_to_json($has_filter),
        pager             => serialize_pager($c->stash->{pager}),
        works             => to_json_array($works),
    );

    $c->stash(
        component_path  => 'artist/ArtistWorks',
        component_props => \%props,
        current_view    => 'Node',
    );
}

=head2 recordings

Shows all recordings of an artist.

=cut

sub recordings : Chained('load')
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $recordings;
    my $standalone_only;
    my $video_only;

    my $has_standalone = $c->model('Recording')->has_standalone($artist->id);
    my $has_video = $c->model('Recording')->has_video($artist->id);

    my %filter = %{ $self->process_filter($c, sub {
        return create_artist_recordings_form($c, $artist->id);
    }) };
    my $has_filter = %filter ? 1 : 0;

    if ($c->req->query_params->{standalone}) {
        $recordings = $self->_load_paged($c, sub {
            return ([], 0) unless $has_standalone;
            return $c->model('Recording')->find_by_artist($artist->id, shift, shift, standalone => 1);
        });
        $standalone_only = 1;
    }
    elsif ($c->req->query_params->{video}) {
        $recordings = $self->_load_paged($c, sub {
            return ([], 0) unless $has_video;
            return $c->model('Recording')->find_by_artist($artist->id, shift, shift, video => 1);
        });
        $video_only = 1;
    }
    else {
        $recordings = $self->_load_paged($c, sub {
            $c->model('Recording')->find_by_artist($artist->id, shift, shift, filter => \%filter);
        });
    }

    $c->model('Recording')->load_meta(@$recordings);

    my $release_group_appearances = $c->model('Recording')->appears_on($recordings, 10, 1);
    if ($c->user_exists) {
        $c->model('Recording')->rating->load_user_ratings($c->user->id, @$recordings);
    }

    $c->model('ISRC')->load_for_recordings(@$recordings);
    $c->model('ArtistCredit')->load(@$recordings);

    $c->stash(
        recordings => $recordings,
        recordings_jsonld => {items => $recordings},
        current_view => 'Node',
        component_path => 'artist/ArtistRecordings',
        component_props => {
            ajaxFilterFormUrl => '' . $c->uri_for_action('/ajax/filter_artist_recordings_form', { artist_id => $artist->id }),
            artist => $artist->TO_JSON,
            filterForm => to_json_object($c->stash->{filter_form}),
            hasFilter => boolean_to_json($has_filter),
            hasStandalone => boolean_to_json($has_standalone),
            hasVideo => boolean_to_json($has_video),
            pager => serialize_pager($c->stash->{pager}),
            recordings => to_json_array($recordings),
            releaseGroupAppearances => $release_group_appearances,
            standaloneOnly => boolean_to_json($standalone_only),
            videoOnly => boolean_to_json($video_only),
        },
    );
}

=head2 events

Shows all events of an artist.

=cut

sub events : Chained('load')
{
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    my $filter = $self->process_filter($c, sub {
        return create_artist_events_form($c, $artist->id);
    });
    my $has_filter = %$filter ? 1 : 0;

    my $events = $self->_load_paged($c, sub {
        $c->model('Event')->find_by_artist(
            $artist->id,
            shift,
            shift,
            filter => $filter,
        );
    });
    $c->model('Event')->load_related_info(@$events);
    $c->model('Event')->load_areas(@$events);
    $c->model('Event')->load_meta(@$events);
    $c->model('Event')->rating->load_user_ratings($c->user->id, @$events) if $c->user_exists;

    my %props = (
        ajaxFilterFormUrl => '' . $c->uri_for_action(
                                 '/ajax/filter_artist_events_form',
                                 { artist_id => $artist->id }
                             ),
        artist       => $artist->TO_JSON,
        events       => to_json_array($events),
        filterForm => to_json_object($c->stash->{filter_form}),
        hasFilter => boolean_to_json($has_filter),
        pager        => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path  => 'artist/ArtistEvents',
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
    my $showing_va_only;

    my %filter = %{ $self->process_filter($c, sub {
        return create_artist_releases_form($c, $artist->id);
    }) };
    my $has_filter = %filter ? 1 : 0;

    my $method = 'find_by_artist';
    my $want_va_only = $c->req->query_params->{va} ? 1 : 0;
    if ($want_va_only) {
        $method = 'find_by_track_artist';
        $showing_va_only = 1;
    }

    $releases = $self->_load_paged($c, sub {
            $c->model('Release')->$method($artist->id, shift, shift, filter => \%filter);
        });

    my $pager = $c->stash->{pager};
    if (!$want_va_only && $pager->total_entries == 0) {
        $releases = $self->_load_paged($c, sub {
                $c->model('Release')->find_by_track_artist($c->stash->{artist}->id, shift, shift, filter => \%filter);
            });
        $want_va_only = 1;
        $showing_va_only = 1;
    }

    $c->model('ArtistCredit')->load(@$releases);
    $c->model('Release')->load_related_info(@$releases);
    $c->model('Release')->load_meta(@$releases);
    $c->stash(
        current_view => 'Node',
        component_path => 'artist/ArtistReleases',
        component_props => {
            ajaxFilterFormUrl => '' . $c->uri_for_action('/ajax/filter_artist_releases_form', { artist_id => $artist->id }),
            artist => $artist->TO_JSON,
            filterForm => to_json_object($c->stash->{filter_form}),
            hasFilter => boolean_to_json($has_filter),
            pager => serialize_pager($pager),
            releases => to_json_array($releases),
            showingVariousArtistsOnly => boolean_to_json($showing_va_only),
            wantVariousArtistsOnly => boolean_to_json($want_va_only),
        },
    );
}

after [qw( show collections details tags ratings aliases subscribers releases recordings works events relationships )] => sub {
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

=head2 merge

Merge 2 artists into a single artist

=cut

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_ARTIST_MERGE,
    merge_form => 'Merge::Artist'
};

before qw( create edit ) => sub {
    my ($self, $c) = @_;
    my %artist_types = map {$_->id => $_} $c->model('ArtistType')->get_all();
    $c->stash->{artist_types} = \%artist_types;
};

sub _merge_load_entities {
    my ($self, $c, @artists) = @_;

    $c->model('ArtistType')->load(@artists);
    $c->model('Gender')->load(@artists);
    $c->model('Area')->load(@artists);
    $c->model('Area')->load_containment(map { $_->{area} } @artists);
};

around _validate_merge => sub {
    my ($orig, $self, $c, $form) = @_;
    return unless $self->$orig($c, $form);
    my $target = $form->field('target')->value;
    my @all = map { $_->value } $form->field('merging')->fields;
    if (any { is_special_artist($_) && $target != $_ } @all) {
        $form->field('target')->add_error(l('You cannot merge a special purpose artist into another artist'));
        return 0;
    }

    if ($target == $DARTIST_ID) {
        $form->field('target')->add_error(l('You cannot merge into Deleted Artist'));
        return 0;
    }

    return 1;
};

around edit => sub {
    my $orig = shift;
    my ($self, $c) = @_;

    my $artist = $c->stash->{artist};
    if ($artist->is_special_purpose) {
        my %props = (
            artist => $artist->TO_JSON,
        );
        $c->stash(
            component_path => 'artist/SpecialPurpose',
            component_props => \%props,
            current_view => 'Node',
        );
        $c->response->status(HTTP_FORBIDDEN);
        $c->detach;
    }
    else {
        $self->$orig($c);
    }
};

sub split : Chained('load') Edit {
    my ($self, $c) = @_;
    my $artist = $c->stash->{artist};
    $self->_stash_collections($c);

    my $can_split = $c->model('Artist')->can_split($artist->id);

    if (!$can_split) {
        my %props = (
            artist => $artist->TO_JSON,
        );
        $c->stash(
            component_path => 'artist/CannotSplit',
            component_props => \%props,
            current_view => 'Node',
        );
        $c->detach;
    }

    my $is_empty = $c->model('Artist')->is_empty($artist->id);

    if ($is_empty) {
        my %props = (
            artist => $artist->TO_JSON,
            isEmpty => \1
        );
        $c->stash(
            component_path => 'artist/CannotSplit',
            component_props => \%props,
            current_view => 'Node',
        );
        $c->detach;
    }

    my $ac = $c->model('ArtistCredit')->find_for_artist($artist);

    my @collaborators = map { $_->target } grep {
        $_->link->type->gid eq $ARTIST_ARTIST_COLLABORATION
    } $artist->all_relationships;

    $c->stash(
        in_use => $c->model('ArtistCredit')->in_use($ac),
        collaborators => \@collaborators,
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

    $self->edit_action(
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
        my $has_filter_params = grep { /^filter\./ } keys %{ $c->req->params };
        if ($has_filter_params || ($cookie && defined($cookie->value) && $cookie->value eq '1')) {
            my $filter_form = $create_form->();
            if ($c->form_submitted_and_valid($filter_form)) {
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2013 Jesse Weinstein
Copyright (C) 2014 Ulrich Klauer

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
