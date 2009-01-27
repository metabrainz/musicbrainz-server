package MusicBrainz::Server::Form::Label::Create;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Label::Base';

sub name { 'create-label' }

sub create
{
    my $self = shift;

    return $self->context->model('Label')->create(
        $self->value('edit_note'),

        name       => $self->value('name'),
        sort_name  => $self->value('sort_name'),
        type       => $self->value('type'),
        resolution => $self->value('resolution'),
        begin_date => $self->value('begin_date'),
        end_date   => $self->value('end_date'),
        country    => $self->value('country'),
        label_code => $self->value('label_code'),
    );
}

1;
