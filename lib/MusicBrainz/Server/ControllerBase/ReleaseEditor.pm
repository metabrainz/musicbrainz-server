package MusicBrainz::Server::ControllerBase::ReleaseEditor;
use Moose;
use TryCatch;
use Encode;
use JSON::Any;
use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::Track';
use aliased 'MusicBrainz::Server::Entity::TrackChangesPreview';
use aliased 'MusicBrainz::Server::Entity::SearchResult';
use MusicBrainz::Server::Data::Search qw( escape_query );
use MusicBrainz::Server::Wizard;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_ADD_ANNOTATION
    $EDIT_RELEASE_ADDRELEASELABEL
    $EDIT_RELEASE_DELETERELEASELABEL
    $EDIT_RELEASE_EDITRELEASELABEL
    $EDIT_TRACK_EDIT
    $EDIT_TRACKLIST_DELETETRACK
    $EDIT_TRACKLIST_ADDTRACK
    $EDIT_TRACKLIST_CREATE
    $EDIT_MEDIUM_CREATE
    $EDIT_MEDIUM_DELETE
    $EDIT_MEDIUM_EDIT
);

use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );

__PACKAGE__->config(
    namespace => 'release_editor'
);

sub search_result
{
    my ($self, $c, $recording) = @_;

    my @extra;

    my ($tracks, $hits) = $c->model('Track')->find_by_recording ($recording->id, 6, 0);

    $c->model('ReleaseGroup')->load(map { $_->tracklist->medium->release } @{ $tracks });

    my %rgs = map {
        $_->tracklist->medium->release->release_group_id =>
            $_->tracklist->medium->release->release_group
    } @{ $tracks };

    my @rgs = sort { $a->name cmp $b->name } values %rgs;

    $c->model('ArtistCredit')->load ($recording);

    return SearchResult->new ({
        entity => $recording,
        position => 1,
        score => 100,
        extra => \@rgs,
    });
}

sub recording_suggestions
{
    my ($self, $c, $changes, @prepend) = @_;

    my $query = escape_query($changes->track->name);
    my $artist = escape_query($changes->track->artist_credit->name);
    my $limit = 10;

    # FIXME: can we include track length too?  Might be useful in some searches... --warp.
    my $response = $c->model ('Search')->external_search (
        $c, 'recording', "$query artist:\"$artist\"", $limit, 1, 1);

    my @results;
    @results = @{ $response->{results} } if $response->{results};

    $changes->suggestions ([ @prepend, @results ]);
}

sub track_add
{
    my ($self, $c, $suggest_recordings, $newdata) = @_;

    delete $newdata->{id};

    $newdata->{artist_credit} = ArtistCredit->from_array ($newdata->{artist_credit});
    my $new = Track->new($newdata);

    my $t = TrackChangesPreview->new (track => $new);

    $self->recording_suggestions ($c, $t) if $suggest_recordings;

    return $t;
}

sub track_compare
{
    my ($self, $c, $suggest_recordings, $newdata, $old) = @_;

    $newdata->{artist_credit} = ArtistCredit->from_array ($newdata->{artist_credit});

    my $new = Track->new($newdata);
    my $preview = TrackChangesPreview->new (track => $new);

    $preview->deleted(1) if $newdata->{deleted};
    $preview->renamed(1) if $old->name ne $new->name;

    return $preview unless $suggest_recordings;

    my @suggest;
    if ($old->id == $new->id)
    {
        # if this track is already linked to a recording, add that recording as
        # the first suggestion.
        @suggest = ( $self->search_result ($c, $old->recording) );
    }

    if ($preview->renamed)
    {
        # the track was renamed, tying it to the old recording (which probably still
        # has the old track name) may be a mistake.  Search for similar recordings to
        # offer the user a choice.

        $self->recording_suggestions ($c, $preview, @suggest);
    }
    else
    {
        $preview->suggestions (\@suggest);
    }

    return $preview;
}

sub tracklist_compare
{
    my ($self, $c, $suggest_recordings, $new_medium, $old_medium) = @_;

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
        push @ret, $self->track_compare ($c, $suggest_recordings, shift @new, shift @old);
    }

    # any tracks left over after removing new tracks which replace existing
    # tracks are added tracks.
    while (@new)
    {
        push @ret, $self->track_add ($c, $suggest_recordings, shift @new);
    }

    $new_medium->{tracklist}->{changes} = \@ret;
    return $new_medium;
}

sub suggest_recordings
{
    my ($self, $c, $data, $release) = @_;

    return $self->release_compare ($c, $data, $release, 1);
}

sub release_compare
{
    my ($self, $c, $data, $release, $suggest_recordings) = @_;

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
        push @ret, $self->tracklist_compare ($c, $suggest_recordings, shift @new_media, shift @old_media);
    }

    while (@new_media)
    {
        push @ret, $self->tracklist_compare ($c, $suggest_recordings, shift @new_media);
    }

    return \@ret;
}

