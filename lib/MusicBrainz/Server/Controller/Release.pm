package MusicBrainz::Server::Controller::Release;
use Moose;
use MusicBrainz::Server::Wizard::ReleaseEditor;
use MusicBrainz::Server::Track;
use Encode;
use JSON::Any;
use TryCatch;

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
    $EDIT_RELEASE_CREATE
    $EDIT_RELEASEGROUP_CREATE
    $EDIT_RELEASE_EDIT
    $EDIT_RELEASE_DELETERELEASELABEL
    $EDIT_RELEASE_EDITRELEASELABEL
    $EDIT_TRACK_EDIT
    $EDIT_TRACKLIST_DELETETRACK
    $EDIT_TRACKLIST_ADDTRACK
    $EDIT_TRACKLIST_CREATE
    $EDIT_MEDIUM_CREATE
    $EDIT_MEDIUM_DELETE
    $EDIT_MEDIUM_EDIT
    $EDIT_RELEASE_CHANGE_QUALITY
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

    my @lists;
    my %containment;
    if ($c->user_exists) {
        # Make a list of lists and whether this release is contained in them
        @lists = $c->model('List')->find_all_by_editor($c->user->id);

        foreach my $list (@lists) {
            $containment{$list->id} = 1
                if ($c->model('List')->check_release($list->id, $release->id));
        }
    }

    $c->stash(
        lists       => \@lists,
        containment => \%containment,
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


sub _serialize_artistcredit {
    my $self = shift;
    my $ac = shift;

    my $credits = [];

    for (@{ $ac->names })
    {
        push @$credits, {
            name => $_->name,
            join => $_->join_phrase,
            id => $_->artist_id,
        };
    }

    return {
        preview => $ac->name,
        names => $credits,
    };
}

sub _serialize_track {
    my $self = shift;
    my $track = shift;

    return {
        length => MusicBrainz::Server::Track::FormatTrackLength($track->length),
        title => $track->name,
        id => $track->id,
        artist => $self->_serialize_artistcredit ($track->artist_credit),
    };
}

sub _serialize_tracklists
{
    my ($self, $release) = @_;

    my $tracklists = [];

    if ($release)
    {
        for ($release->all_mediums)
        {
            my $tracklist = $_->tracklist;

            my $tracks = [];
            for my $track (@{ $tracklist->tracks })
            {
                push @$tracks, $self->_serialize_track ($track);
            }

            push @$tracklists, $tracks;
        }
    }

    # It seems JSON libraries encode things to UTF-8, but the json
    # string will be included in a page which will again be encoded
    # to UTF-8.  So this string has to be decoded back to the internal
    # perl unicode :(.  --warp.
    return decode ("UTF-8", JSON::Any->objToJson ($tracklists));
}


sub add : Chained('base') RequireAuth Args(0)
{
    my ($self, $c) = @_;

    my $wizard = MusicBrainz::Server::Wizard::ReleaseEditor->new (c => $c);

    $wizard->process;

    if ($wizard->cancelled)
    {
        # FIXME: detach to artist, label or release group page if started from there.
        $c->detach ();
    }

    if ($wizard->loading || $wizard->submitted || $wizard->current_page eq 'tracklist')
    {
        # FIXME: empty serialized tracklist
        $c->stash( serialized_tracklists => $self->_serialize_tracklists () );
    }

    if ($wizard->submitted)
    {
        # The user is done with the wizard and wants to submit the new data.
        # So let's create some edits :)

        my $data = $wizard->value;

        # FIXME: some of this is duplicated from 'edit', should be refactored.

        my @fields;
        my %args;
        my $editnote;
        my $edit;

        # add release group
        # ----------------------------------------

        unless ($data->{release_group_id})
        {
            @fields = qw( name artist_credit type_id );
            %args = map { $_ => $data->{$_} } grep { defined $data->{$_} } @fields;

            $editnote = $data->{'editnote'};
            $edit = $self->_create_edit($c, $EDIT_RELEASEGROUP_CREATE, $editnote, %args);
        }

        # add release
        # ----------------------------------------

        @fields = qw( name comment packaging_id status_id script_id language_id
                         country_id barcode artist_credit date );
        %args = map { $_ => $data->{$_} } grep { defined $data->{$_} } @fields;

        $args{release_group_id} = $edit ? $edit->entity->id : $data->{release_group_id};

        $edit = $self->_create_edit($c, $EDIT_RELEASE_CREATE, $editnote, %args);

        my $release_id = $edit->entity->id;
        my $gid = $edit->entity->gid;

        # release labels edit
        # ----------------------------------------

        my $max = scalar @{ $data->{'labels'} } - 1;

        for (0..$max)
        {
            my $new_label = $data->{'labels'}->[$_];

            # Add ReleaseLabel
            # FIXME: There doesn't seem to be an add release label edit. --warp.
            warn "FIXME: ADD RELEASE LABEL EDIT";
        }

        # medium / tracklist / track edits
        # ----------------------------------------

        for my $medium (@{ $data->{'mediums'} })
        {
            my @tracks = map {
                {
                    name => $_->{name},
                    length => $_->{length},
                    artist_credit => $_->{artist_credit},
                    position => $_->{position},
                }
            } @{ $medium->{'tracklist'}->{'tracks'} };

            # We have some tracks but no tracklist ID - so create a new tracklist
            my $create_tl = $self->_create_edit(
                $c, $EDIT_TRACKLIST_CREATE, $editnote, tracks => \@tracks);

            my $tracklist_id = $create_tl->tracklist_id;

            my $opts = {
                position => $medium->{'position'},
                tracklist_id => $tracklist_id,
                release_id => $release_id
            };

            $opts->{name} = $medium->{'name'} if $medium->{'name'};
            $opts->{format_id} = $medium->{'format_id'} if $medium->{'format_id'};

            # Add medium
            $self->_create_edit($c, $EDIT_MEDIUM_CREATE, $editnote, %$opts);
        }

        $c->response->redirect($c->uri_for_action('/release/show', [ $gid ]));
        $c->detach;
    }
    elsif ($wizard->loading)
    {
        # There was no existing wizard, provide the wizard with
        # the $release to initialize the forms.

        my $rg_gid = $c->req->query_params->{'release-group'};
        my $label_gid = $c->req->query_params->{'label'};
        my $artist_gid = $c->req->query_params->{'artist'};

        my $release = MusicBrainz::Server::Entity::Release->new;
        $release->add_medium (MusicBrainz::Server::Entity::Medium->new ( position => 1 ));

        if ($rg_gid)
        {
            $c->detach () unless MusicBrainz::Server::Validation::IsGUID($rg_gid);
            my $rg = $c->model('ReleaseGroup')->get_by_gid($rg_gid);
            $c->detach () unless $rg;

            $release->release_group_id ($rg->id);
            $release->release_group ($rg);
            $release->name ($rg->name);

            $c->model('ArtistCredit')->load ($rg);

            $release->artist_credit ($rg->artist_credit);
        }
        elsif ($label_gid)
        {
            # FIXME: label

            $release->artist_credit (MusicBrainz::Server::Entity::ArtistCredit->new);
            $release->artist_credit->add_name (MusicBrainz::Server::Entity::ArtistCreditName->new);
            $release->artist_credit->names->[0]->artist (MusicBrainz::Server::Entity::Artist->new);
        }
        elsif ($artist_gid)
        {
            $c->detach () unless MusicBrainz::Server::Validation::IsGUID($artist_gid);
            my $artist = $c->model('Artist')->get_by_gid($artist_gid);
            $c->detach () unless $artist;

            $release->artist_credit (
                MusicBrainz::Server::Entity::ArtistCredit->from_artist ($artist));
        }
        else
        {
            $release->artist_credit (MusicBrainz::Server::Entity::ArtistCredit->new);
            $release->artist_credit->add_name (MusicBrainz::Server::Entity::ArtistCreditName->new);
            $release->artist_credit->names->[0]->artist (MusicBrainz::Server::Entity::Artist->new);
        }


        $wizard->render ($release);
    }
    else
    {
        # wizard processed correctly, it's not loading, cancelled or submitted.
        # so all data is in the session and the wizard just needs to be rendered.
        $wizard->render;
    }
}

=head2 WRITE METHODS

Edit a release in release editor

=cut

sub edit : Chained('load') RequireAuth Edit
{
    my ($self, $c) = @_;

    my $release;
    my @mediums;
    my @tracklists;
    my @tracks;

    my $wizard = MusicBrainz::Server::Wizard::ReleaseEditor->new (c => $c);

    $wizard->process;

    if ($wizard->cancelled)
    {
        $c->detach ('show');
    }

    if ($wizard->loading || $wizard->submitted || $wizard->current_page eq 'tracklist')
    {
        # if we're on the tracklist page, load the tracklist so that the trackparser
        # can compare the entered tracks against the original to figure out what edits
        # have been made.

        $release = $c->stash->{release};

        $c->model('Medium')->load_for_releases($release);

        @mediums = $release->all_mediums;
        @tracklists = grep { defined } map { $_->tracklist } @mediums;

        $c->model('Track')->load_for_tracklists(@tracklists);

        @tracks = map { $_->all_tracks } @tracklists;

        $c->model('ArtistCredit')->load(@tracks, $release);

        $c->stash( serialized_tracklists => $self->_serialize_tracklists ($release) );
    }


    if ($wizard->loading || $wizard->submitted)
    {
        # we're either just starting the wizard, or submitting it.  In
        # both cases the release we're editting needs to be loaded
        # from the database.
        $c->model('ReleaseLabel')->load($release);
        $c->model('Label')->load(@{ $release->labels });
        $c->model('ReleaseGroup')->load($release);
        $c->model('ReleaseGroupType')->load($release->release_group);

        $c->model('MediumFormat')->load(@mediums);

        $c->stash( medium_formats => [ $c->model('MediumFormat')->get_all ] );
    }

    if ($wizard->submitted)
    {
        # The user is done with the wizard and wants to submit the new data.
        # So let's create some edits :)

        my $data = $wizard->value;

        # release edit
        # ----------------------------------------

        my @fields = qw( name comment packaging_id status_id script_id language_id
                         country_id barcode artist_credit date );
        my %args = map { $_ => $data->{$_} } grep { defined $data->{$_} } @fields;

        $args{'to_edit'} = $release;
        my $editnote = $data->{'editnote'};
        $c->stash->{changes} = 0;

        $self->_create_edit($c, $EDIT_RELEASE_EDIT, $editnote, %args);

        # release labels edit
        # ----------------------------------------

        my $max = scalar @{ $data->{'labels'} } - 1;

        for (0..$max)
        {
            my $new_label = $data->{'labels'}->[$_];
            my $old_label = $release->labels->[$_];

            if ($old_label)
            {
                if ($new_label->{'deleted'})
                {
                    # Delete ReleaseLabel
                    $self->_create_edit($c, $EDIT_RELEASE_DELETERELEASELABEL,
                         $editnote, release_label => $old_label
                    );
                }
                else
                {
                    # Edit ReleaseLabel
                    $self->_create_edit($c, $EDIT_RELEASE_EDITRELEASELABEL, $editnote,
                        release_label => $old_label,
                        label_id => $new_label->{'label_id'},
                        catalog_number => $new_label->{'catalog_number'},
                    );
                }
            }
            else
            {
                # Add ReleaseLabel
                # FIXME: There doesn't seem to be an add release label edit. --warp.
                warn "FIXME: ADD RELEASE LABEL EDIT";
            }
        }

        # medium / tracklist / track edits
        # ----------------------------------------

        for my $medium (@{ $data->{'mediums'} })
        {
            my $tracklist_id = $medium->{'tracklist'}->{'id'};

            for my $track (@{ $medium->{'tracklist'}->{'tracks'} })
            {
                if ($track->{'id'})
                {
                    if ($track->{'deleted'})
                    {
                        # Delete a track
                        $self->_create_edit ($c, $EDIT_TRACKLIST_DELETETRACK, $editnote,
                             track => $c->model('Track')->get_by_id ($track->{'id'}));
                    }
                    else
                    {
                        # Editing an existing track
                        $self->_create_edit($c, $EDIT_TRACK_EDIT, $editnote,
                             position => $track->{'position'},
                             name => $track->{'name'},
                             artist_credit => $track->{'artist_credit'},
                             length => $track->{'length'},
                             to_edit => $c->model('Track')->get_by_id ($track->{'id'}),
                        );
                    }
                }
                elsif ($tracklist_id)
                {
                    # We are creating a new track (and not a new tracklist)
                    $self->_create_edit($c, $EDIT_TRACKLIST_ADDTRACK, $editnote,
                         position => $track->{'position'},
                         name => $track->{'name'},
                         artist_credit => $track->{'artist_credit'},
                         length => $track->{'length'},
                         tracklist_id => $tracklist_id,
                    );
                }
            }


            if (!$tracklist_id && scalar @{ $medium->{'tracklist'}->{'tracks'} })
            {
                my @tracks = map {
                    {
                        name => $_->{name},
                        length => $_->{length},
                        artist_credit => $_->{artist_credit},
                        position => $_->{position},
                    }
                } @{ $medium->{'tracklist'}->{'tracks'} };

                # We have some tracks but no tracklist ID - so create a new tracklist
                my $create_tl = $self->_create_edit($c, $EDIT_TRACKLIST_CREATE,
                    $editnote, tracks => \@tracks);

                $tracklist_id = $create_tl->tracklist_id;
            }

            if ($medium->{'id'})
            {
                if ($medium->{'deleted'})
                {
                    # Delete medium
                    $self->_create_edit($c, $EDIT_MEDIUM_DELETE, $editnote,
                        medium => $c->model('Medium')->get_by_id ($medium->{'id'}));
                }
                else
                {
                    # Edit medium
                    $self->_create_edit($c, $EDIT_MEDIUM_EDIT, $editnote,
                        name => $medium->{'name'},
                        format_id => $medium->{'format_id'},
                        position => $medium->{'position'},
                        to_edit => $c->model('Medium')->get_by_id ($medium->{'id'}));
                }
            }
            else
            {
                my $opts = {
                    position => $medium->{'position'},
                    tracklist_id => $tracklist_id,
                    release_id => $release->id
                };

                $opts->{name} = $medium->{'name'} if $medium->{'name'};
                $opts->{format_id} = $medium->{'format_id'} if $medium->{'format_id'};

                # Add medium
                $self->_create_edit($c, $EDIT_MEDIUM_CREATE, $editnote, %$opts);
            }
        }

        $c->response->redirect($c->uri_for_action('/release/show', [ $release->gid ]));
        $c->detach;
    }
    elsif ($wizard->loading)
    {
        # There was no existing wizard, provide the wizard with
        # the $release to initialize the forms.
        $wizard->render ($release);
    }
    else
    {
        # wizard processed correctly, it's not loading, cancelled or submitted.
        # so all data is in the session and the wizard just needs to be rendered.
        $wizard->render;
    }
}

sub _create_edit {
    my ($self, $c, $type, $editnote, %args) = @_;

    return unless %args;

    my $edit;
    try {
        $edit = $c->model('Edit')->create(
            edit_type => $type,
            editor_id => $c->user->id,
            %args,
       );
    }
    catch (MusicBrainz::Server::Edit::Exceptions::NoChanges $e) {
    }

    return unless defined $edit;

    if (defined $editnote)
    {
        $c->model('EditNote')->add_note($edit->id, {
            text      => $editnote,
            editor_id => $c->user->id,
        });
    }

    $c->stash->{changes} = 1;

    return $edit;
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

sub change_quality : Chained('load') PathPart('change-quality') RequireAuthu
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};
    $self->edit_action(
        $c,
        item => $release,
        form => 'ChangeReleaseQuality',
        type => $EDIT_RELEASE_CHANGE_QUALITY,
        edit_args => { to_edit => $release },
        on_creation => sub {
            my $uri = $c->uri_for_action('/release/show', [ $release->gid ]);
            $c->response->redirect($uri);
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
