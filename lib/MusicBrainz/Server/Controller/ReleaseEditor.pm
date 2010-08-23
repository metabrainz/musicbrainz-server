package MusicBrainz::Server::Controller::ReleaseEditor;
use Moose;
use TryCatch;
use Encode;
use JSON::Any;
use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::Track';
use aliased 'MusicBrainz::Server::Entity::TrackChangesPreview';
use aliased 'MusicBrainz::Server::Entity::SearchResult';
use MusicBrainz::Server::Data::Search;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_CREATE
    $EDIT_RELEASE_EDIT
    $EDIT_RELEASE_DELETERELEASELABEL
    $EDIT_RELEASE_EDITRELEASELABEL
    $EDIT_RELEASEGROUP_CREATE
    $EDIT_TRACK_EDIT
    $EDIT_TRACKLIST_DELETETRACK
    $EDIT_TRACKLIST_ADDTRACK
    $EDIT_TRACKLIST_CREATE
    $EDIT_MEDIUM_CREATE
    $EDIT_MEDIUM_DELETE
    $EDIT_MEDIUM_EDIT
);

has 'c' => (
    is => 'rw',
    isa => 'Object'
);

sub artist_compare
{
    my ($self, $old, $new) = @_;

    my $i = 0;
    for (@{ $old->names })
    {
        return 1 unless $new->names->[$i];
        return 1 if $_->name ne $new->names->[$i]->name ||
            $_->artist_id    != $new->names->[$i]->artist_id;

        if ($_->join_phrase || $new->names->[$i]->join_phrase)
        {
            return 1 if $_->join_phrase ne $new->names->[$i]->join_phrase;
        }

        $i++;
    }

    return 1 if $new->names->[$i];

    return 0;
}

sub search_result
{
    my ($self, $recording) = @_;

    my @extra;

    my ($tracks, $hits) = $self->c->model('Track')->find_by_recording ($recording->id, 10, 0);

    for (@{ $tracks })
    {
        my $release = $_->tracklist->medium->release;
        $release->mediums ([ $_->tracklist->medium ]);
        $release->mediums->[0]->tracklist ($_->tracklist);
        $release->mediums->[0]->tracklist->tracks ([ $_ ]);

        push @extra, $release;
    }

    $self->c->model('ArtistCredit')->load ($recording);

    return SearchResult->new ({ 
        entity => $recording,
        position => 1,
        score => 100,
        extra => \@extra,
    });
}

sub recording_suggestions
{
    my ($self, $changes, @prepend) = @_;

    my $query = MusicBrainz::Server::Data::Search::escape_query ($changes->track->name);
    my $artist = MusicBrainz::Server::Data::Search::escape_query ($changes->track->artist_credit->name);
    my $limit = 10;

    # FIXME: can we include track length too?  Might be useful in some searches... --warp.
    my $response = $self->c->model ('Search')->external_search (
        $self->c, 'recording', "$query artist:\"$artist\"", $limit, 1, 1);

    my @results;
    @results = @{ $response->{results} } if $response->{results};

    $changes->suggestions ([ @prepend, @results ]);
}

sub track_add
{
    my ($self, $newdata) = @_;

    delete $newdata->{id};

    $newdata->{artist_credit} = ArtistCredit->from_array ($newdata->{artist_credit});
    my $new = Track->new($newdata);
    
    my $t = TrackChangesPreview->new (added => 1, track => $new);

    $self->recording_suggestions ($t);

    return $t;
}

sub track_compare
{
    my ($self, $newdata, $old) = @_;

    $newdata->{artist_credit} = ArtistCredit->from_array ($newdata->{artist_credit});

    my $new = Track->new($newdata);
    my $preview = TrackChangesPreview->new (track => $new, old => $old);

    $preview->deleted(1) if $newdata->{deleted};
    $preview->renamed(1) if $old->name ne $new->name;
    $preview->moved(1)   if $old->position ne $new->position;
    $preview->length(1)  if $old->length ne $new->length;
    $preview->artist(1)  if $self->artist_compare ($old->artist_credit, $new->artist_credit);

    my @suggest;
    if ($old->id == $new->id)
    {
        # if this track is already linked to a recording, add that recording as
        # the first suggestion.
        @suggest = ( $self->search_result ($old->recording) );
    }

    if ($preview->renamed)
    {
        # the track was renamed, tying it to the old recording (which probably still
        # has the old track name) may be a mistake.  Search for similar recordings to
        # offer the user a choice.

        $self->recording_suggestions ($preview, @suggest);
    }
    else
    {
        $preview->suggestions (\@suggest);
    }

    return $preview;
}

