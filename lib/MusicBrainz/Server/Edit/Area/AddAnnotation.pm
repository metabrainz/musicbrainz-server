package MusicBrainz::Server::Edit::Area::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_AREA_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Area';

extends 'MusicBrainz::Server::Edit::Annotation::Edit';
with 'MusicBrainz::Server::Edit::Area';

sub edit_name { N_l('Add area annotation') }
sub edit_type { $EDIT_AREA_ADD_ANNOTATION }

sub _build_related_entities { { area => [ shift->area_id ] } }
sub models { [qw( Area )] }

sub _annotation_model { shift->c->model('Area')->annotation }

has 'area_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

has 'area' => (
    isa => 'Area',
    is => 'rw',
);

sub foreign_keys
{
    my $self = shift;
    return {
        Area => [ $self->area_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig();
    $data->{area} = $loaded->{Area}->{ $self->area_id }
        || Area->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