sub _load_tracklist
{
    my ($self, $c, $release) = @_;

    $c->model('Medium')->load_for_releases($release);

    my @mediums = $release->all_mediums;
    my @tracklists = grep { defined } map { $_->tracklist } @mediums;

    $c->model('Track')->load_for_tracklists(@tracklists);

    my @tracks = map { $_->all_tracks } @tracklists;

    $c->model('ArtistCredit')->load(@tracks, $release);
}

# this just loads the remaining bits of a release, not yet loaded by
# 'load' and '_load_tracklist'.
sub _load_release
{
    my ($self, $c, $release) = @_;

    $c->model('ReleaseLabel')->load($release);
    $c->model('Label')->load(@{ $release->labels });
    $c->model('ReleaseGroupType')->load($release->release_group);
    $c->model('MediumFormat')->load($release->all_mediums);
    $c->model('Release')->annotation->load_latest ($release);
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

sub _preview_edit
{
    my ($self, $c, $type, $editnote, %args) = @_;

    return unless %args;

    my $edit;
    try {
        $edit = $c->model('Edit')->preview(
            edit_type => $type,
            editor_id => $c->user->id,
            %args,
       );
    }
    catch (MusicBrainz::Server::Edit::Exceptions::NoChanges $e) {
    }

    push @{ $c->stash->{edits} }, $edit if defined $edit;

    return $edit;
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
    my ($self, $c, $preview, $editnote, $data, $release) = @_;

    my $edit = $preview ? '_preview_edit' : '_create_edit';

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
                $self->$edit($c,
                    $EDIT_RELEASE_DELETERELEASELABEL,
                    $editnote, release_label => $old_label
                    );
            }
            else
            {
                # Edit ReleaseLabel
                $self->$edit($c,
                    $EDIT_RELEASE_EDITRELEASELABEL, $editnote,
                    release_label => $old_label,
                    label_id => $new_label->{'label_id'},
                    catalog_number => $new_label->{'catalog_number'},
                    );
            }
        }
        else
        {
            # Add ReleaseLabel
            $self->$edit($c,
                $EDIT_RELEASE_ADDRELEASELABEL, $editnote,
                release_id => $release ? $release->id : 0,
                label_id => $new_label->{'label_id'},
                catalog_number => $new_label->{'catalog_number'},
            );
        }
    }
}

