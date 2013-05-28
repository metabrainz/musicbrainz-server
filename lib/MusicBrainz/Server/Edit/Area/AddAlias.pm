package MusicBrainz::Server::Edit::Area::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_AREA_ADD_ALIAS );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Area';

extends 'MusicBrainz::Server::Edit::Alias::Add';
with 'MusicBrainz::Server::Edit::Area';

sub _alias_model { shift->c->model('Area')->alias }

sub edit_name { N_l('Add area alias') }
sub edit_type { $EDIT_AREA_ADD_ALIAS }

sub _build_related_entities { { area => [ shift->area_id ] } }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    $self->c->model('Area')->adjust_edit_pending($adjust, $self->area_id);
    $self->c->model('Area')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

has 'area_id' => (
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
    $keys->{Area}->{ $self->area_id } = [];

    return $keys;
};

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data =  $self->$orig($loaded);
    $data->{area} = $loaded->{Area}->{ $self->area_id }
        || Area->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

