package MusicBrainz::Server::Form::Artist::DataQuality;

use base 'MusicBrainz::Server::Form::DataQuality';

use ModDefs;

sub name { 'change-artist-quality' }

sub mod_type { ModDefs::MOD_CHANGE_ARTIST_QUALITY; }

sub build_options
{
    my $self = shift;

    return {
        artist  => $self->item,
        quality => $self->value('quality'),
    };
}

1;
