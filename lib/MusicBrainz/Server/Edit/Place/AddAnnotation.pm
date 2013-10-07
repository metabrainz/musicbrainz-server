package MusicBrainz::Server::Edit::Place::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_PLACE_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Place';

extends 'MusicBrainz::Server::Edit::Annotation::Edit';
with 'MusicBrainz::Server::Edit::Place';

sub edit_name { N_l('Add place annotation') }
sub edit_type { $EDIT_PLACE_ADD_ANNOTATION }

sub _build_related_entities { { place => [ shift->place_id ] } }
sub models { [qw( Place )] }

sub _annotation_model { shift->c->model('Place')->annotation }

has 'place_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

has 'place' => (
    isa => 'Place',
    is => 'rw',
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

    my $data = $self->$orig();
    $data->{place} = $loaded->{Place}->{ $self->place_id }
        || Place->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
