package MusicBrainz::Server::Edit::Place::DeleteAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PLACE_DELETE_ALIAS );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Translation qw( N_l );

extends 'MusicBrainz::Server::Edit::Alias::Delete';
with 'MusicBrainz::Server::Edit::Place';

use aliased 'MusicBrainz::Server::Entity::Place';

sub _alias_model { shift->c->model('Place')->alias }

sub edit_name { N_l('Remove place alias') }
sub edit_kind { 'remove' }
sub edit_type { $EDIT_PLACE_DELETE_ALIAS }

sub _build_related_entities { { place => [ shift->place_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Place')->adjust_edit_pending($adjust, $self->place_id);
    $self->c->model('Place')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

has 'place_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

sub foreign_keys
{
    my $self = shift;
    return {
        Place => [ $self->place_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig($loaded);
    $data->{place} = to_json_object(
        $loaded->{Place}{ $self->place_id } ||
        Place->new(name => $self->data->{entity}{name})
    );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