sub tracklist_compare
{
    my ($self, $new_medium, $old_medium) = @_;

    my @new;
    my @old;

    # first, only check moves/deletes.
    @new = @{ $new_medium->{tracklist}->{tracks} };
    @old = @{ $old_medium->tracklist->tracks } if $old_medium;

    my $maxnew = scalar @new;
    my $maxold = scalar @old;

    my @to_delete;
    for (my $i = $maxold; $i < $maxnew; $i++)
    {
        my $trackpos = $new[$i]->{position} - 1;

        next if ($i == $trackpos);

        if ($new[$trackpos]->{deleted})
        {
            my $recording_backup = $new[$trackpos]->{id}; 
            $new[$trackpos] = $new[$i];
            $new[$trackpos]->{id} = $recording_backup;

            push @to_delete, $i;
        }
    }

    # delete new tracks which replace existing tracks (moves/renames).
    while (@to_delete)
    {
        delete($new[pop @to_delete]);
    }

    my @ret;
    while (@old)
    {
        push @ret, $self->track_compare (shift @new, shift @old);
    }

    # any tracks left over after removing new tracks which replace existing
    # tracks are added tracks.
    while (@new)
    {
        push @ret, $self->track_add (shift @new);
    }
    
    return \@ret;
}

sub release_compare
{
    my ($self, $data, $release) = @_;

    my @old_media;
    my @new_media;

    @old_media = @{ $release->mediums } if $release;
    @new_media = @{ $data->{mediums} };

    if (scalar @old_media > scalar @new_media)
    {
        die ("removing discs is not yet supported.\n");
    }

    my @ret;
    while (@old_media)
    {
        push @ret, $self->tracklist_compare (shift @new_media, shift @old_media);
    }

    while (@new_media)
    {
        push @ret, $self->tracklist_compare (shift @new_media);
    }

    return \@ret;
}

sub _load_tracklist
{
    my ($self, $release) = @_;

    $self->c->model('Medium')->load_for_releases($release);

    my @mediums = $release->all_mediums;
    my @tracklists = grep { defined } map { $_->tracklist } @mediums;

    $self->c->model('Track')->load_for_tracklists(@tracklists);

    my @tracks = map { $_->all_tracks } @tracklists;

    $self->c->model('ArtistCredit')->load(@tracks, $release);
}

# this just loads the remaining bits of a release, not yet loaded by
# 'load' and '_load_tracklist'.
sub _load_release
{
    my ($self, $release) = @_;

    $self->c->model('ReleaseLabel')->load($release);
    $self->c->model('Label')->load(@{ $release->labels });
    $self->c->model('ReleaseGroupType')->load($release->release_group);

    $self->c->model('MediumFormat')->load($release->all_mediums);
}


