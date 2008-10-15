package MusicBrainz::Server::Form::Release::Remove;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

sub mod_type { ModDefs::MOD_REMOVE_RELEASE }

sub build_options
{
    my ($self) = @_;

    my $release = $self->item;

    return {
        album => $release
    };
}

1;
