package MusicBrainz::Server::Edit::Label::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_ADD_ANNOTATION );

extends 'MusicBrainz::Server::Edit::Annotation::Edit';

sub edit_name { 'Add label annotation' }
sub edit_type { $EDIT_LABEL_ADD_ANNOTATION }

sub related_entities { { label => [ shift->label_id ] } }
sub models { [qw( Label )] }

sub _annotation_model { shift->c->model('Label')->annotation }

has 'label_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity_id} }
);

has 'label' => (
    isa => 'Label',
    is => 'rw',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
