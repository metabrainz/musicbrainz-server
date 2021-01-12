package MusicBrainz::Server::Edit::Release::Merge;

use 5.18.2;

use Moose;
use List::AllUtils qw( any );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MERGE );
use MusicBrainz::Server::Data::Utils qw( localized_note );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw(
    ArtistCreditDefinition
    Nullable
    PartialDateHash
    RecordingMergesArray
);
use MusicBrainz::Server::Edit::Utils qw( large_spread );
use MusicBrainz::Server::Translation qw( N_l );
use Try::Tiny;

use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict Map Optional );

extends 'MusicBrainz::Server::Edit::Generic::Merge';
with 'MusicBrainz::Server::Edit::Release::RelatedEntities' => {
    -excludes => 'release_ids'
};
with 'MusicBrainz::Server::Edit::Release';

use aliased 'MusicBrainz::Server::Entity::Release';
use aliased 'MusicBrainz::Server::Entity::Medium';
use aliased 'MusicBrainz::Server::Entity::MediumFormat';

use aliased 'MusicBrainz::Server::Entity::ReleaseEvent';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

use aliased 'MusicBrainz::Server::Entity::ReleaseLabel';
use aliased 'MusicBrainz::Server::Entity::Label';

use aliased 'MusicBrainz::Server::Entity::ArtistCredit';

use aliased 'MusicBrainz::Server::Entity::Recording';

has '+data' => (
    isa => Dict[
        new_entity => Dict[
            id   => Int,
            name => Str,
            barcode => Optional[Str],
            events => Optional[ArrayRef[Dict[
                date => Nullable[PartialDateHash],
                country_id => Nullable[Int],
            ]]],
            mediums => Optional[ArrayRef[Dict[
                track_count => Int,
                format_name => Nullable[Str]
            ]]],
            labels => Optional[ArrayRef[Dict[
                label => Nullable[Dict[
                    id => Int,
                    name => Str
                ]],
                catalog_number => Nullable[Str]
            ]]],
            artist_credit => Optional[ArtistCreditDefinition]
        ],
        old_entities => ArrayRef[ Dict[
            name => Str,
            id   => Int,
            barcode => Optional[Str],
            events => Optional[ArrayRef[Dict[
                date => Nullable[PartialDateHash],
                country_id => Nullable[Int],
            ]]],
            mediums => Optional[ArrayRef[Dict[
                track_count => Int,
                format_name => Nullable[Str]
            ]]],
            labels => Optional[ArrayRef[Dict[
                label => Nullable[Dict[
                    id => Int,
                    name => Str
                ]],
                catalog_number => Nullable[Str]
            ]]],
            artist_credit => Optional[ArtistCreditDefinition]
        ] ],
        merge_strategy => Int,
        _edit_version => Int,
        medium_changes => Nullable[
            ArrayRef[Dict[
                release => Dict[
                    id => Int,
                    name => Str
                ],
                mediums => ArrayRef[Dict[
                    id           => Int,
                    old_position => Str | Int,
                    new_position => Int,
                    old_name => Str,
                    new_name => Str,
                ]]
            ]]],
        recording_merges => Nullable[RecordingMergesArray],
    ]
);

has recording_merges => (
    is => 'ro',
    isa => Nullable[RecordingMergesArray],
    lazy => 1,
    builder => '_build_recording_merges',
);

has cannot_merge_recordings_reason => (
    is => 'rw',
    isa => 'Maybe[HashRef]',
);

sub _build_recording_merges {
    my $self = shift;

    $self->cannot_merge_recordings_reason(undef);

    if ($self->is_open) {
        my ($can_merge, $result) = $self->c->model('Release')->determine_recording_merges(
            $self->data->{new_entity}{id},
            map { $_->{id} } @{$self->data->{old_entities}},
        );
        if ($can_merge) {
            return $result;
        }
        $self->cannot_merge_recordings_reason($result);
        return [];
    }

    return $self->data->{recording_merges};
}

