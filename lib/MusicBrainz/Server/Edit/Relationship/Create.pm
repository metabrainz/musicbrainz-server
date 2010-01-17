package MusicBrainz::Server::Edit::Relationship::Create;
use Moose;

use MusicBrainz::Server::Edit::Types qw( PartialDateHash );

extends 'MusicBrainz::Server::Edit::Generic::Create';

use MooseX::Types::Moose qw( ArrayRef Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable );

sub edit_type { $EDIT_RELATIONSHIP_CREATE }
sub edit_name { 'Create relationship' }
sub _create_model { 'Relationship' }

has '+data' => (
    isa => Dict[
        entity0      => Int,
        entity1      => Int,
        link_type_id => Int,
        attributes   => Nullable[ArrayRef[Int]],
        begin_date   => Nullable[PartialDateHash],
        end_date     => Nullable[PartialDateHash],
        type0        => Str,
        type1        => Str
    ]
);

sub related_entities
{
    my ($self) = @_;

    my $result;
    if ($self->data->{type0} eq $self->data->{type1}) {
        $result = {
            $self->data->{type0} => [ $self->data->{entity0},
                                      $self->data->{entity1} ]
        };
    }
    else {
        $result = {
            $self->data->{type0} => [ $self->data->{entity0} ],
            $self->data->{type1} => [ $self->data->{entity1} ]
        };
    }
    delete $result->{url} if exists $result->{url};
    return $result;
}

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Relationship')->adjust_edit_pending(
        $self->data->{type0}, $self->data->{type1},
        $adjust, $self->entity_id);
}

sub insert
{
    my ($self) = @_;
    my $relationship = $self->c->model('Relationship')->insert(
        $self->data->{type0},
        $self->data->{type1}, {
            entity0_id   => $self->data->{entity0},
            entity1_id   => $self->data->{entity1},
            attributes   => $self->data->{attributes},
            link_type_id => $self->data->{link_type_id},
            begin_date   => $self->data->{begin_date},
            end_date     => $self->data->{end_date},
        });

    $self->entity_id($relationship->id);
    $self->entity($relationship);
}

sub reject
{
    my $self = shift;
    $self->c->model('Relationship')->delete(
        $self->data->{type0},
        $self->data->{type1},
        $self->entity_id
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
