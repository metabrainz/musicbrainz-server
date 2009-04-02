package MusicBrainz::Server::Form::User::AdjustFlags;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        optional => {
            auto_editor => 'Checkbox',
            bot         => 'Checkbox',
            untrusted   => 'Checkbox',
            link_editor => 'Checkbox',
            wiki_transcluder => 'Checkbox',
            mbid_submitter => 'Checkbox',
        }
    };
}

sub init_value
{
    my ($self, $field) = @_;
    my $user = $self->item;

    use Switch;
    switch ($field->name)
    {
        case ('auto_editor')      { return $user->is_auto_editor; }
        case ('bot')              { return $user->is_bot; }
        case ('untrusted')        { return $user->is_untrusted; }
        case ('link_editor')      { return $user->is_link_moderator; }
        case ('wiki_transcluder') { return $user->is_wiki_transcluder; }
        case ('mbid_submitter')   { return $user->is_mbid_submitter; }
    }
}

1;
