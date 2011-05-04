package MusicBrainz::Server::Wizard::ReleaseEditor;
use Moose;
use namespace::autoclean;

use CGI::Expand qw( collapse_hash expand_hash );
use Clone 'clone';
use JSON::Any;
use List::UtilsBy 'uniq_by';
use MusicBrainz::Server::Data::Search qw( escape_query );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_alternative_ref hash_structure );
use MusicBrainz::Server::Edit::Utils qw( clean_submitted_artist_credits );
use MusicBrainz::Server::Track qw( unformat_track_length format_track_length );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Types qw( $AUTO_EDITOR_FLAG );
use MusicBrainz::Server::Validation qw( is_guid );
use MusicBrainz::Server::Wizard;
use TryCatch;

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::CDTOC';
use aliased 'MusicBrainz::Server::Entity::SearchResult';
use aliased 'MusicBrainz::Server::Entity::Track';

use MusicBrainz::Server::Constants qw(
    $EDIT_ARTIST_CREATE
    $EDIT_LABEL_CREATE
    $EDIT_MEDIUM_CREATE
    $EDIT_MEDIUM_ADD_DISCID
    $EDIT_MEDIUM_DELETE
    $EDIT_MEDIUM_EDIT
    $EDIT_RELEASE_ADDRELEASELABEL
    $EDIT_RELEASE_ADD_ANNOTATION
    $EDIT_RELEASE_DELETERELEASELABEL
    $EDIT_RELEASE_EDITRELEASELABEL
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

    $self->c->model('ReleaseGroup')->load(map { $_->tracklist->medium->release } @{ $tracks });

    my %rgs;
    for (@{ $tracks })
    {
        my $rg = $_->tracklist->medium->release->release_group;
        $rgs{$rg->gid} = $rg;
    }

    return [ sort { $a->name cmp $b->name } values %rgs ];
}


=method name_is_equivalent

Compares two track names, considers them equivalent if there are only
case changes or changes in punctuation between the two strings.

=cut

sub name_is_equivalent
{
    my ($self, $a, $b) = @_;

    $a =~ s/\p{Punctuation}//g;
    $b =~ s/\p{Punctuation}//g;

    return lc($a) eq lc($b);
}

=method recording_edits_by_hash

Takes the inbound (posted to the form) recording association edits,
loads the recordings and makes them available indexed by the edit_sha1
hash of the track edit.

=cut

sub recording_edits_by_hash
{
    my ($self, @edits) = @_;

    my %recording_edits;
    my @recording_gids;

    for my $medium (@edits)
    {
        push @recording_gids, map { $_->{gid} } grep {
            $_->{gid} ne 'new' } @{ $medium->{associations} };
    }

    my %recordings_by_gid = map {
        $_->{gid} => $_
    } values %{ $self->c->model('Recording')->get_by_gids (@recording_gids) };

    for my $medium (@edits)
    {
        for (@{ $medium->{associations} })
        {
            $_->{id} = $_->{gid} eq "new" ? undef : $recordings_by_gid{$_->{gid}}->id;
            $recording_edits{$_->{edit_sha1}} = $_;
        }
    }

    return %recording_edits;
}

=method recording_edits_by_hash

Create no-op recording association edits for a particular tracklist
which are confirmed and linked to the edit_sha1 hashes of unedited
tracks.

When only a few tracks have been edited in a tracklist their recording
associations are unsure.  The recording associations for the remaining
tracks are known and will be taken from the hashref returned from this
method.

=cut

sub recording_edits_from_tracklist
{
    my ($self, $tracklists_by_id) = @_;

    my %recording_edits;

    for my $tracklist (values %$tracklists_by_id)
    {
        $self->c->model('ArtistCredit')->load (@{ $tracklist->{tracks} });
        $self->c->model('Recording')->load (@{ $tracklist->{tracks} });

        for (@{ $tracklist->{tracks} })
        {
            my $edit_sha1 = hash_structure (
                {
                    name => $_->name,
                    length => format_track_length ($_->length),
                    artist_credit => {
                        preview => $_->artist_credit->name,
                        names => artist_credit_to_alternative_ref (
                            $_->artist_credit)
                    }
                });

            $recording_edits{$edit_sha1} = {
                edit_sha1 => $edit_sha1,
                confirmed => 1,
                id => $_->recording->id,
                gid => $_->recording->gid
            };
        }
    }

    return %recording_edits;
}

