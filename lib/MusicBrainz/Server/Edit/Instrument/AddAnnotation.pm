package MusicBrainz::Server::Edit::Instrument::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_INSTRUMENT_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw( N_l );

use aliased 'MusicBrainz::Server::Entity::Instrument';

extends 'MusicBrainz::Server::Edit::Annotation::Edit';
with 'MusicBrainz::Server::Edit::Instrument';

sub edit_name { N_l('Add instrument annotation') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_INSTRUMENT_ADD_ANNOTATION }

sub _build_related_entities { { instrument => [ shift->instrument_id ] } }
sub models { [qw( Instrument )] }

sub _annotation_model { shift->c->model('Instrument')->annotation }

has 'instrument_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

has 'instrument' => (
    isa => 'Instrument',
    is => 'rw',
);

sub foreign_keys {
    my $self = shift;
    return {
        Instrument => [ $self->instrument_id ],
    };
}

around 'build_display_data' => sub {
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig();
    $data->{instrument} = $loaded->{Instrument}->{ $self->instrument_id }
        || Instrument->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
