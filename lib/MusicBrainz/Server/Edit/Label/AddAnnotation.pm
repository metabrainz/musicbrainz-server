package MusicBrainz::Server::Edit::Label::AddAnnotation;
use Moose;

use MusicBrainz::Server::Constants qw( $EDIT_LABEL_ADD_ANNOTATION );
use MusicBrainz::Server::Translation qw ( N_l );

use aliased 'MusicBrainz::Server::Entity::Label';

extends 'MusicBrainz::Server::Edit::Annotation::Edit';
with 'MusicBrainz::Server::Edit::Label';

sub edit_name { N_l('Add label annotation') }
sub edit_kind { 'add' }
sub edit_type { $EDIT_LABEL_ADD_ANNOTATION }

sub _build_related_entities { { label => [ shift->label_id ] } }
sub models { [qw( Label )] }

sub _annotation_model { shift->c->model('Label')->annotation }

has 'label_id' => (
    isa => 'Int',
    is => 'rw',
    lazy => 1,
    default => sub { shift->data->{entity}{id} }
);

has 'label' => (
    isa => 'Label',
    is => 'rw',
);

sub foreign_keys
{
    my $self = shift;
    return {
        Label => [ $self->label_id ],
    };
}

around 'build_display_data' => sub
{
    my $orig = shift;
    my ($self, $loaded) = @_;

    my $data = $self->$orig();
    $data->{label} = $loaded->{Label}->{ $self->label_id }
        || Label->new( name => $self->data->{entity}{name} );

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
