package MusicBrainz::Server::Wizard::ReleaseEditor;
use Moose;
use namespace::autoclean;

with 'MusicBrainz::Server::Wizard';

use CGI::Expand qw( expand_hash collapse_hash );
use Encode;
use JSON::Any;
use MusicBrainz::Server::Constants qw(
    $EDIT_RELEASE_ADD_ANNOTATION
    $EDIT_RELEASE_ADDRELEASELABEL
    $EDIT_RELEASE_DELETERELEASELABEL
    $EDIT_RELEASE_EDITRELEASELABEL
    $EDIT_MEDIUM_EDIT_TRACKLIST
    $EDIT_MEDIUM_CREATE
    $EDIT_MEDIUM_DELETE
    $EDIT_MEDIUM_EDIT
    $EDIT_TRACKLIST_CREATE
);
use MusicBrainz::Server::Data::Search qw( escape_query );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Track qw( unformat_track_length );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Types qw( $AUTO_EDITOR_FLAG );
use MusicBrainz::Server::Wizard;
use TryCatch;

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';
use aliased 'MusicBrainz::Server::Entity::SearchResult';
use aliased 'MusicBrainz::Server::Entity::Track';

sub _tracks_from_edits
{
    my ($self, $edits, $recording_gids, $recording_hash) = @_;

    my $json = JSON::Any->new( utf8 => 1 );

    my @ret;
    my $edited = $self->edited_tracklist ($json->decode ($edits));

    for (@$edited)
    {
        my $ac = ArtistCredit->from_array ([
            map {
                { artist => $_->{id}, name => $_->{name} },
                $_->{join}
            } grep {
                $_->{name} ne '' && $_->{id} ne ''
            } @{ $_->{artist_credit}->{names} }
        ]);

        push @ret, Track->new ({
            length => unformat_track_length ($_->{length}),
            name => $_->{name},
            position => $_->{position},
            artist_credit => $ac,
        });
    }

    return \@ret;
}

sub release_compare
{
    my ($self, $c, $data, $release) = @_;

    my %recordings;

    my @recording_gids = map {
        map { $_->{gid} } @{ $_->{associations} }
    } @{ $data->{rec_mediums} };

    my $recording_hash = { map {
        $_->gid => $_
    } values %{ $c->model('Recording')->get_by_gids (@recording_gids) } };

    my $count = 0;
    for (@{ $data->{mediums} })
    {
        next unless $_->{edits};

        my $recording_gids = $data->{rec_mediums}->[$count]->{assocations};
        $_->{tracks} = $self->_tracks_from_edits (
            $_->{edits}, $recording_gids, $recording_hash);

        $count += 1;
    }

    return $data->{mediums};
}

# this just loads the remaining bits of a release, not yet loaded by 'load'
sub _load_release
{
    my ($self, $c, $release) = @_;

    $c->model('ReleaseLabel')->load($release);
    $c->model('Label')->load(@{ $release->labels });
    $c->model('ReleaseGroupType')->load($release->release_group);
    $c->model('Release')->annotation->load_latest ($release);
}

sub _preview_edit
{
    my ($self, $c, $type, $editnote, %args) = @_;

    return unless %args;

    delete $args{as_auto_editor};

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

    my $privs = $c->user->privileges;
    if ($c->user->is_auto_editor && !$args{as_auto_editor}) {
        $privs &= ~$AUTO_EDITOR_FLAG;
    }

    delete $args{as_auto_editor};

    my $edit;
    try {
        $edit = $c->model('Edit')->create(
            edit_type => $type,
            editor_id => $c->user->id,
            privileges => $privs,
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
                    $editnote, release_label => $old_label,
                    as_auto_editor => $data->{as_auto_editor},
                );
            }
            else
            {
                # Edit ReleaseLabel
                $self->$edit($c,
                    $EDIT_RELEASE_EDITRELEASELABEL, $editnote,
                    release_label => $old_label,
                    label_id => $new_label->{label_id},
                    catalog_number => $new_label->{catalog_number},
                    as_auto_editor => $data->{as_auto_editor},
                    );
            }
        }
        elsif ($new_label->{label_id} || $new_label->{catalog_number})
        {
            # Add ReleaseLabel
            $self->$edit($c,
                $EDIT_RELEASE_ADDRELEASELABEL, $editnote,
                release_id => $release ? $release->id : 0,
                label_id => $new_label->{label_id},
                catalog_number => $new_label->{catalog_number},
                as_auto_editor => $data->{as_auto_editor},
            );
        }
    }
}

sub _tracks_to_ref
{
    my ($self, $tracklist) = @_;

    my @ret = map {
        {
            name => $_->name,
            length => $_->length,
            artist_credit => artist_credit_to_ref ($_->artist_credit),
            recording_id => $_->recording_id,
            position => $_->position,
        }
    } @$tracklist;

    return \@ret;
}

