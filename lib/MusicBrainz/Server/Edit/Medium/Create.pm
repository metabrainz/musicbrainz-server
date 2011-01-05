package MusicBrainz::Server::Edit::Medium::Create;
use Carp;
use Moose;
use MooseX::Types::Moose qw( ArrayRef Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_CREATE );
use MusicBrainz::Server::Edit::Medium::Util ':all';
use MusicBrainz::Server::Edit::Types qw(
    ArtistCreditDefinition
    Nullable
    NullableOnPreview
);
use MusicBrainz::Server::Entity::Medium;
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

sub initialize {
    my ($self, %opts) = @_;

    my $tracklist = delete $opts{tracklist};
    $opts{tracklist} = tracks_to_hash($tracklist);

    $self->data(\%opts);
}

sub foreign_keys
{
    my $self = shift;

    my %fk;
    $fk{MediumFormat} = { $self->data->{format_id} => [] } if $self->data->{format_id};
    $fk{Release} = { $self->data->{release_id} => [ 'ArtistCredit' ] }
        if $self->data->{release_id};

    tracklist_foreign_keys(\%fk, $self->data->{tracklist});

    return \%fk;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    return {
        name         => $self->data->{name},
        format       => $loaded->{MediumFormat}->{ $self->data->{format_id} },
        position     => $self->data->{position},
        release      => $loaded->{Release}->{ $self->data->{release_id} },
        tracklist    => display_tracklist($loaded, $self->data->{tracklist})
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