sub edit_name { N_l('Merge releases') }
sub edit_type { $EDIT_RELEASE_MERGE }
sub _merge_model { 'Release' }

sub release_ids { @{ shift->_entity_ids } }

sub related_recordings
{
    my ($self, $releases) = @_;

    if ($self->data->{merge_strategy} == $MusicBrainz::Server::Data::Release::MERGE_MERGE) {
        my @tracks;
        $self->c->model('Medium')->load_for_releases(@$releases);
        my @mediums = map { $_->all_mediums } @$releases;
        $self->c->model('Track')->load_for_mediums(@mediums);
        @tracks = map { $_->all_tracks } @mediums;
        return $self->c->model('Recording')->load(@tracks);
    } else {
        return ();
    }
}

sub foreign_keys
{
    my $self = shift;

    return {
        Release => {
            map { $_ => [ 'ArtistCredit', 'ReleaseLabel' ] }
                $self->data->{new_entity}{id},
                (map { $_->{id} } @{ $self->data->{old_entities} })
        },
        Area => [ map { $_->{country_id} } map { @{ $_->{events} // [] } } @{ $self->data->{old_entities} }, $self->data->{new_entity} ],
        Label => [ map { $_->{label}{id} } map { @{ $_->{labels} // [] } } @{ $self->data->{old_entities} }, $self->data->{new_entity} ],
        Artist => [ map { $_->{artist}{id} } map { @{ $_->{artist_credit}{names} // [] } } @{ $self->data->{old_entities} }, $self->data->{new_entity} ],
        Recording => { map { $_->{id} => [ 'ArtistCredit' ] } map { $_->{destination}, @{ $_->{sources} } } @{ $self->recording_merges // [] } },
    };
}

sub initialize {
    my ($self, %opts) = @_;
    $opts{_edit_version} = 3;
    $self->data(\%opts);
}

override build_display_data => sub
{
    my ($self, $loaded) = @_;

    for my $entity ($self->new_entity, @{ $self->{data}{old_entities} }) {
        if (!defined $loaded->{Release}->{ $entity->{id} }) {
            $entity->{mediums} = [map { Medium->new(
                    track_count => $_->{track_count},
                    format => ($_->{format_name} ? MediumFormat->new( name => $_->{format_name}) : undef)
                ) } @{ delete $entity->{mediums} }] if $entity->{mediums};
            $entity->{events} = [map { ReleaseEvent->new(
                    country => defined($_->{country_id})
                        ? $loaded->{Area}{ $_->{country_id} }
                        : undef,
                    date => PartialDate->new({
                        year => $_->{date}{year},
                        month => $_->{date}{month},
                        day => $_->{date}{day}
                    })
                ) } @{ delete $entity->{events} }] if $entity->{events};
            $entity->{labels} = [map { ReleaseLabel->new(
                    label => $_->{label} &&
                        ($loaded->{Label}->{$_->{label}{id}} //
                         ($_->{label}{name} ? Label->new(name => $_->{label}{name}) : undef)),
                    catalog_number => $_->{catalog_number}
                ) } @{ delete $entity->{labels} }] if $entity->{labels};
            $entity->{artist_credit} = ArtistCredit->from_array(
                [map { my $name = $_;
                       $name->{artist} = $loaded->{Artist}->{$_->{artist}->{id}} // $_->{artist};
                       $name } @{ $entity->{artist_credit}{names} }]
            ) if $entity->{artist_credit};
        }
    }

    my $data = super();

    $self->c->model('Label')->load(
        grep { $_->label_id && !defined($_->label) }
        map { $_->all_labels }
        values %{ $loaded->{Release} }
    );

    $self->c->model('Medium')->load_for_releases(
        grep { $_->medium_count < 1 }
        values %{ $loaded->{Release} }
    );

    $self->c->model('MediumFormat')->load(
        grep { $_->format_id && !defined($_->format) }
        map { $_->all_mediums }
        values %{ $loaded->{Release} }
    );

    $self->c->model('Release')->load_release_events(
        values %{ $loaded->{Release} }
    );

    if ($self->data->{merge_strategy} == $MusicBrainz::Server::Data::Release::MERGE_APPEND) {
        $data->{changes} = [
            map +{
                release => $loaded->{Release}{ $_->{release}{id} }
                    || Release->new( name => $_->{release}{name} ),
                mediums => $_->{mediums}
            }, @{ $self->data->{medium_changes} }
        ];
        $data->{empty_releases} = [
            map +{
                release => $loaded->{Release}{ $_->{id} } // Release->new(name => $_->{name}),
            }, grep { defined $_->{mediums} && scalar @{ $_->{mediums} } == 0 } @{ $self->data->{old_entities} }
        ];
    } elsif ($self->data->{merge_strategy} == $MusicBrainz::Server::Data::Release::MERGE_MERGE) {
        my $recording_merges = $self->recording_merges;

        $data->{recording_merges} = [map {
            my $destination = $loaded->{Recording}{$_->{destination}{id}} // Recording->new(
                name => $_->{destination}{name},
                length => $_->{destination}{length},
            );
            my $sources = [map {
                $loaded->{Recording}{$_->{id}} // Recording->new(
                    name => $_->{name},
                    length => $_->{length},
                )
            } @{$_->{sources}}];
            {
                medium => $_->{medium},
                track => $_->{track},
                destination => $destination,
                sources => $sources,
                large_spread => (large_spread(map { $_->length } $destination, @{$sources}) ? 1 : 0),
            }
        } @{$recording_merges}] if defined $recording_merges;
    }

    return $data;
};

sub do_merge
{
    my $self = shift;
    my $medium_names;
    if ($self->data->{_edit_version} > 2) {
        $medium_names = {
            map { $_->{id} => $_->{new_name} }
            map { @{ $_->{mediums} } }
            @{ $self->data->{medium_changes} }
        };
    }

    my $merge_strategy = $self->data->{merge_strategy};

    my %opts = (
        new_id => $self->new_entity->{id},
        old_ids => [ $self->_old_ids ],
        merge_strategy => $merge_strategy,
        medium_positions => {
            map { $_->{id} => $_->{new_position} }
            map { @{ $_->{mediums} } }
            @{ $self->data->{medium_changes} }
        },
        medium_names => $medium_names
    );

    my ($can_merge, $cannot_merge_reason) = $self->c->model('Release')->can_merge(\%opts);

    my $recording_merges;
    if ($can_merge && $merge_strategy == $MusicBrainz::Server::Data::Release::MERGE_MERGE) {
        $recording_merges = $self->recording_merges;

        $cannot_merge_reason = $self->cannot_merge_recordings_reason;
        $can_merge = $cannot_merge_reason ? 0 : 1;

        if ($can_merge) {
            $self->data->{recording_merges} = $recording_merges;
            $opts{recording_merges} = $recording_merges;
        }
    }

    unless ($can_merge) {
        my $error = localized_note(
            N_l('These releases could not be merged: {reason}'),
            vars => {
                reason => localized_note(
                    $cannot_merge_reason->{message},
                    vars => $cannot_merge_reason->{vars},
                ),
            },
        );
        MusicBrainz::Server::Edit::Exceptions::GeneralError->throw($error);
    }

    $self->c->model('Release')->merge(%opts);

    if (defined $recording_merges) {
        state $json = JSON::XS->new;
        $self->c->sql->update_row('edit_data', {
            data => $json->encode($self->to_hash),
        }, { edit => $self->id });
    }
};

before restore => sub {
    my ($self, $data) = @_;

    if (defined $data->{medium_changes}) {
        for my $release (@{ $data->{medium_changes} }) {
            for my $medium (@{ $release->{mediums} }) {
                $medium->{old_name} //= '';
                $medium->{new_name} //= '';
            }
        }
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
