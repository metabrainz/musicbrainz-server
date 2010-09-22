package MusicBrainz::Server::Edit::Medium::Create;
use Carp;
use Moose;
use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_CREATE );
use MusicBrainz::Server::Edit::Types qw( NullableOnPreview );
use MusicBrainz::Server::Entity::Medium;

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';

sub edit_type { $EDIT_MEDIUM_CREATE }
sub edit_name { "Add medium" }
sub _create_model { 'Medium' }
sub medium_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        name         => Optional[Str],
        format_id    => Optional[Int],
        position     => Int,
        release_id   => NullableOnPreview[Int],
        tracklist_id => NullableOnPreview[Int],
    ]
);

after 'initialize' => sub {
    my $self = shift;

    if ($self->preview)
    {
       $self->entity ( MusicBrainz::Server::Entity::Medium->new( $self->data ));
       return;
    }

    croak "No release_id specified" unless $self->data->{release_id};
    croak "No tracklist_id specified" unless $self->data->{tracklist_id};
};

sub foreign_keys
{
    my $self = shift;

    my %fk;

    $fk{MediumFormat} = { $self->data->{format_id} => [] } if $self->data->{format_id};
    $fk{Release} = { $self->data->{release_id} => [ 'ArtistCredit' ] }
        if $self->data->{release_id};

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
        tracklist_id => $self->data->{tracklist_id},
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

