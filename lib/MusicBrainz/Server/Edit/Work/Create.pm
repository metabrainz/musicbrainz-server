package MusicBrainz::Server::Edit::Work::Create;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_WORK_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( l ln );

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';

use aliased 'MusicBrainz::Server::Entity::Work';

sub edit_name { l('Add work') }
sub edit_type { $EDIT_WORK_CREATE }
sub _create_model { 'Work' }
sub work_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        type_id       => Nullable[Int],
        name          => Str,
        comment       => Nullable[Str],
        iswc          => Nullable[Str],
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Work => [ $self->entity_id ],
        WorkType => [ $self->data->{type_id} ]
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        name          => $self->data->{name},
        comment       => $self->data->{comment},
        type          => $self->data->{type_id} && $loaded->{WorkType}->{ $self->data->{type_id} },
        work          => $loaded->{Work}{ $self->entity_id }
            || Work->new( name => $self->data->{name} )
    };
}

sub allow_auto_edit { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
