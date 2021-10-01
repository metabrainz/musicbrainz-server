package MusicBrainz::Server::Edit::Medium::Edit;
use Carp;
use Clone qw( clone );
use List::AllUtils qw( any );
use Algorithm::Diff qw( sdiff );
use Text::Diff3 qw( merge );
use Data::Compare;
use Set::Scalar;
use Moose;
use MooseX::Types::Moose qw( ArrayRef Bool Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw(
    $EDIT_MEDIUM_EDIT
    $EDIT_RELEASE_CREATE
);
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Medium::Util qw(
    display_tracklist
    filter_subsecond_differences
    track
    tracks_to_hash
    tracklist_foreign_keys
);
use MusicBrainz::Server::Edit::Types qw(
    Nullable
    NullableOnPreview
);
use MusicBrainz::Server::Edit::Medium::Util qw( check_track_hash );
use MusicBrainz::Server::Edit::Utils qw( verify_artist_credits hash_artist_credit hash_artist_credit_without_join_phrases );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
use MusicBrainz::Server::Log qw( log_assertion );
use MusicBrainz::Server::Validation qw( normalise_strings );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Track qw( format_track_length );
use JSON::XS;
use Try::Tiny;

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Medium::RelatedEntities';
with 'MusicBrainz::Server::Edit::Medium';
with 'MusicBrainz::Server::Edit::Role::AllowAmending' => {
    create_edit_type => $EDIT_RELEASE_CREATE,
    entity_type => 'release',
};

use aliased 'MusicBrainz::Server::Entity::Medium';
use aliased 'MusicBrainz::Server::Entity::Release';

sub edit_type { $EDIT_MEDIUM_EDIT }
sub edit_name { N_l('Edit medium') }
sub edit_kind { 'edit' }
sub _edit_model { 'Medium' }
sub edit_template_react { 'EditMedium' }

sub entity_id { shift->data->{entity_id} }
sub medium_id { shift->entity_id }
sub release_id { shift->data->{release}{id} }

has '+data' => (
    isa => Dict[
        entity_id => NullableOnPreview[Int],
        release => Dict[
            id => Int,
            name => Str
        ],
        separate_tracklists => Optional[Bool],
        current_tracklist => Optional[Int],
        old => change_fields(),
        new => change_fields()
    ]
);

around _build_related_entities => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my $related = $self->$orig(@_);

    if ($self->data->{old}{tracklist}) {
        my @changes =
            grep { $_->[0] ne 'u' }
            @{ sdiff(
                $self->data->{old}{tracklist},
                $self->data->{new}{tracklist},
                sub {
                    my $track = shift;
                    join(':',
                         $track->{name},
                         $track->{length} || '?:??',
                         $track->{recording_id} // 0,
                         $track->{position},
                         join('', map {
                             $_->{artist}{id}, $_->{name}, $_->{join_phrase} || ''
                             } @{$track->{artist_credit}{names}})
                     )
                })
           };

        push @{ $related->{artist} },
            map {
                my ($type, $oldt, $newt) = @$_;
                map {
                    map { $_->{artist}{id} } @{ $_->{artist_credit}{names} }
                } $type eq 'c' ? ($newt, $oldt)
                : $type eq '+' ? ($newt)
                :                ($oldt)
            } @changes;

        push @{ $related->{recording} },
            grep { defined }
            map {
                my ($type, $oldt, $newt) = @$_;
                map { $_->{recording_id} }
                $type eq 'c' ? ($newt, $oldt) :
                $type eq '+' ? ($newt)
                             : ($oldt)
            } @changes;
    }

    return $related;
};

sub alter_edit_pending
{
    my $self = shift;
    return {
        'Medium' => [ $self->entity_id ],
        'Release' => [ $self->data->{release}->{id} ]
    }
}

sub change_fields
{
    return Dict[
        position => Optional[Int],
        name => Optional[Str],
        format_id => Nullable[Int],
        tracklist => Optional[ArrayRef[track()]],
    ];
}

