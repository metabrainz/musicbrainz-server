package MusicBrainz::Server::Edit::Medium::Edit;
use Carp;
use Clone 'clone';
use Data::Compare;
use Moose;
use MooseX::Types::Moose qw( ArrayRef Bool Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_EDIT );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Edit::Types qw(
    ArtistCreditDefinition
    Nullable
    NullableOnPreview
);
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
);
use MusicBrainz::Server::Validation 'normalise_strings';
use MusicBrainz::Server::Track qw( unformat_track_length format_track_length );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Medium::RelatedEntities';

sub edit_type { $EDIT_MEDIUM_EDIT }
sub edit_name { l('Edit medium') }
sub _edit_model { 'Medium' }
sub medium_id { shift->data->{entity_id} }

has '+data' => (
    isa => Dict[
        entity_id => NullableOnPreview[Int],
        separate_tracklists => Optional[Bool],
        old => change_fields(),
        new => change_fields()
    ]
);

sub change_fields
{
    return Dict[
        position => Optional[Int],
        name => Nullable[Str],
        format_id => Nullable[Int],
        tracklist => ArrayRef[track()],
    ];
}

sub track {
    return Dict[
        name => Str,
        artist_credit => ArtistCreditDefinition,
        length => Nullable[Int],
        recording_id => NullableOnPreview[Int],
    ];
}

sub _tracks_to_hash
{
    my $tracks = shift;
    return [ map +{
        name => $_->name,
        artist_credit => artist_credit_to_ref ($_->artist_credit),
        recording_id => $_->recording_id,

        # Filter out sub-second differences
        length => unformat_track_length(format_track_length($_->length)),
    }, @$tracks ];
}

sub initialize
{
    my ($self, %opts) = @_;

    my $entity = delete $opts{to_edit};
    my $tracklist = delete $opts{tracklist};
    my $separate_tracklists = delete $opts{separate_tracklists};
    die "You must specify the object to edit" unless defined $entity;

    my $data = {
        entity_id => $entity->id,
        $self->_changes($entity, %opts)
    };

    if ($tracklist) {
        $self->c->model('Tracklist')->load ($entity);
        $self->c->model('Track')->load_for_tracklists ($entity->tracklist);
        $self->c->model('ArtistCredit')->load ($entity->tracklist->all_tracks);

        $data->{old}{tracklist} = _tracks_to_hash($entity->tracklist->tracks);
        $data->{new}{tracklist} = _tracks_to_hash($tracklist);
        $data->{separate_tracklists} = $separate_tracklists;
    }

    MusicBrainz::Server::Edit::Exceptions::NoChanges->throw
          if Compare($data->{old}, $data->{new});


    $self->data($data);
}

sub foreign_keys {
    my $self = shift;
    my %fk;
    if (exists $self->data->{new}{format_id}) {
        $fk{MediumFormat} = {
            $self->data->{new}{format_id} => [],
            $self->data->{old}{format_id} => [],
        }
    }

    $fk{Artist} = {
        map {
            load_artist_credit_definitions($_->{artist_credit})
        } map { @{ $self->data->{$_}{tracklist} } }
            qw( old new )
        };
    $fk{Recording} = {
        map {
            $_->{recording_id}
        } map { @{ $self->data->{$_}{tracklist} } }
            qw( old new )
    };

    return \%fk;
}

sub display_tracklist {
    my ($self, $loaded, $tracklist) = @_;

    use aliased 'MusicBrainz::Server::Entity::Recording';
    use aliased 'MusicBrainz::Server::Entity::Tracklist';
    use aliased 'MusicBrainz::Server::Entity::Track';

    return Tracklist->new(
        tracks => [ map {
            Track->new(
                name => $_->{name},
                length => $_->{length},
                artist_credit => artist_credit_from_loaded_definition($loaded, $_->{artist_credit}),
                recording => $loaded->{Recording}{ $_->{recording_id} } ||
                    Recording->new( name => $_->{name} )
            )
        } @$tracklist ]
    )
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    my $data = {};

    if (exists $self->data->{new}{format_id}) {
        $data->{format} = {
            new => $loaded->{MediumFormat}->{ $self->data->{new}{format_id} },
            old => $loaded->{MediumFormat}->{ $self->data->{old}{format_id} }
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

    $data->{new}{tracklist} = $self->display_tracklist($loaded, $self->data->{new}{tracklist});
    $data->{old}{tracklist} = $self->display_tracklist($loaded, $self->data->{old}{tracklist});

    use Devel::Dwarn;
    Dwarn $data;

    return $data;
}

sub accept {
    my $self = shift;

    $self->c->model('Medium')->update($self->entity_id, $self->data->{new});

    if ($self->data->{new}{tracklist}) {
        my $data_new_tracklist = clone ($self->data->{new}{tracklist});

        my $medium = $self->c->model('Medium')->get_by_id($self->medium_id);

        # Create related data (artist credits and recordings)
        for my $track (@{ $data_new_tracklist }) {
            $track->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert(@{ $track->{artist_credit} });
            $track->{recording_id} ||= $self->c->model('Recording')->insert($track)->id;
        }

        # See if we need a new tracklist
        if ($self->data->{separate_tracklists} &&
                $self->c->model('Tracklist')->usage_count($medium->tracklist_id) > 1) {
            my $new_tracklist = $self->c->model('Tracklist')->find_or_insert(
                $self->data->{new_tracklist}
            );
            $self->c->model('Medium')->update($medium->id, {
                tracklist_id => $new_tracklist->id
            });
        }
        else {
            $self->c->model('Tracklist')->replace($medium->tracklist_id, 
                                                  $data_new_tracklist);
        }
    }
}

sub allow_auto_edit
{
    my $self = shift;

    my ($old_name, $new_name) = normalise_strings($self->data->{old}{name},
                                                  $self->data->{new}{name});

    return 0 if $self->data->{old}{name} && $old_name ne $new_name;
    return 0 if $self->data->{old}{format_id};
    return 0 if exists $self->data->{old}{position};
    return 0 if exists $self->data->{old}{tracklist};

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

__PACKAGE__->meta->make_immutable;
no Moose;

1;
