package MusicBrainz::Server::Edit::Instrument::AddAlias;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_INSTRUMENT_ADD_ALIAS );
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::Entity::Instrument';

extends 'MusicBrainz::Server::Edit::Alias::Add';
with 'MusicBrainz::Server::Edit::Instrument';

sub _alias_model { shift->c->model('Instrument')->alias }

sub edit_name { N_l('Add instrument alias') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_INSTRUMENT_ADD_ALIAS }

sub _build_related_entities { { instrument => [ shift->instrument_id ] } }

sub adjust_edit_pending {
    my ($self, $adjust) = @_;

    $self->c->model('Instrument')->adjust_edit_pending($adjust, $self->instrument_id);
    $self->c->model('Instrument')->alias->adjust_edit_pending($adjust, $self->alias_id);
}

has 'instrument_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

around 'foreign_keys' => sub {
    my $orig = shift;
    my $self = shift;

    my $keys = $self->$orig();
    $keys->{Instrument}->{ $self->instrument_id } = [];

    return $keys;
};

around 'build_display_data' => sub {
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data =  $self->$orig($loaded);
    $data->{instrument} = $loaded->{Instrument}->{ $self->instrument_id }
        || Instrument->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

