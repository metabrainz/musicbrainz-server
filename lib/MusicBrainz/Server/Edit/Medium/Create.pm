package MusicBrainz::Server::Edit::Medium::Create;
use Moose;

use MooseX::Types::Moose qw( Str Int );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_MEDIUM_CREATE );

extends 'MusicBrainz::Server::Edit::Generic::Create';

sub edit_type { $EDIT_MEDIUM_CREATE }
sub edit_name { "Add medium" }
sub _create_model { 'Medium' }
sub medium_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        name         => Optional[Str],
        format_id    => Optional[Int],
        position     => Int,
        release_id   => Int,
        tracklist_id => Int,
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Release      => { $self->data->{release_id} => [ 'ArtistCredit' ] },
        MediumFormat => { $self->data->{format_id} => [] }
    };
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

