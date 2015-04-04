package MusicBrainz::Server::Edit::Place::Create;
use Moose;
use List::AllUtils qw( any );
use MusicBrainz::Server::Constants qw( $EDIT_PLACE_CREATE );
use MusicBrainz::Server::Edit::Types qw( CoordinateHash Nullable PartialDateHash );
use MusicBrainz::Server::Translation qw( N_l );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use aliased 'MusicBrainz::Server::Entity::Coordinates';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( Bool Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Place';
use aliased 'MusicBrainz::Server::Entity::Area';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Place';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';
with 'MusicBrainz::Server::Edit::Role::DatePeriod';

sub edit_name { N_l('Add place') }
sub edit_type { $EDIT_PLACE_CREATE }
sub _create_model { 'Place' }
sub place_id { shift->entity_id }

has '+data' => (
    isa => Dict[
        name        => Str,
        comment     => Nullable[Str],
        type_id     => Nullable[Int],
        address     => Nullable[Str],
        area_id     => Nullable[Int],
        coordinates => Nullable[CoordinateHash],
        begin_date  => Nullable[PartialDateHash],
        end_date    => Nullable[PartialDateHash],
        ended       => Optional[Bool],
    ]
);

around initialize => sub {
    my ($orig, $self, %options) = @_;

    if ($self->is_comment_required(\%options)) {
        MusicBrainz::Server::Edit::Exceptions::GeneralError->throw(
            'A comment is required for this place.'
        );
    }

    $self->$orig(%options);
};

sub is_comment_required {
    my ($self, $data) = @_;

    my ($name, $comment, $area_id) = $data->{qw(name comment area_id)};
    return 0 if $comment;

    my @duplicates = $self->c->model('Place')->find_by_name($name);
    return 0 unless @duplicates;

    # We require a disambiguation comment if no area is given, or if there
    # is a possible duplicate in the same area or lacking area information.
    return 1 unless defined $area_id;

    $self->c->model('Area')->load(@duplicates);
    return any {(!$_->area || $_->area->id == $area_id) ? 1 : 0} @duplicates;
}

sub foreign_keys
{
    my $self = shift;
    return {
        Place       => [ $self->entity_id ],
        PlaceType   => [ $self->data->{type_id} ],
        Area        => [ $self->data->{area_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->data->{type_id};

    return {
        ( map { $_ => $_ ? $self->data->{$_} : '' } qw( name ) ),
        type        => $type ? $loaded->{PlaceType}->{$type} : '',
        begin_date  => PartialDate->new($self->data->{begin_date}),
        end_date    => PartialDate->new($self->data->{end_date}),
        place       => ($self->entity_id && $loaded->{Place}->{ $self->entity_id }) ||
            Place->new( name => $self->data->{name} ),
        ended       => $self->data->{ended} // 0,
        comment     => $self->data->{comment},
        address     => $self->data->{address},
        coordinates => defined $self->data->{coordinates} ? Coordinates->new($self->data->{coordinates}) : '',
        area        => defined($self->data->{area_id}) &&
                       ($loaded->{Area}->{ $self->data->{area_id} } // Area->new())
    };
}

before restore => sub {
    my ($self, $data) = @_;

    $data->{coordinates} = undef
        if defined $data->{coordinates} && !defined $data->{coordinates}{latitude};
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
