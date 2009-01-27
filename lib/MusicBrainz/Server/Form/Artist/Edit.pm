package MusicBrainz::Server::Form::Artist::Edit;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Artist::Base';

sub name { 'edit-artist' }

sub apply_edit
{
    my ($self) = @_;
    my $artist = $self->item;

    $self->context->model('Artist')->edit(
        $artist,
        $self->value('edit_note'),

        name        => $self->value('name')        || $artist->name,
        sort_name   => $self->value('sortname')    || $artist->sort_name,
        type        => $self->value('artist_type') || $artist->type,
        resolution  => $self->value('resolution')  || $artist->resolution,
        begin       => $self->value('start'),
        end         => $self->value('end'),
    );
}

1;
