package MusicBrainz::Server::Form::Label::RemoveAlias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

sub mod_type { ModDefs::MOD_REMOVE_LABELALIAS }

sub build_options
{
    my ($self, $alias) = @_;

    return {
        label => $self->item,
        alias => $alias
    };
}

1;
