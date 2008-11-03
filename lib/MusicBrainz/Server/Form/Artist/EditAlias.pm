package MusicBrainz::Server::Form::Artist::EditAlias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Alias';

sub mod_type { ModDefs::MOD_EDIT_ARTISTALIAS }

sub build_options
{
    my ($self, $artist) = @_;

    return {
        artist  => $artist,
        alias   => $self->item,
        newname => $self->value('alias'),
    };
}

1;