sub initialize
{
    my ($self, %opts) = @_;

    my $entity = delete $opts{to_edit};

    my $tracklist = delete $opts{tracklist};
    my $delete_tracklist = delete $opts{delete_tracklist};
    my $data;

    $self->check_tracks_against_format($tracklist, $opts{format_id});

    # FIXME: really should receive an entity on preview too.
    if ($self->preview && !defined $entity)
    {
        # This currently only happens when a new medium just created with
        # an Add Medium edit needs to immediatly get an edit to change
        # position.
        $data->{old}{position} = 0;
        $data->{new}{position} = delete $opts{position};
    }
    else
    {
        die 'You must specify the object to edit' unless defined $entity;

        unless ($entity->release) {
            $self->c->model('Release')->load($entity);
        }

        $data = {
            entity_id => $entity->id,
            release => {
                id => $entity->release->id,
                name => $entity->release->name
            },
            $self->_changes($entity, %opts)
        };

        if ($tracklist && @$tracklist) {
            $self->c->model('Track')->load_for_mediums($entity);
            $self->c->model('ArtistCredit')->load($entity->all_tracks);

            my $old = tracks_to_hash($entity->tracks);
            my $new = tracks_to_hash($tracklist);

            unless (Compare(filter_subsecond_differences($old),
                            filter_subsecond_differences($new)))
            {
                check_track_hash($new);
                my $id_set = sub {
                    Set::Scalar->new(grep { defined $_ } map { $_->{id} } @_)
                };
                die 'New tracklist uses track IDs not in the old tracklist'
                    unless $id_set->(@$new) <= $id_set->(@$old);

                $data->{old}{tracklist} = $old;
                $data->{new}{tracklist} = $new;
            }
        } elsif ($tracklist && $delete_tracklist) {
            $self->c->model('Track')->load_for_mediums($entity);
            $self->c->model('ArtistCredit')->load($entity->all_tracks);

            $data->{old}{tracklist} = tracks_to_hash($entity->tracks);
            $data->{new}{tracklist} = [];
        }

        MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
            if Compare($data->{old}, $data->{new});
    }

    $self->data($data);
}

