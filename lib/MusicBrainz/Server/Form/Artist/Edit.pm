package MusicBrainz::Server::Form::Artist::Edit;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Artist::Base';

sub name { 'edit-artist' }

sub apply_edit
{
    my ($self) = @_;
    my $artist = $self->item;

    my $artist_type = defined $self->value('artist_type')
        ? $self->value('artist_type')
        : $artist->type;

    $self->context->model('Artist')->edit(
        $artist,
        $self->value('edit_note'),

        name        => $self->value('name')        || $artist->name,
        sort_name   => $self->value('sortname')    || $artist->sort_name,
        type        => $artist_type,
        resolution  => $self->value('resolution')  || '',
        begin       => $self->value('start'),
        end         => $self->value('end'),
    );
}

1;
