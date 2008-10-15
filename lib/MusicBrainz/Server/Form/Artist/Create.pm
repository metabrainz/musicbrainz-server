package MusicBrainz::Server::Form::Artist::Create;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Artist::Base';

sub mod_type { ModDefs::MOD_ADD_ARTIST }

sub build_options
{
    my ($self) = @_;

    my ($begin, $end) =
        (
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('start') || '') ],
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('end') || '') ],
        );

    return {
        name              => $self->value('name'),
        sortname          => $self->value('sortname'),
        mbid              => '',
        artist_type       => $self->value('artist_type'),
        artist_resolution => $self->value('resolution') || '',

        artist_begindate => $begin,
        artist_enddate   => $end,
    }
}

1;
