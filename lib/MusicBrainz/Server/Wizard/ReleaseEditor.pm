package MusicBrainz::Server::Wizard::ReleaseEditor;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::CGI::Expand qw( collapse_hash expand_hash );
use Clone 'clone';
use JSON::Any;
use List::UtilsBy 'uniq_by';
use MusicBrainz::Server::Data::Search qw( escape_query );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref hash_structure trim );
use MusicBrainz::Server::Edit::Utils qw( clean_submitted_artist_credits );
use MusicBrainz::Server::Track qw( unformat_track_length format_track_length );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Constants qw( $AUTO_EDITOR_FLAG );
use MusicBrainz::Server::Validation qw( is_guid normalise_strings );
use MusicBrainz::Server::Wizard;
use Scalar::Util qw( looks_like_number );
use Try::Tiny;

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::CDTOC';
use aliased 'MusicBrainz::Server::Entity::Label';
use aliased 'MusicBrainz::Server::Entity::SearchResult';
use aliased 'MusicBrainz::Server::Entity::Track';

use MusicBrainz::Server::Constants qw(
    $EDIT_ARTIST_CREATE
    $EDIT_LABEL_CREATE
    $EDIT_MEDIUM_CREATE
    $EDIT_MEDIUM_ADD_DISCID
    $EDIT_MEDIUM_DELETE
    $EDIT_MEDIUM_EDIT
    $EDIT_RECORDING_EDIT
    $EDIT_RELEASE_ADDRELEASELABEL
    $EDIT_RELEASE_ADD_ANNOTATION
    $EDIT_RELEASE_DELETERELEASELABEL
    $EDIT_RELEASE_EDITRELEASELABEL
    $EDIT_RELEASE_REORDER_MEDIUMS
);

extends 'MusicBrainz::Server::Wizard';

has 'release' => (
    is => 'rw',
);

sub _build_pages {
    my $self = shift;

    return [
        {
            name => 'information',
            title => l('Release Information'),
            template => 'release/edit/information.tt',
            form => 'ReleaseEditor::Information',
            prepare => sub { $self->prepare_information ($self->release); },
        },
        {
            name => 'tracklist',
            title => l('Tracklist'),
            template => 'release/edit/tracklist.tt',
            form => 'ReleaseEditor::Tracklist',
            prepare => sub { $self->prepare_tracklist ($self->release); },
        },
        {
            name => 'recordings',
            title => l('Recordings'),
            template => 'release/edit/recordings.tt',
            form => 'ReleaseEditor::Recordings',
            prepare => sub { $self->prepare_recordings ($self->release); },
        },
        {
            name => 'missing_entities',
            title => l('Add Missing Entities'),
            template => 'release/edit/missing_entities.tt',
            form => 'ReleaseEditor::MissingEntities',
            prepare => sub { $self->prepare_missing_entities; },
            skip => sub { $self->skip_missing_entities; },
        },
        {
            name => 'editnote',
            title => l('Edit Note'),
            template => 'release/edit/editnote.tt',
            form => 'ReleaseEditor::EditNote',
            prepare => sub { $self->prepare_edits; },
        },
    ]
}

sub run
{
    my $self = shift;

    $self->process;

    if ($self->submitted)
    {
        $self->prepare_edits;
    }
}

sub init_object { shift->release }

sub load
{
    my ($self) = @_;

    my $release = inner();

    if (!$release->label_count)
    {
        $release->add_label(
            MusicBrainz::Server::Entity::ReleaseLabel->new(
                label => MusicBrainz::Server::Entity::Label->new
            )
        );
    }

    if (!$release->event_count)
    {
        $release->add_event(
            MusicBrainz::Server::Entity::ReleaseEvent->new (
                date => MusicBrainz::Server::Entity::PartialDate->new
            )
        );
    }

    $self->initialize($release);
}

=method _load_release_groups

Load release groups for a particular recording.  Used to display the
"appears on" field underneath a recording suggestion.

=cut

sub _load_release_groups
{
    my ($self, $recording) = @_;

    my ($tracks, $hits) = $self->c->model('Track')->find_by_recording ($recording->id, 6, 0);

    $self->c->model('ReleaseGroup')->load(map { $_->medium->release } @{ $tracks });

    my %rgs;
    for (@{ $tracks })
    {
        my $rg = $_->medium->release->release_group;
        $rgs{$rg->gid} = $rg;
    }

    return [ sort { $a->name cmp $b->name } values %rgs ];
}


=method name_is_equivalent

Compares two track names, considers them equivalent if there are only
case changes, changes in punctuation and/or changes in whitespace between
the two strings.

=cut

sub name_is_equivalent
{
    my ($self, $a, $b) = @_;

    $a =~ s/\p{Punctuation}//g;
    $b =~ s/\p{Punctuation}//g;
    $a =~ s/ //g;
    $b =~ s/ //g;

    return lc($a) eq lc($b);
}

=method recording_edits_by_hash

Takes the inbound (posted to the form) recording association edits,
loads the recordings and makes them available indexed by the edit_sha1
hash of the track edit.

=cut

sub recording_edits_by_hash
{
    my ($self, $medium) = @_;

    my %recording_edits;
    my @recording_gids;

    push @recording_gids, map { $_->{gid} } grep {
        $_->{gid} ne 'new' } @{ $medium->{associations} };

    my %recordings_by_gid = map {
        $_->{gid} => $_
    } values %{ $self->c->model('Recording')->get_by_gids (@recording_gids) };

    my $trkpos = 1;
    for (@{ $medium->{associations} })
    {
        $_->{id} = $_->{gid} eq "new" ? undef : $recordings_by_gid{$_->{gid}}->id;
        $recording_edits{$_->{edit_sha1}}->[$trkpos] = $_;

        $trkpos++;
    }

    return %recording_edits;
}

=method recording_edits_from_medium

Create no-op recording association edits for a particular medium
which are confirmed and linked to the edit_sha1 hashes of unedited
tracks.

When only a few tracks have been edited in a tracklist their recording
associations are unsure.  The recording associations for the remaining
tracks are known and will be taken from the hashref returned from this
method.

=cut

sub recording_edits_from_medium
{
    my ($self, $tracklist) = @_;

    my %recording_edits;

    $self->c->model('ArtistCredit')->load (@{ $tracklist->{tracks} });
    $self->c->model('Recording')->load (@{ $tracklist->{tracks} });

    for my $trk (@{ $tracklist->{tracks} })
    {
        my $trk_edit = $self->track_edit_from_track ($trk);

        $recording_edits{$trk_edit->{edit_sha1}}->[$trk->position] = {
            name => $trk_edit->{name},
            length => $trk_edit->{length},
            artist_credit => $trk_edit->{artist_credit},
            confirmed => 1,
            id => $trk->recording->id,
            gid => $trk->recording->gid
        };
    }

    return %recording_edits;
}

