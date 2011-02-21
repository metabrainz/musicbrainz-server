package MusicBrainz::Server::Wizard::ReleaseEditor;
use Moose;
use namespace::autoclean;

use CGI::Expand qw( collapse_hash expand_hash );
use Clone 'clone';
use JSON::Any;
use List::UtilsBy 'uniq_by';
use MusicBrainz::Server::Data::Search qw( escape_query );
use MusicBrainz::Server::Edit::Utils qw( clean_submitted_artist_credits );
use MusicBrainz::Server::Track qw( unformat_track_length format_track_length );
use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Types qw( $AUTO_EDITOR_FLAG );
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
            prepare => sub { $self->determine_missing_entities; },

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

sub _load_release_groups
{
    my ($self, $recording) = @_;

    my ($tracks, $hits) = $self->c->model('Track')->find_by_recording ($recording->id, 6, 0);

    $self->c->model('ReleaseGroup')->load(map { $_->tracklist->medium->release } @{ $tracks });

    my @rgs = sort { $a->name cmp $b->name } map {
            $_->tracklist->medium->release->release_group
    } @{ $tracks };

    return \@rgs;
}

sub associate_recordings
{
    my ($self, $edits, $tracklists) = @_;

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

    my $recordings = $self->c->model('Recording')->get_by_ids (@recordings);
    $self->c->model('ArtistCredit')->load(values %$recordings);

    $self->c->stash->{appears_on} = {} unless $self->c->stash->{appears_on};

    for (values %$recordings)
    {
        next unless $_;

        $self->c->stash->{appears_on}->{$_->id} = $self->_load_release_groups ($_);
    }

    return map { $_ ? $recordings->{$_} : undef } @ret;
}

sub prepare_tracklist
{
    my ($self, $release) = @_;

    $self->c->stash->{release_artist_json} = "null";
}

sub prepare_recordings
{
    my ($self) = @_;

    my $json = JSON::Any->new( utf8 => 1 );

    my @recording_gids  = @{ $self->value->{rec_mediums} };
    my @tracklist_edits = @{ $self->value->{mediums} };

    my $tracklists = $self->c->model('Tracklist')->get_by_ids(
        map { $_->{tracklist_id} }
        grep { defined $_->{edits} && defined $_->{tracklist_id} }
        @tracklist_edits);

    $self->c->model('Track')->load_for_tracklists (values %$tracklists);

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
                $_->{edits}, $tracklists->{$_->{tracklist_id}});

            $suggestions[$count] = \@recordings;

            $recording_gids[$count]->{associations} = [
                map { { 'gid' => ($_ ? $_->gid : "new") } } @recordings
            ];
        }
        elsif (defined $_->{edits})
        {
            $recording_gids[$count]->{associations} = [
                map { { 'gid' => 'new' } } @{ $_->{edits} }
            ];
        }
        else
        {
            $recording_gids[$count]->{associations} = [ ];
        }
    }

    $self->c->stash->{suggestions} = \@suggestions;
    $self->c->stash->{tracklist_edits} = \@tracklist_edits;

    $self->load_page('recordings', { 'rec_mediums' => \@recording_gids });
}

sub determine_missing_entities
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
            $bad_ac->{artist} = $artist->id;
            $bad_ac->{artist_id} = $artist->id;
        }

        for my $bad_label ($self->_missing_labels($data)) {
            my $label = $created{label}{ $bad_label->{name} }
                or die 'No label was created for ' . $bad_label->{name};

            $bad_label->{label_id} = $label->id;
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

    my @artist_edits = map {
        my $artist = $_;
        $create_edit->(
            $EDIT_ARTIST_CREATE,
            $editnote,
            map { $_ => $artist->{$_} } qw( name sort_name comment ));
    } @{ $data->{missing}{artist} };

    my @label_edits = map {
        my $label = $_;
        $create_edit->(
            $EDIT_LABEL_CREATE,
            $editnote,
            map { $_ => $label->{$_} } qw( name sort_name comment ));
    } @{ $data->{missing}{label} };

    return () if $previewing;
    return (
        artist => {
            map { $_->entity->name => $_->entity } @artist_edits
        },
        label => {
            map { $_->entity->name => $_->entity } @label_edits
        }
    )
}

sub _edit_release_labels
{
    my ($self, %args) = @_;
    my ($data, $create_edit, $editnote, $previewing)
        = @args{qw( data create_edit edit_note previewing )};

    my $max = scalar @{ $data->{'labels'} } - 1;

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
                $create_edit->(
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
            $create_edit->(
                $EDIT_RELEASE_ADDRELEASELABEL, $editnote,
                release_id => $previewing ? 0 : $self->release->id,
                label_id => $new_label->{label_id},
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

                if ($new->{edits}) {
                    $opts{tracklist} = $new->{tracks};
                }

                # Edit medium
                $create_edit->(
                    $EDIT_MEDIUM_EDIT, $editnote,
                    %opts
                );
            }
        }
        else
        {
            my $opts = {
                position => $medium_idx + 1,
                release_id => $previewing ? 0 : $self->release->id,
            };

            $opts->{name} = $new->{name} if $new->{name};
            $opts->{format_id} = $new->{format_id} if $new->{format_id};

            if (my $tracklist_id = $new->{tracklist_id}) {
                my $tracklist_entity = $self->c->model('Tracklist')->get_by_id($tracklist_id);
                $self->c->model('Track')->load_for_tracklists($tracklist_entity);
                $self->c->model('ArtistCredit')->load($tracklist_entity->all_tracks);
                $opts->{tracklist} = $tracklist_entity->tracks;
            } else {
                $opts->{tracklist} = $new->{tracks};
            }

            # Add medium
            my $add_medium = $create_edit->($EDIT_MEDIUM_CREATE, $editnote, %$opts);

            if ($new->{toc}) {
                $create_edit->(
                    $EDIT_MEDIUM_ADD_DISCID,
                    $editnote,
                    medium_id  => $previewing ? 0 : $add_medium->entity_id,
                    release_id => $previewing ? 0 : $self->release->id,
                    cdtoc      => $new->{toc}
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
            entity_id => $previewing ? 0 : $self->release->id,
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
        else
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

    for my $label (@{ $params->{labels} || [] }) {
        if (my $mbid = $label->{mbid}) {
            my $entity = $self->c->model('Label')
                ->get_by_gid($mbid);
            $label->{label_id} = $entity->id;
            $label->{name} = $entity->name;
        }
        elsif (my $name = $label->{name}) {
            $label->{name} = $name;
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
