package MusicBrainz::Server::Form::Annotation;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Data::Utils qw( trim_multiline_text );
extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => (default => 'edit-annotation');

has_field 'text' => (
    type     => 'Text',
    trim => { transform => sub { trim_multiline_text(shift) } }
);

has_field 'changelog' => (
    type      => '+MusicBrainz::Server::Form::Field::Text',
    maxlength => 255,
    default_over_obj => ''
);

has 'annotation_model' => (
    is       => 'ro',
    required => 1
);

has 'entity_id' => (
    is       => 'ro',
    required => 1
);

has_field 'preview' => (
    type => 'Submit',
    value => ''
);

sub edit_field_names { qw( text changelog ) }

sub validate
{
    my ($self) = @_;

    # The "text" field is required only if the previous annotation was blank
    my $previous_annotanion = $self->annotation_model->get_latest($self->entity_id);
    $self->field('text')->required($previous_annotanion && $previous_annotanion->text ? 0 : 1);
    $self->field('text')->validate_field;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
