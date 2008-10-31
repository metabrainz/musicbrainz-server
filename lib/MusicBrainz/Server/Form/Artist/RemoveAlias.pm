package MusicBrainz::Server::Form::Artist::RemoveAlias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

sub mod_type { ModDefs::MOD_REMOVE_ARTISTALIAS }

sub build_options
{
    my ($self, $alias) = @_;

    return {
        artist => $self->item,
        alias  => $alias
    };
}

1;