=method track_edits_from_medium

Create no-op track edits for a particular medium.

=cut

sub track_edits_from_medium
{
    my ($self, $medium) = @_;

    $self->c->model('Track')->load_for_mediums ($medium);
    $self->c->model('ArtistCredit')->load ($medium->all_tracks);
    $self->c->model('Recording')->load ($medium->all_tracks);

    my @data = map { $self->track_edit_from_track ($_) } $medium->all_tracks;

    use Data::Dumper;
    warn "track edits from medium: ".Dumper (
        { input => $medium, output => \@data });

    return @data;
}

=method _search_recordings

Search for recordings which match the track name and artist credit preview of a
new track.

=cut

sub _search_recordings
{
    my ($self, $track_name, $artist_credit, $limit) = @_;

    my $offset = 0;
    my $where = { artist => $artist_credit->{names}->[0]->{artist}->{name} };

    my ($search_results, $hits) = $self->c->model ('Search')->search (
        'recording', $track_name, $limit, $offset, $where);

    return @$search_results;
}


=method _exact_match

Compare a search_result with a track edit, return true if artist credit
and track title match exactly.

=cut

sub _exact_match
{
    my ($self, $search_result, $trk_edit) = @_;

    return $search_result->entity->name eq $trk_edit->{name} &&
        $search_result->entity->artist_credit->name eq $trk_edit->{artist_credit}->{preview};
}


=method associate_recordings

For each track edit, suggest whether the existing recording
association should be kept or a new recording should be added.

For each recording association set "confirmed => 0" if we are unsure
about the suggestion and require the user to confirm our choice.

=cut