=method associate_recordings

For each track edit, suggest whether the existing recording
association should be kept or a new recording should be added.

For each recording association set "confirmed => 0" if we are unsure
about the suggestion and require the user to confirm our choice.

=cut

sub associate_recordings
{
    my ($self, $edits, $tracklists, $recording_edits) = @_;

    my @ret;
    my @recording_ids;

    my $count = 0;
    for (@$edits)
    {
        my $trk = $tracklists->tracks->[$_->{original_position} - 1];
        my $rec_edit = $recording_edits->{$_->{edit_sha1}};

        # Track edit is already associated with a recording edit.
        if ($rec_edit)
        {
            push @recording_ids, $rec_edit->{id} if $rec_edit->{id};
            push @ret, $rec_edit;
            $self->c->stash->{confirmation_required} = 1 unless $rec_edit->{confirmed};
        }

        # Track hasn't changed OR track has minor changes (case / punctuation).
        elsif ($trk && $self->name_is_equivalent ($_->{name}, $trk->name))
        {
            push @recording_ids, $trk->recording_id;
            push @ret, { 'id' => $trk->recording_id, 'confirmed' => 1 };
        }

        # Track changed significantly, but there is only one recording
        # associated with it.  Keep the recording association, but ask
        # for confirmation.
        elsif ($trk && $self->c->model('Recording')->usage_count ($trk->recording_id) == 1)
        {
            push @recording_ids, $trk->recording_id;
            push @ret, { 'id' => $trk->recording_id, 'confirmed' => 0 };
            $self->c->stash->{confirmation_required} = 1;
        }

        # Track changed.
        elsif ($trk)
        {
            push @ret, { 'id' => undef, 'confirmed' => 0 };
            $self->c->stash->{confirmation_required} = 1;
        }

        # Track is new.
        # (FIXME: search for similar existing tracks, suggest those and set
        #  "confirmed => 0" if found?)
        else
        {
            push @ret, { 'id' => undef, 'confirmed' => 1 };
        }

        $ret[$#ret]->{'edit_sha1'} = $_->{edit_sha1};

        $count += 1;
    }

    my $recordings = $self->c->model('Recording')->get_by_ids (@recording_ids);
    $self->c->model('ArtistCredit')->load(values %$recordings);

    for (@ret)
    {
        $_->{recording} = $_->{id} ? $recordings->{$_->{id}} : undef;
    }

    return @ret;
}

sub prepare_tracklist
{
    my ($self, $release) = @_;

    $self->c->stash->{release_artist_json} = "null";
}

sub prepare_recordings
{
    my ($self, $release) = @_;

    my $json = JSON::Any->new( utf8 => 1 );

    my @recording_edits = @{ $self->value->{rec_mediums} };
    my @tracklist_edits = @{ $self->value->{mediums} };

    my $tracklists_by_id = $self->c->model('Tracklist')->get_by_ids(
        map { $_->{tracklist_id} } grep { defined $_->{tracklist_id} }
        @tracklist_edits);

    $self->c->model('Track')->load_for_tracklists (values %$tracklists_by_id);

    my %recording_edits = scalar @recording_edits ?
        $self->recording_edits_by_hash (@recording_edits) :
        $self->recording_edits_from_tracklist ($tracklists_by_id);

    my @suggestions;
    my @tracklists;

    my $count = -1;
    for my $medium (@tracklist_edits)
    {
        $count += 1;

        $recording_edits[$count]->{tracklist_id} = $medium->{tracklist_id};

        next if $medium->{deleted};

        $medium->{edits} = $self->edited_tracklist ($json->decode ($medium->{edits}))
            if $medium->{edits};

        if (defined $medium->{edits} && defined $medium->{tracklist_id})
        {
            # Tracks were edited, suggest which recordings should be
            # associated with the edited tracks.
            my @recordings = $self->associate_recordings (
                $medium->{edits},
                $tracklists_by_id->{$medium->{tracklist_id}},
                \%recording_edits);

            $suggestions[$count] = [ map { $_->{recording} } @recordings ];

            # Set confirmed to undef if false, so that the 'required'
            # attribute on the field prevents the page from validating.
            $recording_edits[$count]->{associations} = [ map {
                {
                    'gid' => ($_->{recording} ? $_->{recording}->gid : "new"),
                    'confirmed' => $_->{confirmed} ? 1 : undef,
                    'edit_sha1' => $_->{edit_sha1}
                } } @recordings ];
        }
        elsif (defined $medium->{edits})
        {
            # A new tracklist has been entered, create new recordings
            # for all these tracks by default (no recording
            # assocations are suggested).
            $recording_edits[$count]->{associations} = [ map {
                {
                    'gid' => 'new',
                    'confirmed' => 1,
                    'edit_sha1' => $_->{edit_sha1},
                } } @{ $medium->{edits} } ];
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
            $suggestions[$count] = \@recordings;

            # Also load the tracklist, as tracks cannot be rendered
            # from the (non-existent) track edits.
            $tracklists[$count] = $tracklists_by_id->{$medium->{tracklist_id}};
            $self->c->model('ArtistCredit')->load (@{ $tracklists[$count]->tracks });
        }
        else
        {
            # There are no track edits, and no edits to the recording
            # associations.
            $recording_edits[$count]->{associations} = [ ];
        }
    }

    $self->c->stash->{suggestions} = \@suggestions;
    $self->c->stash->{tracklist_edits} = \@tracklist_edits;
    $self->c->stash->{tracklists} = \@tracklists;
    $self->c->stash->{appears_on} = {};

    for my $medium_recordings (@suggestions)
    {
        map {
            $self->c->stash->{appears_on}->{$_->id} = $self->_load_release_groups ($_);
        } grep { $_ } @$medium_recordings;
    }

    $self->load_page('recordings', { 'rec_mediums' => \@recording_edits });
}

sub prepare_missing_entities
{
    my ($self) = @_;

    my $data = $self->_expand_mediums(clone($self->value));

    my @credits = map +{
            for => $_->{name},
            name => $_->{name},
        }, uniq_by { $_->{name} }
            $self->_misssing_artist_credits($data);

    my @labels = map +{
            for => $_->{name},
            name => $_->{name}
        }, uniq_by { $_->{name} }
            $self->_missing_labels($data);

    $self->load_page('missing_entities', {
        missing => {
            artist => \@credits,
            label => \@labels
        }
    });

    $self->c->stash(
        missing_entity_count => scalar @credits + scalar @labels,
        possible_artists => {
            map {
                $_ => [ $self->c->model('Artist')->find_by_name($_) ]
            } map { $_->{for} } @credits
        }
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
            data => clone($data),
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
    return grep { !$_->{label_id} && $_->{name} }
        @{ $data->{labels} };
}

sub _misssing_artist_credits
{
    my ($self, $data) = @_;
    return
        (
            # Artist credit for the release itself
            grep { !$_->{artist} } grep { ref($_) }
            map { @{ clean_submitted_artist_credits($_) } }
                $data->{artist_credit}
        ),
        (
            # Artist credits on new tracklists
            grep { !$_->artist_id }
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

    $self->_expand_mediums($data);

    # Artists and labels:
    # ----------------------------------------
    my (%created) = $self->_edit_missing_entities(%args);

    unless ($previewing) {
        for my $bad_ac ($self->_misssing_artist_credits($data)) {
            my $artist = $created{artist}{ $bad_ac->{name} }
                or die 'No artist was created for ' . $bad_ac->{name};

            # XXX Fix me
            # Because bad_ac might refer to data in the form submisison
            # OR an actual ArtistCredit object, we need to fill in both of these
            # It's a horrible hack.
            $bad_ac->{artist} = $artist;
            $bad_ac->{artist_id} = $artist;
        }

        for my $bad_label ($self->_missing_labels($data)) {
            my $label = $created{label}{ $bad_label->{name} }
                or die 'No label was created for ' . $bad_label->{name};

            $bad_label->{label_id} = $label;
        }
    }

    $self->release(inner());

    # Add any other extra edits (adding mediums, etc)
    $self->create_common_edits(%args);

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

    if ($previewing) {
        $self->c->model ('Edit')->load_all (@{ $self->c->stash->{edits} });
    }
}

sub _edit_missing_entities
{
    my ($self, %args) = @_;
    my ($data, $create_edit, $editnote, $previewing)
        = @args{qw( data create_edit edit_note previewing )};

    my %created;

    my @missing_artist = @{ $data->{missing}{artist} || [] };
    my @artist_edits = map {
        my $artist = $_;
        $create_edit->(
            $EDIT_ARTIST_CREATE,
            $editnote,
            as_auto_editor => $data->{as_auto_editor},
            name => $artist->{name},
            sort_name => $artist->{sort_name} || '',
            comment => $artist->{comment} || '');
    } grep { !$_->{entity_id} } @missing_artist;

    my @missing_label = @{ $data->{missing}{label} || [] };
    my @label_edits = map {
        my $label = $_;
        $create_edit->(
            $EDIT_LABEL_CREATE,
            $editnote,
            as_auto_editor => $data->{as_auto_editor},
            map { $_ => $label->{$_} } qw( name sort_name comment ));
    } grep { !$_->{entity_id} } @{ $data->{missing}{label} };

    return () if $previewing;
    return (
        artist => {
            (map { $_->entity->name => $_->entity->id } @artist_edits),
            (map { $_->{for} => $_->{entity_id} }
                 grep { $_->{entity_id} } @missing_artist)
        },
        label => {
            (map { $_->entity->name => $_->entity->id } @label_edits),
            (map { $_->{for} => $_->{entity_id} }
                 grep { $_->{entity_id} } @missing_label)
        }
    )
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

        if ($old_label)
        {
            if ($new_label->{'deleted'})
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
                );

                my $label;
                $label = $labels->{ $new_label->{label_id} } if $new_label->{label_id};
                $args{label} = $label if $label;

                $create_edit->($EDIT_RELEASE_EDITRELEASELABEL, $editnote, %args);
            }
        }
        elsif ($new_label->{label_id} || $new_label->{catalog_number})
        {
            # Add ReleaseLabel

            $create_edit->(
                $EDIT_RELEASE_ADDRELEASELABEL, $editnote,
                release => $previewing ? undef : $self->release,
                label => $labels->{ $new_label->{label_id} },
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

    my $medium_idx = -1;
    for my $new (@{ $data->{mediums} })
    {
        $medium_idx++;

        my $rec_medium = $data->{rec_mediums}->[$medium_idx];

        if ($new->{id})
        {
            # The medium already exists

            if ($new->{deleted})
            {
                # Delete medium
                $create_edit->(
                    $EDIT_MEDIUM_DELETE, $editnote,
                    medium => $self->c->model('Medium')->get_by_id ($new->{id}),
                    as_auto_editor => $data->{as_auto_editor},
                );
            }
            else
            {
                # Edit medium
                my %opts = (
                    name => $new->{name},
                    format_id => $new->{format_id},
                    position => $new->{position},
                    to_edit => $self->c->model('Medium')->get_by_id ($new->{id}),
                    separate_tracklists => 1,
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
            # Medium does not exist yet.

            my $opts = {
                position => $medium_idx + 1,
                release => $previewing ? undef : $self->release,
                as_auto_editor => $data->{as_auto_editor},
            };

            $opts->{name} = $new->{name} if $new->{name};
            $opts->{format_id} = $new->{format_id} if $new->{format_id};

            if ($new->{tracks}) {
                $opts->{tracklist} = $new->{tracks};
            }
            elsif (my $tracklist_id = $new->{tracklist_id}) {
                my $tracklist_entity = $self->c->model('Tracklist')->get_by_id($tracklist_id);
                $self->c->model('Track')->load_for_tracklists($tracklist_entity);
                $self->c->model('ArtistCredit')->load($tracklist_entity->all_tracks);
                $opts->{tracklist} = $tracklist_entity->tracks;
            }
            else {
                die "Medium data does not contain sufficient information to create a tracklist";
            }

            # Add medium
            my $add_medium = $create_edit->($EDIT_MEDIUM_CREATE, $editnote, %$opts);

            if ($new->{toc}) {
                $create_edit->(
                    $EDIT_MEDIUM_ADD_DISCID,
                    $editnote,
                    medium_id  => $previewing ? 0 : $add_medium->entity_id,
                    release_id => $previewing ? 0 : $self->release->id,
                    cdtoc      => $new->{toc},
                    as_auto_editor => $data->{as_auto_editor},
                );
            }

            if ($new->{position} != $medium_idx + 1)
            {
                # Disc was inserted at the wrong position, enter an edit to re-order it.
                $create_edit->(
                    $EDIT_MEDIUM_EDIT, $editnote,
                    position => $new->{position},
                    to_edit => $add_medium->entity,
                    as_auto_editor => $data->{as_auto_editor},
                );
            }
        }
    }
}

sub _edit_release_annotation
{
    my ($self, %args) = @_;
    my ($data, $create_edit, $editnote, $previewing)
        = @args{qw( data create_edit edit_note previewing )};

    my $annotation = ($self->release && $self->release->latest_annotation) ?
        $self->release->latest_annotation->text : '';

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

    push @{ $self->c->stash->{edits} }, $edit;
    return $edit;
}

sub _submit_edit
{
    my ($self, $type, $editnote, %args) = @_;

    my $privs = $self->c->user->privileges;
    if ($self->c->user->is_auto_editor && !$args{as_auto_editor}) {
        $privs &= ~$AUTO_EDITOR_FLAG;
    }

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
    }
    catch (MusicBrainz::Server::Edit::Exceptions::NoChanges $e) { }

    return $edit;
}


sub _expand_track
{
    my ($self, $trk, $assoc) = @_;

    my $entity = Track->new(
        length => unformat_track_length ($trk->{length}),
        name => $trk->{name},
        position => $trk->{position},
        artist_credit => ArtistCredit->from_array ([
            map {
                { artist => $_->{id}, name => $_->{name} },
                $_->{join}
            } grep { $_->{name} } @{ $trk->{artist_credit}->{names} }
        ]));

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

    my $count = 0;
    for my $disc (@{ $data->{mediums} }) {
        my $rec_medium = $data->{rec_mediums}->[$count];
        my $tracklist_id = $rec_medium->{tracklist_id};
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
        elsif ($tracklist_id)
        {
            my $tracklist = $self->c->model('Tracklist')->get_by_id ($tracklist_id);
            $self->c->model('Track')->load_for_tracklists ($tracklist);
            $self->c->model('ArtistCredit')->load ($tracklist->all_tracks);

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
            } $tracklist->all_tracks ];
        }
    }

    return $data;
}

=method edited_tracklist

Returns a list of tracks, sorted by position, with deleted tracks removed

=cut

sub edited_tracklist
{
    my ($self, $tracks) = @_;

    my $idx = 1;
    map { $_->{original_position} = $idx++; } @$tracks;

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
            sub { shift->model('Country')->find_by_code(shift) },
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
            'type_id', 'type',
            sub { shift->model('ReleaseGroupType')->find_by_name(shift) },
        ],
        [
            'packaging_id', 'packaging',
            sub { shift->model('ReleasePackaging')->find_by_name(shift) },
        ],
    );

    for my $trans (@transformations) {
        my ($key, $alias, $transform) = @$trans;
        if (exists $params->{$alias}) {
            my $obj = $transform->($self->c, delete $params->{$alias}) or next;
            $params->{$key} = $obj->id;
        }
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
        if (my $mbid = $artist_credit->{mbid}){
            my $entity = $self->c->model('Artist')
                ->get_by_gid($mbid);
            $artist_credit->{artist_id} = $entity->id;
            $artist_credit->{name} ||= $entity->name;
            $artist_credit->{gid} = $entity->gid;
            $artist_credit->{artist_name} = $entity->name;
        }
    }

    {
        my $medium_idx;
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

            if (my @tracks = @{ $medium->{track} || [] }) {
                my @edits;
                my $track_idx;
                for my $track (@tracks) {
                    $track->{position} = ++$track_idx;
                    my $track_ac = $track->{artist_credit} || $params->{artist_credit};
                    if ($track_ac->{names}) {
                        $track->{artist_credit}{names} = [
                            map +{
                                name => $_->{name},
                                id => $_->{artist_id},
                                join => $_->{join_phrase},
                                artist_name => $_->{artist_name},
                                gid => $_->{gid}
                            }, @{$track_ac->{names}}
                        ];

                        $track->{artist_credit}{preview} = join (
                            "", map { $_->{name} . $_->{join_phrase}
                            } @{$track_ac->{names}});
                    }

                    if (my $length = $track->{length}) {
                        $track->{length} = ($length =~ /:/)
                            ? $length
                            : format_track_length($length);
                    }

                    push @edits, $track;
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

    $params->{mediums} = [
        { position => 1 },
    ] unless @{ $params->{mediums}||[] };

    return collapse_hash($params);
};

__PACKAGE__->meta->make_immutable;
1;
