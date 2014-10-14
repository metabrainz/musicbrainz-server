package MusicBrainz::Server::Form::Role::EditNote;
use HTML::FormHandler::Moose::Role;

use MusicBrainz::Server::Translation qw( l );

has 'requires_edit_note' => ( is => 'ro', default => 0 );

has_field 'edit_note' => (
    type => 'TextArea',
    label => 'Edit note:',
    localize_meth => sub { my ($self, @message) = @_; return l(@message); }
);

has_field 'make_votable' => (
    type => 'Checkbox',
);

sub requires_edit_note_text {
    l("You must provide an edit note");
}

sub default_make_votable {
    my $self = shift;
    return $self->ctx->user->is_auto_editor;
};

after validate => sub {
    my $self = shift;

    if ($self->requires_edit_note && (!defined $self->field('edit_note')->value || $self->field('edit_note')->value eq '')) {
        $self->field('edit_note')->add_error($self->requires_edit_note_text);
    }
};

1;
