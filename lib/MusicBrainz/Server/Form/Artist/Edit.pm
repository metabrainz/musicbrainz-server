package MusicBrainz::Server::Form::Artist::Edit;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Artist::Base';

sub mod_type { ModDefs::MOD_EDIT_ARTIST }

sub build_options
{
    my $self = shift;
    
    my $artist = $self->item;

    my ($begin, $end) =
        (
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('start') || '') ],
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('end') || '') ],
        );

    return {
        artist      => $artist,
        name        => $self->value('name')        || $artist->name,
        sortname    => $self->value('sortname')    || $artist->sort_name,
        artist_type => $self->value('artist_type') || $artist->type,
        resolution  => $self->value('resolution')  || $artist->resolution,

        begindate => $begin,
        enddate   => $end,
    };
}

1;
