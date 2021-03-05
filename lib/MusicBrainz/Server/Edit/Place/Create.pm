package MusicBrainz::Server::Edit::Place::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PLACE_CREATE );
use MusicBrainz::Server::Edit::Types qw( CoordinateHash Nullable PartialDateHash );
use MusicBrainz::Server::Translation qw( N_l );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
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
with 'MusicBrainz::Server::Edit::Role::CheckDuplicates';

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
        type        => $type ? to_json_object($loaded->{PlaceType}{$type}) : undef,
        begin_date  => to_json_object(PartialDate->new($self->data->{begin_date})),
        end_date    => to_json_object(PartialDate->new($self->data->{end_date})),
        place       => ($self->entity_id && to_json_object(
            $loaded->{Place}{ $self->entity_id }) ||
            Place->new( name => $self->data->{name} )
        ),
        ended       => boolean_to_json($self->data->{ended}),
        comment     => $self->data->{comment},
        address     => $self->data->{address},
        coordinates => defined $self->data->{coordinates} &&
                       to_json_object(Coordinates->new($self->data->{coordinates})),
        area        => defined($self->data->{area_id}) &&
                       to_json_object($loaded->{Area}{ $self->data->{area_id} } // Area->new())
    };
}

sub edit_template_react { "AddPlace" }

before restore => sub {
    my ($self, $data) = @_;

    $data->{coordinates} = undef
        if defined $data->{coordinates} && !defined $data->{coordinates}{latitude};
};

override _is_disambiguation_needed => sub {
    my ($self, %opts) = @_;

    my ($name, $area_id) = $opts{qw(name area_id)};
    my $duplicate_areas = $self->c->sql->select_single_column_array(
        'SELECT area FROM place
         WHERE lower(musicbrainz_unaccent(name)) = lower(musicbrainz_unaccent(?))',
        $name
    );

    return $self->_possible_duplicate_area($area_id, @$duplicate_areas);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
