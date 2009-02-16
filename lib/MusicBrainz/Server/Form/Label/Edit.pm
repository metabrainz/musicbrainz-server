package MusicBrainz::Server::Form::Label::Edit;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Label::Base';

sub name { 'edit-label' }

sub edit
{
    my ($self) = @_;

    $self->context->model('Label')->edit(
        $self->item,
        $self->value('edit_note'),

        name       => $self->value('name'),
        sort_name  => $self->value('sort_name'),
        type       => $self->value('type') || MusicBrainz::Server::Label::LABEL_TYPE_UNKNOWN,
        resolution => $self->value('resolution'),
        country    => $self->value('country'),
        label_code => $self->value('label_code'),
        begin_date => $self->value('begin_date'),
        end_date   => $self->value('end_date'),
    );
}

1;