sub foreign_keys {
    my $self = shift;
    my %fk = (
        Release => { $self->data->{release}{id} => [ 'ArtistCredit' ] },
        Medium => { $self->data->{entity_id} => [ 'Release ArtistCredit', 'MediumFormat' ] },
    );

    $fk{MediumFormat} = {};

    $fk{MediumFormat}->{$self->data->{old}{format_id}} = []
        if defined $self->data->{old}{format_id};

    $fk{MediumFormat}->{$self->data->{new}{format_id}} = []
        if defined $self->data->{new}{format_id};

    my @tracks;
    push @tracks, @{ $self->data->{old}{tracklist} }
        if exists $self->data->{old}{tracklist};
    push @tracks, @{ $self->data->{new}{tracklist} }
        if exists $self->data->{new}{tracklist};

    tracklist_foreign_keys(\%fk, \@tracks);

    return \%fk;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $data = { };

    my $release = $loaded->{Release}{ $self->data->{release}{id} } //
                  Release->new(
                      id => $self->data->{release}{id},
                      name => $self->data->{release}{name},
                  );

    $data->{medium} = to_json_object(
        $loaded->{Medium}{ $self->data->{entity_id} } //
        Medium->new(
            release_id => $self->data->{release}{id},
            release => $release,
        )
    );

    if (exists $self->data->{new}{format_id}) {
        $data->{format} = {
            new => defined($self->data->{new}{format_id}) &&
                     to_json_object($loaded->{MediumFormat}{ $self->data->{new}{format_id} }),
            old => defined($self->data->{old}{format_id}) &&
                     to_json_object($loaded->{MediumFormat}{ $self->data->{old}{format_id} }),
        };
    }

    for my $attribute (qw( name position )) {
        if (exists $self->data->{new}{$attribute}) {
            $data->{$attribute} = {
                new => $self->data->{new}{$attribute},
                old => $self->data->{old}{$attribute},
            };
        }
    }

    if ($self->data->{new}{tracklist}) {
        my $new_tracklist = display_tracklist($loaded, $self->data->{new}{tracklist});
        my $old_tracklist = display_tracklist($loaded, $self->data->{old}{tracklist});

        $data->{new}{tracklist} = to_json_array($new_tracklist);
        $data->{old}{tracklist} = to_json_array($old_tracklist);

        my $tracklist_changes = [
            @{ sdiff(
                $old_tracklist,
                $new_tracklist,
                sub {
                    my $track = shift;
                    return join(
                        '',
                        $track->id // 0,
                        $track->name // '',
                        format_track_length($track->length),
                        join(
                            '',
                            map {
                                join('', $_->name, $_->join_phrase // '')
                            } $track->artist_credit->all_names
                        ),
                        $track->is_data_track ? 1 : 0,
                        $track->position ? 1 : 0,
                    );
                }
            ) }
        ];

        my $i = 0;
        while ($i < scalar(@$tracklist_changes)) {
            my $change = $tracklist_changes->[$i];
            my ($old, $new) = @$change[1, 2];

            if ($change->[0] eq 'c' && ($old->id // 0) != ($new->id // 0)) {
                splice @$tracklist_changes, $i, 1, ['-', $old, ''], ['+', '', $new];
                $i++;
            }
            $i++;
        }

        if (any {$_->[0] ne 'u' || $_->[1]->number ne $_->[2]->number } @$tracklist_changes) {
            my @mapped_tracklist_changes = map +{
                change_type => $_->[0],
                old_track => $_->[1] eq '' ? undef : to_json_object($_->[1]),
                new_track => $_->[2] eq '' ? undef : to_json_object($_->[2]),
            }, @$tracklist_changes;
            $data->{tracklist_changes} = \@mapped_tracklist_changes;
        }

        # Edits that predate track mbids do not store track ids at all.
        my @changes_with_track_ids = grep { $_->[1] && $_->[1]->id } @$tracklist_changes;

        if (scalar(@changes_with_track_ids) && any { $_->[2] && !$_->[2]->id } @$tracklist_changes) {
            $data->{changed_mbids} = 1;
        }

        $data->{artist_credit_changes} = [
            map +{
                change_type => $_->[0],
                old_track => $_->[1] eq '' ? undef : to_json_object($_->[1]),
                new_track => to_json_object($_->[2]),
            },
            grep {
                ($_->[1] && hash_artist_credit_without_join_phrases($_->[1]->artist_credit))
                    ne
                ($_->[2] && hash_artist_credit_without_join_phrases($_->[2]->artist_credit))
            }
            grep { $_->[0] ne '-' }
            @$tracklist_changes ];


        # Generate a map of track id => old recording id, for edits that store
        # track ids, to detect if recordings have changed.

        my %old_recordings = map {
                $_->[1]->id => $_->[1]->recording_id // $_->[1]->recording->id
            }
            @changes_with_track_ids;

        $data->{recording_changes} = [
            map +{
                change_type => $_->[0],
                old_track => $_->[1] eq '' ? undef : to_json_object($_->[1]),
                new_track => to_json_object($_->[2]),
            },
            grep {
                my $old = $_->[1];
                my $new = $_->[2];
                my $old_recording = $old ? ($old->recording_id // $old->recording->id // 0) : 0;
                my $new_recording = $new ? ($new->recording_id // $new->recording->id // 0) : 0;

                $new && ($new->id ? $old_recordings{$new->id} : $old_recording) != $new_recording;
            }
            @$tracklist_changes ];

        $data->{data_track_changes} = any {
            ($_->[1] ? $_->[1]->{is_data_track} // 0 : 0) !=
            ($_->[2] ? $_->[2]->{is_data_track} // 0 : 0)
        } @$tracklist_changes;
    }

    return $data;
}

my $UNDEF_MARKER = time();
sub track_column {
    my ($column, $tracklist, $key_generation) = @_;

    [ map {
        my $value = $_->{$column};
        ($key_generation ? $key_generation->($value) : $value) // $UNDEF_MARKER
    } @$tracklist ];
}

sub accept {
    my $self = shift;

    if (!$self->c->model('Medium')->get_by_id($self->entity_id)) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This edit cannot be applied, as the medium being edited no longer exists.'
        )
    }

    my $data_new = clone($self->data->{new});
    my $data_new_tracklist = delete $data_new->{tracklist};

    $self->c->model('Medium')->update($self->entity_id, $data_new);

    if ($data_new_tracklist) {
        my $medium = $self->c->model('Medium')->get_by_id($self->medium_id);
        $self->c->model('MediumFormat')->load($medium);
        $self->c->model('Track')->load_for_mediums($medium);
        $self->c->model('ArtistCredit')->load($medium->all_tracks);

        # Make sure we aren't using undef for recording_id or is_data_track, as it will merge incorrectly
        for (@$data_new_tracklist) {
            $_->{recording_id} //= 0;
            $_->{is_data_track} //= 0;
        }

        my (@merged_row_ids, @merged_numbers, @merged_names, @merged_recordings,
            @merged_lengths, @merged_artist_credits, @merged_is_data_tracks);

        my %hashed_artist_credits;
        my $hash_artist_credit = sub {
            my ($artist_credit) = @_;

            my $hash = hash_artist_credit($artist_credit);
            $hashed_artist_credits{$hash} = $artist_credit;
            $hash;
        };

        my $current_tracklist = tracks_to_hash($medium->tracks);
        try {
            for my $merge (
                [ id => \@merged_row_ids ],
                [ number => \@merged_numbers ],
                [ name => \@merged_names ],
                [ recording_id => \@merged_recordings ],
                [ length => \@merged_lengths ],
                [ artist_credit => \@merged_artist_credits, $hash_artist_credit ],
                [ is_data_track => \@merged_is_data_tracks ]
            ) {
                my ($property, $container, $key_generation) = @$merge;
                my $merged = merge(
                    track_column($property, $data_new_tracklist, $key_generation),
                    track_column($property, $self->data->{old}{tracklist}, $key_generation),
                    track_column($property, $current_tracklist, $key_generation),
                );
                die if $merged->{conflict};
                push @$container, @{ $merged->{body} };
            }
        }
        catch {
            MusicBrainz::Server::Edit::Exceptions::FailedDependency
                  ->throw('The tracklist has changed since this edit was created, and conflicts ' .
                      'with changes made in this edit');
        };

        log_assertion {
            @merged_row_ids == @merged_numbers &&
            @merged_numbers == @merged_names &&
            @merged_names == @merged_recordings &&
            @merged_recordings == @merged_lengths &&
            @merged_lengths == @merged_artist_credits &&
            @merged_artist_credits == @merged_is_data_tracks
        } 'Merged properties are all the same length';

        # Create the final merged tracklist

        # Check for a pregap track. The medium must support disc ids, and the
        # first track must have position 0.
        my $position = 1;

        if ($medium->may_have_discids) {
            my @new_tracks = @$data_new_tracklist;
            if (@new_tracks) {
                my $first_position = $new_tracks[0]->{position};
                if (defined($first_position) && $first_position == 0) {
                    $position = 0;
                }
            }
        }

        my @final_tracklist;
        my $existing_recordings = $self->c->sql->select_single_column_array(
            'SELECT id FROM recording WHERE id = any(?)', \@merged_recordings
        );
        my %existing_recordings = map { $_ => 1 } @$existing_recordings;
        while (1) {
            last unless @merged_row_ids &&
                        @merged_artist_credits &&
                        @merged_lengths &&
                        @merged_recordings &&
                        @merged_names &&
                        @merged_numbers &&
                        @merged_is_data_tracks;

            my $track_id = shift(@merged_row_ids);
            my $length = shift(@merged_lengths);
            my $number = shift(@merged_numbers);
            my $recording_id = shift(@merged_recordings);
            my $is_data_track = shift(@merged_is_data_tracks);

            if (defined($recording_id) && $recording_id > 0 && !$existing_recordings{$recording_id}) {
                MusicBrainz::Server::Edit::Exceptions::FailedDependency
                  ->throw('This edit changes recording IDs, but some of the recordings no longer exist.');
            }

            push @final_tracklist, {
                id => $track_id eq $UNDEF_MARKER ? undef : $track_id,
                name => shift(@merged_names),
                position => $position++,
                medium_id => $self->entity_id,
                number => $number eq $UNDEF_MARKER ? undef : $number,
                length => $length eq $UNDEF_MARKER ? undef : $length,
                recording_id => $recording_id,
                artist_credit => $hashed_artist_credits{shift(@merged_artist_credits)},
                is_data_track => $is_data_track
            }
        }

        verify_artist_credits($self->c, map {
            $_->{artist_credit}
        } @final_tracklist);

        # Wait until commit before checking (medium, position) uniqueness,
        # after all tracks are in their final places.
        $self->c->sql->do('SET CONSTRAINTS track_uniq_medium_position DEFERRED');

        # Create tracks and recordings
        my %tracks_reused;
        for my $track (@final_tracklist) {
            $track->{artist_credit_id} = $self->c->model('ArtistCredit')->find_or_insert(
                $track->{artist_credit});

            if (!$track->{recording_id}) {
                $track->{recording_id} = $self->c->model('Recording')->insert({
                    %$track, artist_credit => $track->{artist_credit_id} })->{id};

                # We are in the processing of closing this edit. The edit exists, so we need to add a new link
                $self->c->model('Edit')->add_link('recording', $track->{recording_id}, $self->id);
            }

            if ($track->{id})
            {
                $self->c->model('Track')->update($track->{id}, $track);
                $tracks_reused{$track->{id}} = 1;
            }
            else
            {
                $self->c->model('Track')->insert($track);
            }

            # Remove stuff not expected on the edit data
            delete $track->{artist_credit_id};
            delete $track->{medium_id};
        }

        for my $old_track ($medium->all_tracks)
        {
            $self->c->model('Track')->delete($old_track->id)
                unless $tracks_reused{$old_track->id}
        }

        # We add the final tracklist, with created recordings, to the edit data
        $self->data->{new}{tracklist} = \@final_tracklist;
        my $json = JSON::XS->new;
        $self->c->sql->update_row('edit_data', { data => $json->encode($self->to_hash) }, { edit => $self->id });
    }
}

sub allow_auto_edit
{
    my $self = shift;

    return 1 if $self->can_amend($self->release_id);

    my ($old_name, $new_name) = normalise_strings($self->data->{old}{name},
                                                  $self->data->{new}{name});

    return 0 if $self->data->{old}{name} && $old_name ne $new_name;
    return 0 if $self->data->{old}{format_id};
    return 0 if exists $self->data->{old}{position};

    if ($self->data->{old}{tracklist}) {
        # If there's no old tracklist, allow adding one as an autoedit 
        return 1 if scalar @{ $self->data->{old}{tracklist} } == 0;

        my @changes =
            grep { $_->[0] ne 'u' }
            @{ sdiff(
                $self->{data}{old}{tracklist},
                $self->{data}{new}{tracklist},
                sub {
                    my $track = shift;
                    return join(
                        '',
                        $track->{name},
                        format_track_length($track->{length}),
                        hash_artist_credit($track->{artist_credit}),
                        $track->{recording_id} // 'new'
                    );
                }
            ) };

        # If this edit adds or removes tracks, it's not an auto-edit
        return 0 if (any { $_->[0] ne 'c' } @changes);

        for my $change (@changes) {
            my (undef, $old, $new) = @$change;

            ($old_name, $new_name) = normalise_strings($old->{name},
                                                       $new->{name});

            return 0 if $old_name ne $new_name;
            return 0 if $old->{length} && $old->{length} != $new->{length};
            return 0 if hash_artist_credit($old->{artist_credit}) ne hash_artist_credit($new->{artist_credit});
            return 0 if ($old->{recording_id} // 0) != ($new->{recording_id} // 0);
        }
    }

    return 1;
}

sub artist_ids
{
    my $self = shift;

    return map { $_->{artist} }
        grep { ref($_) } map { @{ $_->{artist_credit} } }
        @{ $self->data->{new}{tracklist} },
        @{ $self->data->{old}{tracklist} }
}

sub recording_ids
{
    my $self = shift;
    grep { defined }
        map { $_->{recording_id} }
        @{ $self->data->{new}{tracklist} },
        @{ $self->data->{old}{tracklist} }
}

before restore => sub {
    my ($self, $data) = @_;
    if (exists $data->{new}{name}) {
        $data->{new}{name} //= '';
        $data->{old}{name} //= '';
    }

    # Some old edits have undef join phrases. Two loops and checks to avoid
    # autovivification causing weird issues.
    if (exists $data->{new}{tracklist}) {
        for my $new_track (@{ $data->{new}{tracklist} }) {
            for my $artist_credit_name (@{ $new_track->{artist_credit}{names} }) {
                $artist_credit_name->{join_phrase} //= '';
            }
        }
    }

    if (exists $data->{old}{tracklist}) {
        for my $old_track (@{ $data->{old}{tracklist} }) {
            for my $artist_credit_name (@{ $old_track->{artist_credit}{names} }) {
                $artist_credit_name->{join_phrase} //= '';
            }
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
