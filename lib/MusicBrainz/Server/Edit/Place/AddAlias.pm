package MusicBrainz::Server::Edit::Place::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PLACE_ADD_ALIAS );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Place';

extends 'MusicBrainz::Server::Edit::Alias::Add';
with 'MusicBrainz::Server::Edit::Place';

sub _alias_model { shift->c->model('Place')->alias }

sub edit_name { N_l('Add place alias') }
sub edit_type { $EDIT_PLACE_ADD_ALIAS }

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

around 'foreign_keys' => sub
{
    my $orig = shift;
    my $self = shift;

    my $keys = $self->$orig();
    $keys->{Place}->{ $self->place_id } = [];

    return $keys;
};

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data =  $self->$orig($loaded);
    $data->{place} = $loaded->{Place}->{ $self->place_id }
        || Place->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

