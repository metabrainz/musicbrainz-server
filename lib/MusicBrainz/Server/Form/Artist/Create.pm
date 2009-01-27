package MusicBrainz::Server::Form::Artist::Create;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Artist::Base';

sub name { 'create-artist' }

sub create
{
    my ($self) = @_;

    return $self->context->model('Artist')->create(
        $self->value('edit_note'),

	name       => $self->value('name'),
	sort_name  => $self->value('sortname'),
	begin_date => $self->value('start'),
	end_date   => $self->value('end'),
	resolution => $self->value('resolution'),
    );
}

1;
