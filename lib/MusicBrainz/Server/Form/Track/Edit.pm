package MusicBrainz::Server::Form::Track::Edit;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Track::Base';

sub name { 'edit-track' }

sub edit
{
    my $self = shift;

    my $track     = $self->item;
    my $model     = $self->context->model('Track');
    my $new       = $self->value('track');
    my $edit_note = $self->value('edit_note');

    $model->edit_number($track, $new->{number}, $edit_note);
    $model->edit_title($track, $new->{name}, $edit_note);
    $model->edit_duration($track, $new->{duration}, $edit_note);
}

1;
