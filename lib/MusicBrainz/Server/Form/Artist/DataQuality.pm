package MusicBrainz::Server::Form::Artist::DataQuality;

use base 'MusicBrainz::Server::Form::DataQuality';

sub build_moderation
{
    my ($self, $current_moderation) = @_;

    $current_moderation->{type}    = ModDefs::MOD_CHANGE_ARTIST_QUALITY;
    $current_moderation->{artist}  = $self->item;

    return $current_moderation;
}

1;
