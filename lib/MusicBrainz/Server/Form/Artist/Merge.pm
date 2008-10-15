package MusicBrainz::Server::Form::Artist::Merge;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditForm';

use Moderation;
use ModDefs;

sub profile
{
    return {
        required => {
            edit_note => 'TextArea',
        }
    };
}

sub mod_type { ModDefs::MOD_MERGE_ARTIST }

sub build_options
{
    my ($self, $target) = @_;

    my $source = $self->item;

    return {
        source => $source,
        target => $target,
    }
}

1;