sub associate_recordings
{
    my ($self, $edits, $medium, $recording_edits) = @_;

    my @ret;
    my @suggestions;
    my @load_recordings;
    my $trk_edit;
    my $suggested_tracklist;

    my $trackno = 0;
    for $trk_edit (@$edits)
    {
        my @track_suggestions;

        my $trk = $medium->tracks->[$trk_edit->{original_position} - 1];
        my $trk_at_pos = $medium->tracks->[$trk_edit->{position} - 1];

        my $rec_edit = $recording_edits->{$trk_edit->{edit_sha1}}->[$trk_edit->{position}];
        if (! $rec_edit)
        {
            # there is no recording edit at the original track position, look for it
            # elsewhere.
            for $rec_edit (@{ $recording_edits->{$trk_edit->{edit_sha1}} })
            {
                last if $rec_edit;
            }
        }

        # MBS-3957: Track length has been changed by >10 seconds.
        # Always require confirmation
        if ($trk && $trk_edit->{length} && $trk->length &&
            abs($trk_edit->{length} - $trk->length) > 10000) {
            push @load_recordings, $trk->recording_id;
            push @ret, { 'id' => $trk->recording_id, 'confirmed' => 0 };
        }

        # Track edit is already associated with a recording edit.
        # (but ignore that association if it concerns an automatically
        #  selected "add new recording").
        elsif ($rec_edit && ($rec_edit->{confirmed} || $rec_edit->{gid} ne "new"))
        {
            push @load_recordings, $rec_edit->{id} if $rec_edit->{id};
            push @ret, $rec_edit;
            $self->c->stash->{confirmation_required} = 1 unless $rec_edit->{confirmed};
        }

        # Track hasn't changed OR track has minor changes (case / punctuation).
        elsif ($trk && $self->name_is_equivalent ($trk_edit->{name}, $trk->name))
        {
            push @load_recordings, $trk->recording_id;
            push @ret, { 'id' => $trk->recording_id, 'confirmed' => 1 };
        }

        # Track hasn't changed OR track has minor changes (case / punctuation)
        # when compared to the track originally at this position on the disc.
        elsif ($trk_at_pos && $self->name_is_equivalent ($trk_edit->{name}, $trk_at_pos->name))
        {
            push @load_recordings, $trk_at_pos->recording_id;
            push @ret, { 'id' => $trk_at_pos->recording_id, 'confirmed' => 1 };
        }

        # Track is the only track associated with this particular recording.
        elsif ($trk && $self->c->model ('Recording')->usage_count ($trk->recording_id) == 1)
        {
            push @load_recordings, $trk->recording_id;
            push @ret, { 'id' => $trk->recording_id, 'confirmed' => 1 };
        }

        # Track is identical or similar to associated recording
        elsif ($trk && $trk->recording &&
               $self->name_is_equivalent ($trk_edit->{name}, $trk->recording->name) &&
               $self->name_is_equivalent ($trk_edit->{artist_credit}->{preview}, $trk->recording->artist_credit->name))
        {
            push @load_recordings, $trk->recording_id;
            push @ret, { 'id' => $trk->recording_id, 'confirmed' => 1 };
        }

        # Track is identical or similar to recording associated with the track
        # originally at this position.
        elsif ($trk_at_pos && $trk_at_pos->recording &&
               $self->name_is_equivalent ($trk_edit->{name}, $trk_at_pos->recording->name) &&
               $self->name_is_equivalent ($trk_edit->{artist_credit}->{preview}, $trk_at_pos->recording->artist_credit->name))
        {
            push @load_recordings, $trk_at_pos->recording_id;
            push @ret, { 'id' => $trk_at_pos->recording_id, 'confirmed' => 1 };
        }

        # Track changed.
        elsif ($trk)
        {
            push @load_recordings, $trk->recording_id;
            push @ret, { 'id' => undef, 'confirmed' => 0 };
            $self->c->stash->{confirmation_required} = 1;

            # Search for similar recordings.
            my @results = $self->_search_recordings ($trk_edit->{name}, $trk_edit->{artist_credit}, 3);
            $self->c->model('ArtistCredit')->load (map { $_->entity } @results) if scalar @results;

            push @track_suggestions, { 'id' => $trk->recording_id };
            push @track_suggestions, map {
                {
                    'id' => $_->entity->id,
                    'recording' => $_->entity,
                }
            } grep { $_ } @results;
        }

        # New track in the position of an existing track with recording association.
        elsif ($trk_at_pos)
        {
            push @load_recordings, $trk_at_pos->recording_id;
            push @ret, { 'id' => undef, 'confirmed' => 0 };
            $self->c->stash->{confirmation_required} = 1;

            # Search for similar recordings.
            my @results = $self->_search_recordings ($trk_edit->{name}, $trk_edit->{artist_credit}, 3);
            $self->c->model('ArtistCredit')->load (map { $_->entity } @results) if scalar @results;

            push @track_suggestions, { 'id' => $trk_at_pos->recording_id };
            push @track_suggestions, map {
                {
                    'id' => $_->entity->id,
                    'recording' => $_->entity,
                }
            } grep { $_ } @results;
        }

        # Track is new.
        else
        {
            my @results = $self->_search_recordings ($trk_edit->{name}, $trk_edit->{artist_credit}, 3);
            $self->c->model('ArtistCredit')->load (map { $_->entity } @results) if scalar @results;

            # The new track has one matching recording in the database
            if (scalar @results == 1)
            {
                # The only result is an exact match
                if ($self->_exact_match ($results[0], $trk_edit))
                {
                    push @ret, { 'id' => $results[0]->entity->id, 'confirmed' => 1 };
                }
                # The only result is an approximate match
                else
                {
                    push @ret, { 'id' => undef, 'confirmed' => 0 };
                    $self->c->stash->{confirmation_required} = 1;

                    push @track_suggestions, {
                        'id' => $results[0]->entity->id,
                        'recording' => $results[0]->entity
                    };
                }
            }

            # The new track has several matching recordings in the database
            elsif (scalar @results > 1)
            {
                my $exact_match;
                my $count = 0;
                for my $search_result (@results)
                {
                    if ($self->_exact_match ($search_result, $trk_edit))
                    {
                        $exact_match = delete $results[$count];
                        last;
                    }

                    $count++;
                }

                push @ret, { 'id' => undef, 'confirmed' => 0 };
                $self->c->stash->{confirmation_required} = 1;

                # One or more of the results are an exact match
                if ($exact_match)
                {
                    push @track_suggestions, {
                        'id' => $exact_match->entity->id,
                        'recording' => $exact_match->entity,
                    }
                }

                # Add the (remaining) exact or approximate matches
                push @track_suggestions, map {
                    {
                        'id' => $_->entity->id,
                        'recording' => $_->entity,
                    }
                } grep { $_ } @results;
            }

            # The new track has no matching recordings in the database
            else
            {
                push @ret, { 'id' => undef, 'confirmed' => 1 };
            }
        }

        $ret[$#ret]->{'edit_sha1'} = $trk_edit->{edit_sha1};

        push @suggestions, \@track_suggestions;

        $trackno++;
    }

    # FIXME: prevent loading recordings/artist credits for those recordings
    # already loaded.
    my $recordings = $self->c->model('Recording')->get_by_ids (@load_recordings);
    $self->c->model('ArtistCredit')->load(values %$recordings);

    for (@ret, map { @$_ } grep { $_ } @suggestions)
    {
        if (!defined $_->{recording})
        {
            $_->{recording} = $_->{id} ? $recordings->{$_->{id}} : undef;
        }
    }

    return (\@ret, \@suggestions);
}

sub prepare_information
{
    my ($self, $release) = @_;

    my $labels = $self->c->model('Label')->get_by_ids(
        grep { $_ }
        map { $_->{label_id} }
        @{ $self->get_value ("information", "labels") // [] });

    my $rg_id = $self->get_value ("information", "release_group_id");

    $self->c->stash(
        labels_by_id => $labels,
        release_group => $rg_id ? $self->c->model('ReleaseGroup')->get_by_id($rg_id) : undef
        );
}

sub prepare_tracklist
{
    my ($self, $release) = @_;

    my $submitted_ac = $self->get_value ("information", "artist_credit");

    my %artist_ids;
    map { $artist_ids{$_->{artist}->{id}} = 1 }
    grep { $_->{artist}->{id} } @{ $submitted_ac->{names} };

    my $artists = $self->c->model('Artist')->get_by_ids (keys %artist_ids);

    map { $_->{artist}->{gid} = $artists->{$_->{artist}->{id}}->gid }
    grep { $_->{artist}->{id} } @{ $submitted_ac->{names} };

    my $mediums = $self->get_value ('tracklist', 'mediums') // [];
    if (scalar @$mediums == 0)
    {
        # Releases should always have one medium, but the current
        # edit-system cannot guarantee that.  See MBS-1929.
        #
        # "Add Disc" buttons use an existing disc as a template, so we
        # need to make sure there is atleast one disc.
        $self->set_value (
            'tracklist', 'mediums', [
                {
                    'format_id' => undef,
                    'position' => '1',
                    'name' => undef,
                    'deleted' => '0',
                    'edits' => '[]',
                    'toc' => undef,
                    'id' => undef
                }]);
    }

    $self->c->stash->{release_artist} = $submitted_ac;
}

sub prepare_recordings
{
    my ($self, $release) = @_;

    my $json = JSON::Any->new( utf8 => 1 );

    my @medium_edits = @{ $self->get_value ('tracklist', 'mediums') // [] };
    my @recording_edits = @{ $self->get_value ('recordings', 'rec_mediums') // [] };

    my $mediums_by_id = $self->c->model('Medium')->get_by_ids(
        map { $_->{id} || $_->{medium_id_for_recordings} }
        grep { defined $_->{id} || defined $_->{medium_id_for_recordings} }
        @medium_edits);

    $self->c->model('Track')->load_for_mediums (values %$mediums_by_id);

    my @suggestions;
    my @mediums;

    my $count = -1;
    for my $medium_edit (@medium_edits)
    {
        $count += 1;

        $recording_edits[$count]->{medium_id} = $medium_edit->{id};

        next if $medium_edit->{deleted};

        my %recording_edits = scalar $recording_edits[$count] ?
            $self->recording_edits_by_hash ($recording_edits[$count]) :
            $self->recording_edits_from_medium ($mediums_by_id->{$medium_edit->{id}});

        $medium_edit->{edits} = $self->edited_tracklist (
            $json->decode ($medium_edit->{edits})) if $medium_edit->{edits};

        my $medium = defined $medium_edit->{id} ?
            $mediums_by_id->{$medium_edit->{id}} :
            defined $medium_edit->{medium_id_for_recordings} ?
            $mediums_by_id->{$medium_edit->{medium_id_for_recordings}} :
            undef;

        if ($medium_edit->{edits} && $medium)
        {
            $self->c->model ('Recording')->load ($medium->all_tracks);
            $self->c->model ('ArtistCredit')->load (map { $_->recording } $medium->all_tracks);

            # Tracks were edited, suggest which recordings should be
            # associated with the edited tracks.
            my ($first_suggestions, $extra_suggestions) = $self->associate_recordings (
                $medium_edit->{edits}, $medium, \%recording_edits);

            my $trackno = 0;
            $suggestions[$count] = [
                map {
                    my @suggestions;
                    push @suggestions, $_->{recording};
                    push @suggestions, map { $_->{recording} } @{ $extra_suggestions->[$trackno] };

                    $trackno++;
                    \@suggestions;
                } @$first_suggestions ];

            # Set confirmed to undef if false, so that the 'required'
            # attribute on the field prevents the page from validating.
            $recording_edits[$count]->{associations} = [ map {
                {
                    'gid' => ($_->{recording} ? $_->{recording}->gid : "new"),
                    'confirmed' => $_->{confirmed} ? 1 : undef,
                    'edit_sha1' => $_->{edit_sha1}
                } } @$first_suggestions ];
        }
        elsif ($medium_edit->{edits})
        {
            if (defined $medium_edit->{id})
            {
                # We have a medium id, but failed to load it.  That
                # probably means the release is being edited by
                # multiple people at the same time -- one of them
                # removed this medium so we cannot find it anymore.

                $self->c->stash( medium_vanished => 1 );
            }

            # A new medium has been added, create new recordings
            # for all these tracks by default (no recording
            # assocations are suggested).
            $recording_edits[$count]->{associations} ||= [];
            my $edit_idx = 0;
            for my $edit (@{ $medium_edit->{edits} }) {
                $recording_edits[$count]->{associations}[$edit_idx] ||= {
                    'gid' => 'new',
                    'confirmed' => 1,
                    'edit_sha1' => $edit->{edit_sha1},
                };

                # If a recording MBID is seeded it needs to be loaded from the DB.
                my $gid = $recording_edits[$count]->{associations}[$edit_idx]->{gid};
                if ($gid ne "new")
                {
                    # FIXME: collect these in a single query.
                    $suggestions[$count][$edit_idx] = [
                        $self->c->model ('Recording')->get_by_gid ($gid)
                    ];
                }

                $edit_idx++;
            }

            $self->c->model('ArtistCredit')->load (
                map { $_->[0] } grep { $_ } @{ $suggestions[$count] });
        }
        elsif ($recording_edits[$count]->{associations} &&
               scalar @{ $recording_edits[$count]->{associations} })
        {
            # There are no track edits, but there are edits to the
            # recording associations.  Load the previously selected
            # recordings as suggestions.

            my @assoc = @{ $recording_edits[$count]->{associations} };
            my $recordings_by_id = $self->c->model('Recording')->get_by_ids (
                map { $_->{id} } grep { $_->{id} } @assoc);

            my @recordings = map { $recordings_by_id->{$_->{id}} } @assoc;

            $self->c->model('ArtistCredit')->load (grep { $_ } @recordings);
            $suggestions[$count] = [ map { [ $_ ] } @recordings ];

            # Also load the medium, as tracks cannot be rendered
            # from the (non-existent) track edits.
            $mediums[$count] = $mediums_by_id->{$medium_edit->{id}};
            $self->c->model('ArtistCredit')->load (@{ $mediums[$count]->tracks });
        }
        else
        {
            # There are no track edits, and no edits to the recording
            # associations.
            $recording_edits[$count]->{associations} = [ ];
        }
    }

    $self->c->stash->{suggestions} = \@suggestions;
    $self->c->stash->{medium_edits} = \@medium_edits;
    $self->c->stash->{mediums} = \@mediums;
    $self->c->stash->{appears_on} = {};

    for my $medium_recordings (@suggestions)
    {
        map {
            $self->c->stash->{appears_on}->{$_->id} = $self->_load_release_groups ($_);
        } grep { $_ } map { @$_ } grep { $_ } @$medium_recordings;
    }

    $self->load_page(
        'recordings',
        {
            'rec_mediums' => \@recording_edits,
            'infer_durations' => $self->get_value ('recordings', 'infer_durations'),
            'propagate_all_track_changes' => $self->get_value ('recordings', 'propagate_all_track_changes'),
        });
}

sub prepare_missing_entities
{
    my ($self) = @_;

    my $data = $self->_expand_mediums(clone($self->value));
    my @artist_credits = $self->_missing_artist_credits($data);

    my @credits = map +{
            for => trim ($_->{artist}->{name}),
            name => trim ($_->{artist}->{name}),
        }, uniq_by { normalise_strings($_->{artist}->{name}) } @artist_credits;

    my @labels = map +{
            for => trim ($_->{name}),
            name => trim ($_->{name})
        }, uniq_by { normalise_strings($_->{name}) }
            $self->_missing_labels($data);

    $self->load_page('missing_entities', {
        missing => {
            artist => \@credits,
            label => \@labels
        }
    });

    $self->c->stash(
        missing_entity_count => scalar @credits + scalar @labels,
        possible_artists => $self->c->model('Artist')->search_by_names (
            map { $_->{for} } @credits),
        possible_labels => $self->c->model('Label')->search_by_names (
            map { $_->{for} } @labels),
        );
}

sub skip_missing_entities
{
    my $self = shift;

    return ! $self->c->stash->{missing_entity_count};
}

sub prepare_edits
{
    my $self = shift;

    my $previewing = !$self->submitted;

    my $data = clone($self->value);
    my $editnote = $data->{edit_note};

    $self->release(
        $self->create_edits(
            data => $data,
            create_edit => $previewing
                ? sub { $self->_preview_edit(@_) }
                : sub { $self->_submit_edit(@_) },
            edit_note => $editnote,
            previewing => $previewing
        ));

    if (!$previewing) {
        $self->on_submit($self);
    }
}

sub _missing_labels {
    my ($self, $data) = @_;

    $data->{labels} = $self->get_value ('information', 'labels');

    return grep { !$_->{label_id} && $_->{name} && !$_->{deleted} }
        @{ $data->{labels} };
}

sub _missing_artist_credits
{
    my ($self, $data) = @_;

    $data->{artist_credit} = clean_submitted_artist_credits($data->{artist_credit});

    return
        (
            # Artist credit for the release itself
            grep { !$_->{artist}->{id} }
            grep { ref($_) }
            @{ $data->{artist_credit}->{names} }
        ),
        (
            # Artist credits on new tracklists
            grep { !$_->artist || !$_->artist->id }
            map { @{ $_->artist_credit->names } }
            map { @{ $_->{tracks} } } grep { $_->{edits} }
            @{ $data->{mediums} }
        );
}

sub create_edits
{
    my ($self, %args) = @_;

    my ($data, $create_edit, $editnote, $previewing)
        = @args{qw( data create_edit edit_note previewing )};

    $data->{artist_credit} = clean_submitted_artist_credits($data->{artist_credit});

    $self->_expand_mediums($data);

    $self->c->model('MB')->context->sql->begin unless $previewing;

    # Artists and labels:
    # ----------------------------------------
    my (%created) = $self->_edit_missing_entities(%args);

    unless ($previewing) {
        for my $bad_ac ($self->_missing_artist_credits($data)) {
            my $artist = $created{artist}{ normalise_strings($bad_ac->{artist}->{name}) }
                or die 'No artist was created for ' . $bad_ac->{name};

            $bad_ac->{artist}->{id} = $artist;
        }

        for my $bad_label ($self->_missing_labels($data)) {
            my $label = $created{label}{ normalise_strings($bad_label->{name}) }
                or die 'No label was created for ' . $bad_label->{name};

            $bad_label->{label_id} = $label;
        }
    }

    $self->release(inner());

    # Add any other extra edits (adding mediums, etc)
    $self->create_common_edits(%args);

    $self->c->model('MB')->context->sql->commit unless $previewing;

    return $self->release;
}

sub create_common_edits
{
    my ($self, %args) = @_;

    my ($data, $create_edit, $editnote, $previewing)
        = @args{qw( data create_edit edit_note previewing )};

    # release labels edit
    # ----------------------------------------

    $self->_edit_release_labels(%args);

    # medium / tracklist / track edits
    # ----------------------------------------

    $self->_edit_release_track_edits(%args);

    # annotation
    # ----------------------------------------

    $self->_edit_release_annotation(%args);

    # recording edits
    # ----------------------------------------

    $self->_edit_recording_edits(%args);

    if ($previewing) {
        $self->c->model ('Edit')->load_all (@{ $self->c->stash->{edits} });
    }
}

sub _edit_recording_edits {
    my ($self, %args) = @_;

    my ($data, $create_edit, $editnote, $previewing)
        = @args{qw( data create_edit edit_note previewing )};

    my $medium_index = -1;
    for my $medium (@{ $data->{rec_mediums} }) {
        $medium_index++;
        my $track_index = -1;
        for my $track_association (@{ $medium->{associations} }) {
            $track_index++;
            next if $track_association->{gid} eq 'new';
            if ($track_association->{update_recording}) {
                my $track = $data->{mediums}[ $medium_index ]{tracks}[ $track_index ];
                $create_edit->(
                    $EDIT_RECORDING_EDIT, $editnote,
                    to_edit => $self->c->model('Recording')->get_by_gid( $track_association->{gid} ),
                    name => $track->name,
                    artist_credit => artist_credit_to_ref($track->artist_credit, [ "gid" ]),
                    length => $track->length,
                    as_auto_editor => $data->{as_auto_editor},
                );
            }
        }
    }
}

sub _edit_missing_entities
{
    my ($self, %args) = @_;
    my ($data, $create_edit, $editnote, $previewing)
        = @args{qw( data create_edit edit_note previewing )};

    my @missing_artist = @{ $data->{missing}{artist} || [] };
    my @artist_edits = map {
        my $artist = $_;
        $create_edit->(
            $EDIT_ARTIST_CREATE,
            $editnote,
            as_auto_editor => $data->{as_auto_editor},
            name => trim ($artist->{name}),
            sort_name => trim ($artist->{sort_name}) || '',
            comment => trim ($artist->{comment}) || '',
            ipi_codes => [ ],
            isni_codes => [ ]);
    } grep { !$_->{entity_id} } @missing_artist;

    my @missing_label = @{ $data->{missing}{label} || [] };
    my @label_edits = map {
        my $label = $_;
        $create_edit->(
            $EDIT_LABEL_CREATE,
            $editnote,
            as_auto_editor => $data->{as_auto_editor},
            name => trim ($label->{name}),
            sort_name => trim ($label->{sort_name}) || '',
            comment => trim ($label->{comment}) || '',
            ipi_codes => [ ],
            isni_codes => [ ]);
    } grep { !$_->{entity_id} } @{ $data->{missing}{label} };

    return () if $previewing;
    return (
        artist => {
            (map { normalise_strings($_->name) => $_->id }
                 values %{ $self->c->model('Artist')->get_by_ids(
                     map { $_->entity_id } @artist_edits) }),
            (map { normalise_strings($_->{for}) => $_->{entity_id} }
                 grep { $_->{entity_id} } @missing_artist)
        },
        label => {
            (map { normalise_strings($_->name) => $_->id }
                 values %{ $self->c->model('Label')->get_by_ids(
                     map { $_->entity_id } @label_edits) }),
            (map { normalise_strings($_->{for}) => $_->{entity_id} }
                 grep { $_->{entity_id} } @missing_label)
        }
    )
}

sub _release_label_empty {
    my ($release_label) = @_;
    # An 'empty' release label is either deleted in the UI, or has no catalog
    # number nor label.
    return $release_label->{'deleted'} || (
        ($release_label->{catalog_number} eq '' || !defined($release_label->{catalog_number}))
            && !$release_label->{label_id}
    );
}

sub _edit_release_labels
{
    my ($self, %args) = @_;
    my ($data, $create_edit, $editnote, $previewing)
        = @args{qw( data create_edit edit_note previewing )};

    my $max = scalar @{ $data->{'labels'} } - 1;

    my $labels = $self->c->model('Label')->get_by_ids(
        grep { $_ }
            (map { $_->{label_id} } @{ $data->{'labels'} }),
            (map { $_->label_id } $self->release ? $self->release->all_labels : ())
    );

    for (0..$max)
    {
        my $new_label = $data->{'labels'}->[$_];
        my $old_label = $self->release->labels->[$_] if $self->release;

        $new_label->{name} = trim ($new_label->{name}) if $new_label->{name};
        $new_label->{catalog_number} = trim ($new_label->{catalog_number}) if $new_label->{catalog_number};

        if ($old_label)
        {
            if (_release_label_empty($new_label))
            {
                # Delete ReleaseLabel
                $create_edit->(
                    $EDIT_RELEASE_DELETERELEASELABEL,
                    $editnote, release_label => $old_label,
                    as_auto_editor => $data->{as_auto_editor},
                );
            }
            else
            {
                # Edit ReleaseLabel
                my %args = (
                    release_label => $old_label,
                    catalog_number => $new_label->{catalog_number},
                    as_auto_editor => $data->{as_auto_editor},
                    label => $new_label->{label_id} ? $labels->{ $new_label->{label_id} } : undef
                );

                $create_edit->($EDIT_RELEASE_EDITRELEASELABEL, $editnote, %args);
            }
        }
        elsif (_release_label_empty($new_label))
        {
            # Ignore new labels which have already been deleted, or contain no
            # useful information.
        }
        elsif (
            $previewing ?
                $new_label->{name} || $new_label->{catalog_number} :
                $new_label->{label_id} || $new_label->{catalog_number})
        {
            my $label;

            # Add ReleaseLabel
            if ($previewing && !$new_label->{label_id})
            {
                $label = $new_label->{name} ?
                    Label->new(
                        id   => 0,
                        name => $new_label->{name}
                    ) : undef;
            }
            else
            {
                $label = $labels->{ $new_label->{label_id} } if $new_label->{label_id};
            }

            $create_edit->(
                $EDIT_RELEASE_ADDRELEASELABEL, $editnote,
                release => $previewing ? undef : $self->release,
                label => $label,
                catalog_number => $new_label->{catalog_number},
                as_auto_editor => $data->{as_auto_editor},
            );
        }
    }
}

sub _edit_release_track_edits
{
    my ($self, %args) = @_;
    my ($data, $create_edit, $editnote, $previewing)
        = @args{qw( data create_edit edit_note previewing )};

    my @new_order;
    my $re_order = 0;

    my $medium_idx = -1;
    for my $new (@{ $data->{mediums} })
    {
        $medium_idx++;

        my $rec_medium = $data->{rec_mediums}->[$medium_idx];

        if ($new->{id})
        {
            # The medium already exists
            my $entity = $self->c->model('Medium')->get_by_id ($new->{id});
            $entity->release ($self->release);

            if ($new->{deleted})
            {
                # Delete medium
                $create_edit->(
                    $EDIT_MEDIUM_DELETE, $editnote,
                    medium => $entity,
                    as_auto_editor => $data->{as_auto_editor},
                );
            }
            else
            {
                my $entity = $self->c->model('Medium')->get_by_id ($new->{id});
                $entity->release($self->release);

                push @new_order, {
                    medium_id => $entity->id,
                    old => $entity->position,
                    new => $new->{position},
                };
                $re_order ||= ($entity->position != $new->{position});

                # Edit medium
                my %opts = (
                    name => trim ($new->{name}),
                    format_id => $new->{format_id},
                    to_edit => $entity,
                    as_auto_editor => $data->{as_auto_editor},
                );

                if ($new->{edits} || $rec_medium->{associations}) {
                    $opts{tracklist} = $new->{tracks};
                }

                # Edit medium
                $create_edit->(
                    $EDIT_MEDIUM_EDIT, $editnote,
                    %opts
                );
            }
        }
        elsif (!$new->{deleted})
        {
            my $add_medium_position = $new->{position};

            my $opts = {
                position => $add_medium_position,
                release => $previewing ? undef : $self->release,
                as_auto_editor => $data->{as_auto_editor},
            };

            $opts->{name} = trim ($new->{name}) if $new->{name};
            $opts->{format_id} = $new->{format_id} if $new->{format_id};

            die "Medium data does not contain sufficient information to create a tracklist"
                unless $new->{tracks};

            $self->c->model('Artist')->load_for_artist_credits (
                map { $_->artist_credit } @{ $new->{tracks} });
            $opts->{tracklist} = $new->{tracks};

            # Add medium
            my $add_medium = $create_edit->($EDIT_MEDIUM_CREATE, $editnote, %$opts);

            if ($new->{toc})
            {
                $create_edit->(
                    $EDIT_MEDIUM_ADD_DISCID,
                    $editnote,
                    cdtoc => $new->{toc},
                    release => $self->release,
                    medium_id  => $previewing ? 0 : $add_medium->entity_id,
                    as_auto_editor => $data->{as_auto_editor},
                );
            }

            push @new_order, {
                medium_id => $add_medium->entity_id,
                old => $add_medium_position,
                new => $new->{position},
            };
            $re_order ||= ($add_medium_position != $new->{position});
        }
    }

    if ($re_order) {
        $create_edit->(
            $EDIT_RELEASE_REORDER_MEDIUMS,
            $editnote,
            release  => $self->release,
            medium_positions => \@new_order,
            as_auto_editor => $data->{as_auto_editor},
        );
    }
}

sub _edit_release_annotation
{
    my ($self, %args) = @_;
    my ($data, $create_edit, $editnote, $previewing)
        = @args{qw( data create_edit edit_note previewing )};

    my $annotation = ($self->release && $self->release->latest_annotation) ?
        $self->release->latest_annotation->text : '';

    $annotation //= '';
    my $data_annotation = $data->{annotation} ? $data->{annotation} : '';

    if ($annotation ne $data_annotation)
    {
        my $edit = $create_edit->(
            $EDIT_RELEASE_ADD_ANNOTATION, $editnote,
            entity => $self->release,
            text => $data_annotation,
            as_auto_editor => $data->{as_auto_editor},
        );
    }
}

sub _preview_edit
{
    my ($self, $type, $editnote, %args) = @_;

    my $edit = $self->_create_edit(
        sub { $self->c->model('Edit')->preview(@_) },
        $type, $self->c->user->id,
        %args
    ) or return;

    return $edit;
}

sub _submit_edit
{
    my ($self, $type, $editnote, %args) = @_;

    my $privs = $self->c->user->privileges;
    if ($self->c->user->is_auto_editor && !$args{as_auto_editor}) {
        $privs &= ~$AUTO_EDITOR_FLAG;
    }

    # Set as autoedits edits that cannot fail
    $privs |= $AUTO_EDITOR_FLAG if $self->should_approve($type);

    my $edit = $self->_create_edit(
        sub { $self->c->model('Edit')->create(@_) },
        $type, $self->c->user->id,
        privileges => $privs,
        %args,
    ) or return;

    if (defined $editnote)
    {
        $self->c->model('EditNote')->add_note($edit->id, {
            text      => $editnote,
            editor_id => $self->c->user->id,
        });
    }

    $self->c->stash->{changes} = 1;
    return $edit;
}

=method should_approve

Takes a type, and should return 1 if the edit should be an autoedit

=cut

sub should_approve {
    return 0;
}

sub _create_edit {
    my ($self, $method, $type, $user_id, %args) = @_;
    return unless %args;

    delete $args{as_auto_editor};

    my $edit;

    try {
        $edit = $method->(
            edit_type => $type,
            editor_id => $user_id,
            %args,
        );
        push @{ $self->c->stash->{edits} }, $edit;
    }
    catch {
        die $_ unless ref($_) eq 'MusicBrainz::Server::Edit::Exceptions::NoChanges';
    };

    return $edit;
}


sub _expand_track
{
    my ($self, $trk, $assoc) = @_;

    my $infer_durations = $self->get_value ('recordings', 'infer_durations') // undef;

    my @names = @{ clean_submitted_artist_credits($trk->{artist_credit})->{names} };

    # artists may be seeded with an MBID, or selected in the release editor
    # with just an id.
    # FIXME: move this out of _expand_track.

    my $gid_artists = $self->c->model ('Artist')->get_by_gids (
        map { $_->{artist}->{gid} }
        grep { $_->{artist} && $_->{artist}->{gid} } @names);

    my %artists_by_gid = map { $_->gid => $_ } values %$gid_artists;

    my $artists_by_id = $self->c->model ('Artist')->get_by_ids (
        map { $_->{artist}->{id} }
        grep { $_->{artist} && $_->{artist}->{id} } @names);

    for my $i (0..$#names)
    {
        my $artist_id = $names[$i]->{artist}->{id};
        my $artist = $artists_by_id->{ $artist_id } if $artist_id;

        $artist = $artists_by_gid{ $names[$i]->{artist}->{gid} }
            if !$artist && $names[$i]->{artist}->{gid};

        $names[$i]->{artist} = $artist if $artist;
    }

    my %new_track = (
        length => $trk->{length} // (($infer_durations and $assoc) ? $assoc->length : undef),
        name => $trk->{name},
        position => trim ($trk->{position}),
        number => trim ($trk->{number} // $trk->{position}),
        artist_credit => ArtistCredit->from_array ([
            grep { $_->{name} } @names
        ]));

    $new_track{id} = $trk->{id} if looks_like_number ($trk->{id});
    my $entity = Track->new(%new_track);

    if ($assoc)
    {
        $entity->recording_id ($assoc->id);
        $entity->recording ($assoc);
    }

    return $entity;
}

=method _expand_mediums

Expands the 'edits' element for each medium object into a set of tracks

=cut

sub _expand_mediums
{
    my ($self, $data) = @_;
    my $json = JSON::Any->new( utf8 => 1 );

    $data->{mediums} = $self->get_value ('tracklist', 'mediums') // [];
    $data->{rec_mediums} = $self->get_value ('recordings', 'rec_mediums') // [];

    my $count = 0;
    for my $disc (@{ $data->{mediums} }) {
        my $rec_medium = $data->{rec_mediums}->[$count];
        my $medium_id = $rec_medium->{medium_id};
        my $associations = $rec_medium->{associations};
        my $edits = $disc->{edits};
        $count++;

        next unless $edits || $associations && scalar @$associations;

        my @gids = grep { $_ ne 'new' } map { $_->{gid} } @$associations;
        my %recordings = map { $_->gid => $_ }
          values %{ $self->c->model('Recording')->get_by_gids (@gids) };

        if ($edits)
        {
            my $pos = 0;
            $disc->{tracks} = [ map {
                my $rec = $recordings{$associations->[$pos]->{gid}};
                $pos++;
                $self->_expand_track ($_, $rec);
            } @{ $self->edited_tracklist($json->decode($edits)) } ];
        }
        elsif ($disc->{deleted})
        {
            $disc->{tracks} = [ ];
        }
        elsif ($medium_id)
        {
            my $medium = $self->c->model('Medium')->get_by_id ($medium_id);
            $self->c->model('Track')->load_for_mediums ($medium);
            $self->c->model('ArtistCredit')->load ($medium->all_tracks);
            $self->c->model('Artist')->load ($medium->all_tracks);

            my $pos = 0;
            $disc->{tracks} = [ map {
                my $rec = $recordings{$associations->[$pos]->{gid}};
                $pos++;
                if ($rec) {
                    $_->recording_id ($rec->id);
                    $_->recording ($rec);
                }
                else
                {
                    $_->clear_recording_id;
                    $_->clear_recording;
                }
                $_
            } $medium->all_tracks ];
        }
    }

    return $data;
}

=method update_track_edit_hash

Updates the edit_sha1 hash in a track edit.

=cut

sub update_track_edit_hash
{
    my ($self, $track) = @_;

    my $sha = hash_structure({
        name => $track->{name},
        length => $track->{length},
        artist_credit => $track->{artist_credit},
    });
    $track->{edit_sha1} = $sha;

    return $track;
}

=method track_edit_from_track

Generates a track edit for the tracklist page from a track instance.

=cut
sub track_edit_from_track
{
    my ($self, $track) = @_;

    return $self->update_track_edit_hash ({
        artist_credit => artist_credit_to_ref ($track->artist_credit, [ "gid" ]),
        deleted => 0,
        length => $track->length,
        name => $track->name,
        position => $track->position,
        number => $track->number
    });
}


=method edited_tracklist

Returns a list of tracks, sorted by position, with deleted tracks
removed.

=cut

sub edited_tracklist
{
    my ($self, $tracks) = @_;

    my $pos = 1;
    map { $_->{original_position} = $pos++ } @$tracks;

    return [ sort { $a->{position} <=> $b->{position} } grep { ! $_->{deleted} } @$tracks ];
}

sub _seed_parameters {
    my ($self, $params) = @_;
    $params = expand_hash($params);

    my @transformations = (
        [
            'language_id', 'language',
            sub { shift->model('Language')->find_by_code(shift) },
        ],
        [
            'country_id', 'country',
            sub { shift->model('Area')->find_by_iso_3166_1_code(shift) },
        ],
        [
            'script_id', 'script',
            sub { shift->model('Script')->find_by_code(shift) },
        ],
        [
            'status_id', 'status',
            sub { shift->model('ReleaseStatus')->find_by_name(shift) },
        ],
        [
            'packaging_id', 'packaging',
            sub { shift->model('ReleasePackaging')->find_by_name(shift) },
        ],
    );

    if (exists $params->{type})
    {
        my %primary_types = map { lc($_->name) => $_ } $self->c->model('ReleaseGroupType')->get_all ();
        my %secondary_types = map { lc($_->name) => $_ } $self->c->model('ReleaseGroupSecondaryType')->get_all ();

        for my $typename (ref($params->{type}) eq 'ARRAY' ? @{ $params->{type} } : ($params->{type}))
        {
            if (defined $primary_types{$typename})
            {
                $params->{primary_type_id} = $primary_types{$typename}->id;
            }
            elsif (defined $secondary_types{$typename})
            {
                $params->{secondary_type_ids} = [] unless defined $params->{secondary_type_ids};
                push @{ $params->{secondary_type_ids} }, $secondary_types{$typename}->id;
            }
        }

        delete $params->{type};
    }

    for my $trans (@transformations) {
        my ($key, $alias, $transform) = @$trans;
        if (exists $params->{$alias}) {
            my $obj = $transform->($self->c, delete $params->{$alias}) or next;
            $params->{$key} = $obj->id;
        }
    }

    if (exists $params->{country_id} || exists $params->{date})
    {
        # schema 16 style country/date pair, convert to schema 18 release event.
        $params->{events} = [ { deleted => 0 } ];
        $params->{events}->[0]->{date} = $params->{date} if exists $params->{date};
        $params->{events}->[0]->{country_id} = $params->{country_id} if exists $params->{country_id};
    }

    if (my $release_group_mbid = delete $params->{release_group}) {
        if(is_guid($release_group_mbid) and
               my $release_group = $self->c->model('ReleaseGroup')
                   ->get_by_gid($release_group_mbid)) {
            $params->{release_group_id} = $release_group->id;
            $params->{release_group}{name} = $release_group->name;
        }
    }

    for my $label (@{ $params->{labels} || [] }) {
        if (my $mbid = $label->{mbid}) {
            if(is_guid($mbid) and
                   my $entity = $self->c->model('Label')
                       ->get_by_gid($mbid)) {
                $label->{label_id} = $entity->id;
                $label->{name} = $entity->name;
            }
        }
        elsif (my $name = $label->{name}) {
            $label->{name} = $name;
        }
    }

    $params->{mediums} = [ map {
        defined $_ ? $_ : { position => 1 }
    } @{ $params->{mediums} || [] } ];

    for my $container (
        $params,
        map { @{ $_->{track} || [] } }
            @{ $params->{mediums} || [] }
    ) {
        if (ref($container->{artist_credit}) eq 'ARRAY') {
            $container->{artist_credit} = {
                names => $container->{artist_credit}
            };
        }
        elsif (ref($container->{artist_credit}) ne 'HASH') {
            delete $container->{artist_credit};
        }
    }

    for my $artist_credit (
        map { @{ $_->{names} || [] } } (
            ($params->{artist_credit} || ()),
            map { $_->{artist_credit} || {} }
                map { @{ $_->{track} || []}  }
                    @{ $params->{mediums} || []}
        )
    ) {
        if (my $mbid = $artist_credit->{mbid})
        {
            my $entity = $self->c->model('Artist')->get_by_gid($mbid);
            if ($entity)
            {
                $artist_credit->{name} ||= $entity->name;
                $artist_credit->{artist}->{gid} = $entity->gid;
                $artist_credit->{artist}->{id} = $entity->id;
                $artist_credit->{artist}->{name} = $entity->name;
            }
        }
        else {
            $artist_credit->{artist}->{name} ||= $artist_credit->{name};
        }
    }

    {
        my $medium_idx = 0;
        my $json = JSON::Any->new(utf8 => 1);
        for my $medium (@{ $params->{mediums} || [] }) {
            if (my $format = delete $medium->{format}) {
                my $entity = $self->c->model('MediumFormat')
                    ->find_by_name($format);
                $medium->{format_id} = $entity->id if $entity;
            }

            my $toc = $medium->{toc};
            if ($toc and my $cdtoc = CDTOC->new_from_toc($toc)) {
                if (ref($medium->{track})) {
                    if (@{ $medium->{track} } != $cdtoc->track_count) {
                        delete $medium->{toc};
                    }
                    else {
                        my $details = $cdtoc->track_details;
                        for my $i (1..$cdtoc->track_count) {
                            my $n = $i - 1;
                            $medium->{track}->[$n] ||= {};
                            $medium->{track}->[$n]->{length} =
                                $details->[$n]->{length_time};
                        }
                    }
                }
                else {
                    $medium->{track} = [ map +{
                        length => $_->{length_time}
                    }, @{ $cdtoc->track_details } ];
                }
            }

            $params->{rec_mediums}[$medium_idx]{associations} = [];
            if (my @tracks = @{ $medium->{track} || [] }) {
                my @edits;
                my $track_idx;
                for my $track (@tracks) {
                    $track->{position} = ++$track_idx;
                    my $track_ac = $track->{artist_credit} || $params->{artist_credit};

                    if ($track_ac->{names}) {
                        $track->{artist_credit}{names} = [
                            map +{
                                name => $_->{name} // $_->{artist}->{name},
                                join_phrase => $_->{join_phrase},
                                artist => {
                                    name => $_->{artist}->{name} // $_->{name},
                                    id => $_->{artist}->{id},
                                    gid => $_->{artist}->{gid},
                                }
                            }, @{$track_ac->{names}}
                        ];

                        $track->{artist_credit}{preview} = join (
                            "", map { ($_->{name} // "") . ($_->{join_phrase} // "")
                            } @{$track_ac->{names}});
                    }

                    if (my $length = $track->{length}) {
                        $track->{length} = ($length =~ /:/)
                            ? unformat_track_length ($length)
                            : $length;
                        $track->{length} = defined $track->{length} ? int($track->{length}) : undef;
                    }

                    my $track = $self->update_track_edit_hash ($track);

                    push @edits, $track;

                    my $recording_id = delete $track->{recording};
                    my $recording = $self->c->model('Recording')->get_by_gid($recording_id) if $recording_id;

                    if ($recording)
                    {
                        $params->{rec_mediums}[$medium_idx]{associations}[$track_idx] = {
                            edit_sha1 => $track->{edit_sha1},
                            confirmed => 1,
                            id => $recording->id,
                            gid => $recording->gid
                        };
                    }
                    else
                    {
                        # Have some kind of empty default which isn't undef
                        # at this track position, FormHandler skips undef
                        # values when processing the init_object.
                        $params->{rec_mediums}[$medium_idx]{associations}[$track_idx] = {
                            edit_sha1 => $track->{edit_sha1},
                            confirmed => 1,
                            gid => "new"
                        };
                    }
                }

                $medium->{edits} = $json->encode(\@edits);
            }

            $medium->{position} = ++$medium_idx;
        }
    };

    # FIXME a bit of a hack, but if either of these = [], HTML::FormHandler
    # will show no rows
    $params->{labels} = [
        { label => '', catalog_number => '' }
    ] unless @{ $params->{labels}||[] };

    $params->{events} = [
        { deleted => 0 }
    ] unless @{ $params->{events}||[] };

    $params->{seeded} = 1;

    return collapse_hash($params);
};


sub _filter_release_events {
    my ($self, $events) = @_;

    return $self->_filter_empty_release_events (
        $self->_filter_deleted_release_events ($events));
}

sub _filter_empty_release_events {
    my (undef, $events) = @_;

    return [
        grep {
            (defined $_->{country_id} ||
             defined $_->{date}->{year} ||
             defined $_->{date}->{month} ||
             defined $_->{date}->{day})
        } @$events ];
}

sub _filter_deleted_release_events {
    my (undef, $events) = @_;
    return [
        map { delete $_->{deleted}; $_ }
            grep { !$_->{deleted} }
                @$events
    ];
}

=head1 LICENSE

Copyright (C) 2011 MetaBrainz Foundation

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
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut

__PACKAGE__->meta->make_immutable;
1;
