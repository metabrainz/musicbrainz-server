package MusicBrainz::Server::Edit::Medium::Create;
use Carp;
use Moose;
use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_CREATE );
use MusicBrainz::Server::Edit::Types qw(
    ArtistCreditDefinition
    Nullable
    NullableOnPreview
);
use MusicBrainz::Server::Edit::Utils qw(
    load_artist_credit_definitions
    artist_credit_from_loaded_definition
);
use MusicBrainz::Server::Entity::Medium;
use MusicBrainz::Server::Track qw( unformat_track_length format_track_length );
use MusicBrainz::Server::Data::Utils qw( artist_credit_to_ref );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Medium::RelatedEntities';

sub edit_type { $EDIT_MEDIUM_CREATE }
sub edit_name { l('Add medium') }
sub _create_model { 'Medium' }
sub medium_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        name         => Optional[Str],
        format_id    => Optional[Int],
        position     => Int,
        release_id   => NullableOnPreview[Int],
        tracklist    => ArrayRef[track()]
    ]
);

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

sub initialize {
    my ($self, %opts) = @_;

    my $tracklist = delete $opts{tracklist};
    $opts{tracklist} = _tracks_to_hash($tracklist);

    $self->data(\%opts);
}

sub foreign_keys
{
    my $self = shift;

    my %fk;

    $fk{MediumFormat} = { $self->data->{format_id} => [] } if $self->data->{format_id};
    $fk{Release} = { $self->data->{release_id} => [ 'ArtistCredit' ] }
        if $self->data->{release_id};

    $fk{Artist} = {
        map {
            load_artist_credit_definitions($_->{artist_credit})
        } @{ $self->data->{tracklist} }
    };

    $fk{Recording} = {
        map {
            $_->{recording_id}
        } @{ $self->data->{tracklist} }
    };

    return \%fk;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    use aliased 'MusicBrainz::Server::Entity::Tracklist';
    use aliased 'MusicBrainz::Server::Entity::Track';

    return {
        name         => $self->data->{name},
        format       => $loaded->{MediumFormat}->{ $self->data->{format_id} },
        position     => $self->data->{position},
        release      => $loaded->{Release}->{ $self->data->{release_id} },
        tracklist    => Tracklist->new(
            tracks => [ map {
                Track->new(
                    name => $_->{name},
                    length => $_->{length},
                    artist_credit => artist_credit_from_loaded_definition($loaded, $_->{artist_credit}),
                    recording => $loaded->{Recording}{ $_->{recording_id} }
                )
            } @{ $self->data->{tracklist} } ]
        )
    };
}

sub _insert_hash {
    my ($self, $data) = @_;

    # Create related data (artist credits and recordings)
    my $tracklist = delete $data->{tracklist};
    for my $track (@$tracklist) {
        $track->{artist_credit} = $self->c->model('ArtistCredit')->find_or_insert(@{ $track->{artist_credit} });
        $track->{recording_id} ||= $self->c->model('Recording')->insert($track)->id;
    }

    $data->{tracklist_id} = $self->c->model('Tracklist')->find_or_insert($tracklist)->id;

    return $data;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

