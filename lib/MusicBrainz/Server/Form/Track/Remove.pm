package MusicBrainz::Server::Form::Track::Remove;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

use Moderation;
use ModDefs;

sub mod_type { ModDefs::MOD_REMOVE_TRACK }

sub build_options
{
    my ($self, $release) = @_;
    
    my $track = $self->item;

    return {
        track => $track,
        album => $release,
    };
}

1;
