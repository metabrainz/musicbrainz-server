package MusicBrainz::Server::Edit::Work::Create;
use Moose;

use MooseX::Types::Moose qw( ArrayRef Int Maybe Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw( $EDIT_WORK_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';

use aliased 'MusicBrainz::Server::Entity::Work';

sub edit_name { N_l('Add work') }
sub edit_type { $EDIT_WORK_CREATE }
sub _create_model { 'Work' }
sub work_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        name          => Str,
        comment       => Nullable[Str],
        type_id       => Nullable[Int],
        language_id   => Nullable[Int],
        iswc          => Nullable[Str],
        attributes    => Optional[ArrayRef[Dict[
            attribute_text => Maybe[Str],
            attribute_value_id => Maybe[Int],
            attribute_type_id => Int
        ]]]
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Work => [ $self->entity_id ],
        WorkType => [ $self->data->{type_id} ],
        Language => [ $self->data->{language_id} ]
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        name          => $self->data->{name},
        comment       => $self->data->{comment},
        type          => $self->data->{type_id} && $loaded->{WorkType}->{ $self->data->{type_id} },
        language      => $self->data->{language_id} && $loaded->{Language}->{ $self->data->{language_id} },
        iswc          => $self->data->{iswc},
        work          => $loaded->{Work}{ $self->entity_id } || Work->new( name => $self->data->{name} ),
        attributes    => { $self->grouped_attributes_by_type($self->data->{attributes}) },
    };
}

sub allow_auto_edit { 1 }

after insert => sub {
    my $self = shift;
    if (my $attributes = $self->data->{attributes}) {
        $self->c->model('Work')->set_attributes($self->entity_id, @$attributes);
    }
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