sub _edit_release_track_edits
{
    my ($self, $c, $preview, $editnote, $data, $release) = @_;

    my $edit = $preview ? '_preview_edit' : '_create_edit';

    my $mediums = $self->release_compare ($c, $data, $release);

    my $medium_idx = -1;
    for my $new (@$mediums)
    {
        $medium_idx++;

        my $tracklist_id = $new->{tracklist_id};

        # new medium which re-uses a tracklist already in the database.
        my $new_medium = $tracklist_id && ! $new->{id};

        next unless $new->{edits} || $new_medium;

        if ($tracklist_id && $new->{id})
        {
            # We already have a tracklist and a medium, so lets create a tracklist edit

            my $old = $c->model('Medium')->get_by_id ($new->{id});
            $c->model('Tracklist')->load ($old);
            $c->model('Track')->load_for_tracklists ($old->tracklist);
            $c->model('ArtistCredit')->load ($old->tracklist->all_tracks);

            $self->$edit($c,
                $EDIT_MEDIUM_EDIT_TRACKLIST,
                $editnote,
                separate_tracklists => 1,
                medium_id => $new->{id},
                tracklist_id => $new->{tracklist_id},
                old_tracklist => $self->_tracks_to_ref ($old->tracklist->tracks),
                new_tracklist => $self->_tracks_to_ref ($new->{tracks}),
                as_auto_editor => $data->{as_auto_editor},
            );
        }
        elsif (!$tracklist_id)
        {
            my $create_tl = $self->$edit(
                $c, $EDIT_TRACKLIST_CREATE, $editnote,
                tracks => $self->_tracks_to_ref ($new->{tracks}));

            $tracklist_id = $create_tl->tracklist_id || 0;
        }


        if ($new->{id})
        {
            if ($new->{deleted})
            {
                # Delete medium
                $self->$edit($c,
                    $EDIT_MEDIUM_DELETE, $editnote,
                    medium => $c->model('Medium')->get_by_id ($new->{id}),
                    as_auto_editor => $data->{as_auto_editor},
                );
            }
            else
            {
                # Edit medium
                $self->$edit($c,
                    $EDIT_MEDIUM_EDIT, $editnote,
                    name => $new->{name},
                    format_id => $new->{format_id},
                    position => $new->{position},
                    to_edit => $c->model('Medium')->get_by_id ($new->{id}),
                    as_auto_editor => $data->{as_auto_editor},
                );
            }
        }
        else
        {
            my $opts = {
                position => $medium_idx + 1,
                tracklist_id => $tracklist_id,
                release_id => $release ? $release->id : 0,
            };

            $opts->{name} = $new->{name} if $new->{name};
            $opts->{format_id} = $new->{format_id} if $new->{format_id};

            # Add medium
            my $add_medium = $self->$edit($c, $EDIT_MEDIUM_CREATE, $editnote, %$opts);

            if ($new->{position} != $medium_idx + 1)
            {
                # Disc was inserted at the wrong position, enter an edit to re-order it.
                $self->$edit($c,
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
    my ($self, $c, $preview, $editnote, $data, $release) = @_;

    my $edit = $preview ? '_preview_edit' : '_create_edit';

    my $annotation = ($release && $release->latest_annotation) ?
        $release->latest_annotation->text : '';

    my $data_annotation = $data->{annotation} ? $data->{annotation} : '';

    if ($annotation ne $data_annotation)
    {
        my $edit = $self->$edit($c,
            $EDIT_RELEASE_ADD_ANNOTATION, $editnote,
            entity_id => $release ? $release->id : 0,
            text => $data_annotation,
            as_auto_editor => $data->{as_auto_editor},
        );
    }
}

sub _build_pages {
    return [
        {
            name => 'information',
            title => l('Release Information'),
            template => 'release/edit/information.tt',
            form => 'ReleaseEditor::Information'
        },
        {
            name => 'tracklist',
            title => l('Tracklist'),
            template => 'release/edit/tracklist.tt',
            form => 'ReleaseEditor::Tracklist'
        },
        {
            name => 'recordings',
            title => l('Recordings'),
            template => 'release/edit/recordings.tt',
            form => 'ReleaseEditor::Recordings'
        },
        {
            name => 'editnote',
            title => l('Edit Note'),
            template => 'release/edit/editnote.tt',
            form => 'ReleaseEditor::EditNote'
        }
    ];
}

sub cancel { }

sub run
{
    my ($self, $c, $release) = @_;

    $self->process;

    if ($self->cancelled) {
        $self->cancel($c);
    }
    elsif ($self->current_page eq 'recordings') {
        $self->prepare_recordings($c, $self, $release);
    }
    elsif ($self->current_page eq 'editnote' || $self->submitted) {
        my $previewing = !$self->submitted;
        my $data = $self->value;
        my $editnote = $data->{editnote};
        $release = $self->create_edits($c, $data, $previewing, $editnote, $release);

        if (!$previewing) {
            $self->submit($c, $release);
        }
    }
    else {
        my $method = $self->current_page;
        $self->$method($c, $self, $release) if $self->can($method);
    }

    $self->render;
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

sub init_object
{
    my ($self, $c, $release) = @_;

    $release = inner();

    if (!$release->label_count)
    {
        $release->add_label(
            MusicBrainz::Server::Entity::ReleaseLabel->new(
                label => MusicBrainz::Server::Entity::Label->new
            )
        );
    }

    return $release;
}

sub _load_release_groups
{
    my ($self, $c, $recording) = @_;

    my ($tracks, $hits) = $c->model('Track')->find_by_recording ($recording->id, 6, 0);

    $c->model('ReleaseGroup')->load(map { $_->tracklist->medium->release } @{ $tracks });

    my @rgs = sort { $a->name cmp $b->name } map {
            $_->tracklist->medium->release->release_group
    } @{ $tracks };

    return \@rgs;
}


sub associate_recordings
{
    my ($self, $c, $edits, $tracklists) = @_;

    my @ret;
    my @recordings;

    my $count = 0;
    for (@$edits)
    {
        if ($tracklists->tracks->[$count] &&
            $_->{name} eq $tracklists->tracks->[$count]->name)
        {
            push @recordings, $tracklists->tracks->[$count]->recording_id;
            push @ret, $tracklists->tracks->[$count]->recording_id;
        }
        else
        {
            push @ret, undef;
        }

        $count += 1;
    }

    my $recordings = $c->model('Recording')->get_by_ids (@recordings);
    $c->model('ArtistCredit')->load(values %$recordings);

    $c->stash->{appears_on} = {} unless $c->stash->{appears_on};

    for (values %$recordings)
    {
        next unless $_;

        $c->stash->{appears_on}->{$_->id} = $self->_load_release_groups ($c, $_);
    }

    return map { $_ ? $recordings->{$_} : undef } @ret;
}

sub edited_tracklist
{
    my ($self, $tracks) = @_;

    return [ sort { $a->{position} > $b->{position} } grep { ! $_->{deleted} } @$tracks ];
}


sub prepare_recordings
{
    my ($self, $c, $wizard, $release) = @_;

    my $json = JSON::Any->new( utf8 => 1 );

    my @recording_gids  = @{ $wizard->value->{rec_mediums} };
    my @tracklist_edits = @{ $wizard->value->{mediums} };

    my $tracklists = $c->model('Tracklist')->get_by_ids(
        map { $_->{tracklist_id} }
        grep { defined $_->{edits} && defined $_->{tracklist_id} }
        @tracklist_edits);

    $c->model('Track')->load_for_tracklists (values %$tracklists);

    my @suggestions;

    my $count = -1;
    for (@tracklist_edits)
    {
        $count += 1;

        $_->{edits} = $self->edited_tracklist ($json->decode ($_->{edits}))
            if $_->{edits};

        # FIXME: we don't want to lose previously created associations
        # here, however... if the tracklist has been edited since making
        # these choices those associations could be wrong.  Perhaps a
        # javascript warning when going back?  For now, just wipe the
        # slate clean on loading this page.  --warp.

        $recording_gids[$count]->{tracklist_id} = $_->{tracklist_id};

        if (defined $_->{edits} && defined $_->{tracklist_id}) {
            my @recordings = $self->associate_recordings (
                $c, $_->{edits}, $tracklists->{$_->{tracklist_id}});

            $suggestions[$count] = \@recordings;

            $recording_gids[$count]->{associations} = [
                map { { 'gid' => $_ ? $_->gid : undef } } @recordings
            ];
        }
        else
        {
            $recording_gids[$count]->{associations} = [ ];
        }
    }

    $c->stash->{suggestions} = \@suggestions;
    $c->stash->{tracklist_edits} = \@tracklist_edits;

    $wizard->load_page('recordings', { 'rec_mediums' => \@recording_gids });
}

sub load_page
{
    my ($self, $step, $init_object) = @_;

    my $page = $self->page_number->{$step};
    $page = $step unless defined $page;

    return $self->_load_page ($page, $init_object);
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

    $self->_edit_release_annotation ($c, $as_previews, $edit_note, $data, $release);

    if ($as_previews) {
        $c->model ('Edit')->load_all (@{ $c->stash->{edits} });
    }
}

sub _transform_parameters {
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
            $params->{$key} = $transform->($self->c, delete $params->{$alias})->id;
        }
    }

    for my $label (@{ $params->{labels} }) {
        next unless $label->{mbid};
        my $entity = $self->c->model('Label')
            ->get_by_gid(delete $label->{mbid});
        $label->{label_id} = $entity->id;
        $label->{name} = $entity->name;
    }

    for my $artist_credit (@{ $params->{artist_credit}{names} }) {
        next unless $artist_credit->{mbid};
        my $entity = $self->c->model('Artist')
            ->get_by_gid(delete $artist_credit->{mbid});
        $artist_credit->{artist_id} = $entity->id;
        $artist_credit->{name} ||= $entity->name;
    }

    return collapse_hash($params);
}

1;
