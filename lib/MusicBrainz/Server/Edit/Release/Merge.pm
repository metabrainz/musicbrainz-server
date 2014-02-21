package MusicBrainz::Server::Edit::Release::Merge;
use Moose;

use List::AllUtils qw( any );
use MusicBrainz::Server::Constants qw( $EDIT_RELEASE_MERGE );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash ArtistCreditDefinition );
use MusicBrainz::Server::Translation qw ( N_l );
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
                    old_name => Nullable[Str],
                    new_name => Nullable[Str],
                ]]
            ]]]
    ]
);

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
        Artist => [ map { $_->{artist}{id} } map { @{ $_->{artist_credit}{names} // [] } } @{ $self->data->{old_entities} }, $self->data->{new_entity} ]
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
                    format => MediumFormat->new( name => $_->{format_name})
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
                         Label->new(name => $_->{label}{name})),
                    catalog_number => $_->{catalog_number}
                ) } @{ delete $entity->{labels} }] if $entity->{labels};
            $entity->{artist_credit} = ArtistCredit->from_array($entity->{artist_credit}->{names}) if $entity->{artist_credit};
            $self->c->model('Artist')->load(@{ $entity->{artist_credit}{names} });
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
    } elsif ($self->data->{merge_strategy} == $MusicBrainz::Server::Data::Release::MERGE_MERGE) {
        $self->c->model('Track')->load_for_mediums(
            map { $_->all_mediums }
            values %{ $loaded->{Release} }
        );

        $self->c->model('Recording')->load(
            map { $_->all_tracks }
            map { $_->all_mediums }
            values %{ $loaded->{Release} }
        );

        my $recording_merges = [];
        for my $medium ($data->{new}->all_mediums) {
            for my $track ($medium->all_tracks) {
                try {
                    my @sources;
                    for my $source_medium (map { $_->all_mediums } @{ $data->{old} }) {
                        if ($source_medium->position == $medium->position) {
                            push @sources, map { $_->recording }
                                grep { $_->position == $track->position } $source_medium->all_tracks;
                        }
                    }
                    @sources = grep { $_->id != $track->recording->id } @sources;
                    push(@$recording_merges, {
                             medium => $medium->position,
                             track => $track->number,
                             sources => \@sources,
                             destination => $track->recording}) if scalar @sources;
                };
            }
        }
        $data->{recording_merges} = $recording_merges;
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

    my %opts = (
        new_id => $self->new_entity->{id},
        old_ids => [ $self->_old_ids ],
        merge_strategy => $self->data->{merge_strategy},
        medium_positions => {
            map { $_->{id} => $_->{new_position} }
            map { @{ $_->{mediums} } }
            @{ $self->data->{medium_changes} }
        },
        medium_names => $medium_names
    );

    if (!$self->c->model('Release')->can_merge(%opts)) {
        my $message = 'These releases could not be merged';
        if ($self->data->{merge_strategy} == $MusicBrainz::Server::Data::Release::MERGE_MERGE) {
            $message .= ' because the track counts on at least one set of corresponding mediums did not match.';
        } elsif ($self->data->{merge_strategy} == $MusicBrainz::Server::Data::Release::MERGE_APPEND) {
            $message .= ' because medium positions conflicted.';
        }
        MusicBrainz::Server::Edit::Exceptions::GeneralError->throw($message);
    }

    $self->c->model('Release')->merge(%opts);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
