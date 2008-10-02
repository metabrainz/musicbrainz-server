package MusicBrainz::Server::Form::Release::DataQuality;

use base 'MusicBrainz::Server::DataQuality';

sub build_moderation
{
    my ($self, $current_moderation) = @_;

    $current_moderation->{type}     = ModDefs::MOD_CHANGE_RELEASE_QUALITY;
    $current_moderation->{releases} = [ $self->item ];

    return $current_moderation;
}

1;
