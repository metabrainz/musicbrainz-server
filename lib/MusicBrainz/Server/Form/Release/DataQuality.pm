package MusicBrainz::Server::Form::Release::DataQuality;

use base 'MusicBrainz::Server::DataQuality';

sub name { 'change-release-quality' }

sub mod_type { ModDefs::MOD_CHANGE_RELEASE_QUALITY }

sub build_options
{
    my $self = shift;

    return {
        type     => ModDefs::MOD_CHANGE_RELEASE_QUALITY,
        releases => [ $self->item ],
        quality  => $self->value('quality'),
    };
}

1;
