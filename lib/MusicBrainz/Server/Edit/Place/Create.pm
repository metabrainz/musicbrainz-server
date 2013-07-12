package MusicBrainz::Server::Edit::Place::Create;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PLACE_CREATE );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Translation qw ( N_l );
use aliased 'MusicBrainz::Server::Entity::PartialDate';
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw( ArrayRef Bool Str Int );
use MooseX::Types::Structured qw( Dict Optional );

use aliased 'MusicBrainz::Server::Entity::Place';

extends 'MusicBrainz::Server::Edit::Generic::Create';
with 'MusicBrainz::Server::Edit::Role::Preview';
with 'MusicBrainz::Server::Edit::Place';

sub edit_name { N_l('Add place') }
sub edit_type { $EDIT_PLACE_CREATE }
sub _create_model { 'Place' }
sub place_id { shift->entity_id }


has '+data' => (
    isa => Dict[
        name       => Str,
        gid        => Optional[Str],
        sort_name  => Optional[Str],
        comment    => Optional[Str],
        type_id    => Nullable[Int],
        address    => Optional[Str],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
        ended      => Optional[Bool],
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {
        Place       => [ $self->entity_id ],
        PlaceType   => [ $self->data->{type_id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->data->{type_id};

    return {
        ( map { $_ => $_ ? $self->data->{$_} : '' } qw( name sort_name ) ),
        type       => $type ? $loaded->{PlaceType}->{$type} : '',
        begin_date => PartialDate->new($self->data->{begin_date}),
        end_date   => PartialDate->new($self->data->{end_date}),
        place      => ($self->entity_id && $loaded->{Place}->{ $self->entity_id }) ||
            Place->new( name => $self->data->{name} ),
        ended      => $self->data->{ended} // 0,
        comment    => $self->data->{comment},
        address    => $self->data->{address}
    };
}

sub _insert_hash
{
    my ($self, $data) = @_;
    $data->{sort_name} ||= $data->{name};
    return $data;
};

sub allow_auto_edit { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