sub _edit_release_track_edits
{
    my ($self, $c, $preview, $editnote, $data, $release) = @_;

    my $edit = $preview ? '_preview_edit' : '_create_edit';

    my $changes = $self->release_compare ($c, $data, $release);

    my $medium_idx = 0;
    for my $medium (@$changes)
    {
        my $tracklist_id = $medium->{tracklist}->{id};

        my $track_idx = 0;
        for my $trackchanges (@{ $medium->{tracklist}->{changes} })
        {
            my $track = $trackchanges->track;
            my $rec_gid = $data->{'preview_mediums'}->[$medium_idx]->{'associations'}->[$track_idx]->{'gid'};

            my $recording;
            $recording = $c->model ('Recording')->get_by_gid ($rec_gid) if $rec_gid;

            if ($track->{'id'})
            {
                if ($track->{'deleted'})
                {
                    # Delete a track
                    $self->$edit($c,
                        $EDIT_TRACKLIST_DELETETRACK, $editnote,
                        track => $c->model('Track')->get_by_id ($track->{'id'}));
                }
                else
                {
                    my $to_edit = $c->model('Track')->get_by_id ($track->{'id'});

                    # Editing an existing track
                    $self->$edit($c,
                        $EDIT_TRACK_EDIT, $editnote,
                        position => $track->{'position'},
                        name => $track->{'name'},
                        recording_id => $recording ? $recording->id : $to_edit->recording_id,
                        artist_credit => $track->{'artist_credit'},
                        length => $track->{'length'},
                        to_edit => $to_edit,
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
                $self->$edit($c, $EDIT_TRACKLIST_ADDTRACK, $editnote, %edit);
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
                    artist_credit => artist_credit_to_ref($_->{artist_credit}),
                    position => $_->{position},
                };

                $trk->{recording_id} = $recording->id if $recording;

                push @tracks, $trk;

                $track_idx++;
            }

            # We have some tracks but no tracklist ID - so create a new tracklist
            my $create_tl = $self->$edit($c,
                $EDIT_TRACKLIST_CREATE, $editnote, tracks => \@tracks);

            $tracklist_id = $create_tl->tracklist_id || 0;
        }

        if ($medium->{'id'})
        {
            if ($medium->{'deleted'})
            {
                # Delete medium
                $self->$edit($c,
                    $EDIT_MEDIUM_DELETE, $editnote,
                    medium => $c->model('Medium')->get_by_id ($medium->{'id'}));
            }
            else
            {
                # Edit medium
                $self->$edit($c,
                    $EDIT_MEDIUM_EDIT, $editnote,
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
                release_id => $release ? $release->id : 0,
            };

            $opts->{name} = $medium->{'name'} if $medium->{'name'};
            $opts->{format_id} = $medium->{'format_id'} if $medium->{'format_id'};

            # Add medium
            $self->$edit($c,$EDIT_MEDIUM_CREATE, $editnote, %$opts);
        }

        $medium_idx++;
    }
}

sub _edit_release_annotation
{
    my ($self, $preview, $editnote, $data, $release) = @_;

    my $edit = $preview ? '_preview_edit' : '_create_edit';

    my $annotation = $release->latest_annotation ? $release->latest_annotation->text : '';
    if ($annotation ne $data->{annotation})
    {
        my $edit = $self->$edit(
            $EDIT_RELEASE_ADD_ANNOTATION, $editnote,
            entity_id => $release->id,
            text => $data->{annotation});
    }
}

sub run
{
    my ($self, $c, $release) = @_;

    $c->stash( serialized_tracklists => $self->_serialize_tracklists () );

    my $wizard = MusicBrainz::Server::Wizard->new(
        c => $c,
        name => 'release_editor',
        pages => [
            {
                name => 'information',
                title => 'Release Information',
                template => 'release/edit/information.tt',
                form => 'ReleaseEditor::Information'
            },
            {
                name => 'tracklist',
                title => 'Tracklist',
                template => 'release/edit/tracklist.tt',
                form => 'ReleaseEditor::Tracklist'
            },
            {
                name => 'recordings',
                title => 'Recordings',
                template => 'release/edit/recordings.tt',
                form => 'ReleaseEditor::Recordings'
            },
            {
                name => 'editnote',
                title => 'Edit Note',
                template => 'release/edit/editnote.tt',
                form => 'ReleaseEditor::EditNote'
            },
        ]
    );
    $wizard->process;

    if ($wizard->cancelled) {
        $self->cancelled($c);
    }
    elsif ($wizard->current_page eq 'recordings') {
        $self->associate_recordings($c, $wizard, $release);
    }
    elsif ($wizard->current_page eq 'editnote' || $wizard->submitted) {
        my $previewing = !$wizard->submitted; 
        my $data = $wizard->value;
        my $editnote = $data->{editnote};
        $release = $self->create_edits($c, $data, $previewing, $editnote, $release);

        if (!$previewing) {
            $self->submitted($c, $release);
        }
    }
    elsif ($wizard->loading) {
        $self->load($c, $wizard, $release);
    }

    $wizard->render;
}

sub create_edits
{
    my ($self, $c, $data, $previewing, $editnote, $release) = @_;

    $c->stash->{edits} = [];
    $release = inner();

    # Add any other extra edits (adding mediums, etc)
    $self->create_common_edits($c,
        data => $data,
        edit_note => $editnote,
        release => $release,
        as_previews => $previewing
    );

    return $release;
}

sub associate_recordings
{
    my ($self, $c, $wizard, $release) = @_;
    $c->model('Recording')->load($release->all_tracks) if $release;
    my $suggestions = $self->suggest_recordings($c, $wizard->value, $release);

    my $associations = [];
    for my $medium (@$suggestions)
    {
        my $medium_assoc = [];
        for my $track (@{ $medium->{tracklist}->{changes} })
        {
            my $rec;

            if (scalar @{ $track->suggestions } == 1 || $track->renamed)
            {
                $rec = $track->suggestions->[0]->entity->gid;
            }

            push @$medium_assoc, $rec ? { gid => $rec } : { gid => '' };
        }

        push @$associations, { associations => $medium_assoc };
    }

    $c->stash->{suggestions} = $suggestions;

    $wizard->load_page('recordings', { 'preview_mediums' => $associations });

}

sub create_common_edits
{
    my ($self, $c, %opts) = @_;

    my $as_previews = $opts{as_previews};
    my $data = $opts{data};
    my $edit_note = $opts{edit_note};
    my $release = $opts{release};

    # release labels edit
    # ----------------------------------------

    $self->_edit_release_labels ($c, $as_previews, $edit_note, $data, $release);

    # medium / tracklist / track edits
    # ----------------------------------------

    $self->_edit_release_track_edits ($c, $as_previews, $edit_note, $data, $release);

    # annotation
    # ----------------------------------------

    $self->_edit_release_annotation ($as_previews, $edit_note, $data, $release);

    if ($as_previews) {
        $c->model ('Edit')->load_all (@{ $c->stash->{edits} });
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