sub _serialize_artistcredit
{
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

sub _serialize_track
{
    my ($self, $track) = @_;

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

sub _create_edit
{
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

sub _edit_release_labels
{
    my ($self, $c, $editnote, $data, $release) = @_;


    my $max = scalar @{ $data->{'labels'} } - 1;

    for (0..$max)
    {
        my $new_label = $data->{'labels'}->[$_];
        my $old_label = $release->labels->[$_] if $release;

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
}

sub _edit_release_track_edits
{
    my ($self, $c, $editnote, $data, $release) = @_;

    my $medium_idx = 0;
    for my $medium (@{ $data->{'mediums'} })
    {
        my $tracklist_id = $medium->{'tracklist'}->{'id'};

        my $track_idx = 0;
        for my $track (@{ $medium->{'tracklist'}->{'tracks'} })
        {
            my $rec_gid = $data->{'preview_mediums'}->[$medium_idx]->{'associations'}->[$track_idx]->{'gid'};

            my $recording;
            $recording = $c->model ('Recording')->get_by_gid ($rec_gid) if $rec_gid;

            if ($track->{'id'})
            {
                if ($track->{'deleted'})
                {
                    # Delete a track
                    $self->_create_edit (
                        $c, $EDIT_TRACKLIST_DELETETRACK, $editnote,
                        track => $c->model('Track')->get_by_id ($track->{'id'}));
                }
                else
                {
                    # Editing an existing track
                    $self->_create_edit(
                        $c, $EDIT_TRACK_EDIT, $editnote,
                        position => $track->{'position'},
                        name => $track->{'name'},
                        recording_id => $recording->id,
                        artist_credit => $track->{'artist_credit'},
                        length => $track->{'length'},
                        to_edit => $c->model('Track')->get_by_id ($track->{'id'}),
                        );
                }
            }
            elsif ($tracklist_id)
            {
                my %edit = (
                    position => $track->{'position'},
                    name => $track->{'name'},
                    artist_credit => $track->{'artist_credit'},
                    length => $track->{'length'},
                    tracklist_id => $tracklist_id,
                    );

                $edit{recording_id} = $recording->id if $recording;

                # We are creating a new track (and not a new tracklist)
                $self->_create_edit($c, $EDIT_TRACKLIST_ADDTRACK, $editnote, %edit);
            }

            $track_idx++;
        }

        if (!$tracklist_id && scalar @{ $medium->{'tracklist'}->{'tracks'} })
        {
            my @tracks;
            my $track_idx = 0;
            for (@{ $medium->{'tracklist'}->{'tracks'} })
            {
                my $rec_gid = $data->{'preview_mediums'}->[$medium_idx]->{'associations'}->[$track_idx]->{'gid'};

                my $recording;
                $recording = $c->model ('Recording')->get_by_gid ($rec_gid) if $rec_gid;

                my $trk = {
                    name => $_->{name},
                    length => $_->{length},
                    artist_credit => $_->{artist_credit},
                    position => $_->{position},
                };

                $trk->{recording_id} = $recording->id if $recording;

                push @tracks, $trk;

                $track_idx++;
            }

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
                $self->_create_edit(
                    $c, $EDIT_MEDIUM_EDIT, $editnote,
                    name => $medium->{'name'},
                    format_id => $medium->{'format_id'},
                    position => $medium->{'position'},
                    to_edit => $c->model('Medium')->get_by_id ($medium->{'id'})
                );
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

        $medium_idx++;
    }
}

sub release_add
{
    my ($self, $wizard, $release) = @_;

    $wizard->process;

    if ($wizard->cancelled)
    {
        # FIXME: detach to artist, label or release group page if started from there.
        $self->c->detach ();
    }

    if ($wizard->loading || $wizard->submitted || $wizard->current_page eq 'tracklist' ||
        $wizard->current_page eq 'preview')
    {
        $self->c->stash( serialized_tracklists => $self->_serialize_tracklists () );
    }

    if ($wizard->current_page eq 'preview')
    {
        my $changes = $self->release_compare ($wizard->value);

        my $associations = [];
        for my $medium_changes (@$changes)
        {
            my $medium_assoc = [];
            for my $track_changes (@$medium_changes)
            {
                my $rec;

                if (scalar @{ $track_changes->suggestions } == 1 ||
                    $track_changes->renamed)
                {
                    $rec = $track_changes->suggestions->[0]->entity->gid;
                }

                push @$medium_assoc, $rec ? { gid => $rec } : { gid => '' };
            }

            push @$associations, { associations => $medium_assoc };
        }

        $self->c->stash->{changes} = $changes;

        $wizard->load_page('preview', { 'preview_mediums' => $associations });
    }

    if ($wizard->submitted)
    {
        # The user is done with the wizard and wants to submit the new data.
        # So let's create some edits :)

        my $data = $wizard->value;

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
            $edit = $self->_create_edit($EDIT_RELEASEGROUP_CREATE, $editnote, %args);
        }

        # add release
        # ----------------------------------------

        @fields = qw( name comment packaging_id status_id script_id language_id
                         country_id barcode artist_credit date );
        %args = map { $_ => $data->{$_} } grep { defined $data->{$_} } @fields;

        $args{release_group_id} = $edit ? $edit->entity->id : $data->{release_group_id};

        $edit = $self->_create_edit($EDIT_RELEASE_CREATE, $editnote, %args);

        my $release_id = $edit->entity->id;
        my $gid = $edit->entity->gid;

        # release labels edit
        # ----------------------------------------

        $self->_edit_release_labels ($editnote, $data);

        # medium / tracklist / track edits
        # ----------------------------------------

        $self->_edit_release_track_edits ($editnote, $data, $edit->entity);

        $self->c->response->redirect($self->c->uri_for_action('/release/show', [ $gid ]));
        $self->c->detach;
    }
    elsif ($wizard->loading)
    {
        # There was no existing wizard, provide the wizard with
        # the $release to initialize the forms.

        my $rg_gid = $self->c->req->query_params->{'release-group'};
        my $label_gid = $self->c->req->query_params->{'label'};
        my $artist_gid = $self->c->req->query_params->{'artist'};

        my $release = MusicBrainz::Server::Entity::Release->new;
        $release->add_medium (MusicBrainz::Server::Entity::Medium->new ( position => 1 ));

        if ($rg_gid)
        {
            $self->c->detach () unless MusicBrainz::Server::Validation::IsGUID($rg_gid);
            my $rg = $self->c->model('ReleaseGroup')->get_by_gid($rg_gid);
            $self->c->detach () unless $rg;

            $release->release_group_id ($rg->id);
            $release->release_group ($rg);
            $release->name ($rg->name);

            $self->c->model('ArtistCredit')->load ($rg);

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
            $self->c->detach () unless MusicBrainz::Server::Validation::IsGUID($artist_gid);
            my $artist = $self->c->model('Artist')->get_by_gid($artist_gid);
            $self->c->detach () unless $artist;

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

sub release_edit
{
    my ($self, $wizard, $release) = @_;

    $wizard->process;

    if ($wizard->cancelled)
    {
        $self->c->detach ('show');
    }

    if ($wizard->loading || $wizard->submitted ||
        $wizard->current_page eq 'tracklist' || $wizard->current_page eq 'preview')
    {
        # if we're on the tracklist page, load the tracklist so that the trackparser
        # can compare the entered tracks against the original to figure out what edits
        # have been made.

        $self->_load_tracklist ($release);

        $self->c->stash( serialized_tracklists => $self->_serialize_tracklists ($release) );
    }

    if ($wizard->current_page eq 'preview')
    {
        # we're on the changes preview page, load recordings so that the user can
        # confirm track <-> recording associations.
        my @tracks = map { $_->all_tracks } map { $_->tracklist } $release->all_mediums;
        $self->c->model('Recording')->load (@tracks);

        my $changes = $self->release_compare ($wizard->value, $release);

        my $associations = [];
        for my $medium_changes (@$changes)
        {
            my $medium_assoc = [];
            for my $track_changes (@$medium_changes)
            {
                my $rec;

                # If there is only one suggestion, use that as the default.
                # Use the first suggestion (which is the current association) as a
                # default if the track is renamed.
                if (scalar @{ $track_changes->suggestions } == 1 ||
                    $track_changes->renamed)
                {
                    $rec = $track_changes->suggestions->[0]->entity->gid;
                }

                push @$medium_assoc, $rec ? { gid => $rec } : { gid => '' };
            }

            push @$associations, { associations => $medium_assoc };
        }

        $self->c->stash->{changes} = $changes;

        $wizard->load_page('preview', { 'preview_mediums' => $associations });
    }

    if ($wizard->loading || $wizard->submitted)
    {
        # we're either just starting the wizard, or submitting it.  In
        # both cases the release we're editting needs to be loaded
        # from the database.

        $self->_load_release ($release);

        $self->c->stash( medium_formats => [ $self->c->model('MediumFormat')->get_all ] );
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
        $self->c->stash->{changes} = 0;

        $self->_create_edit($self->c, $EDIT_RELEASE_EDIT, $editnote, %args);

        # release labels edit
        # ----------------------------------------

        $self->_edit_release_labels ($self->c, $editnote, $data, $release);

        # medium / tracklist / track edits
        # ----------------------------------------

        $self->_edit_release_track_edits ($self->c, $editnote, $data, $release);

        $self->c->response->redirect($self->c->uri_for_action('/release/show', [ $release->gid ]));
        $self->c->detach;
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


__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
