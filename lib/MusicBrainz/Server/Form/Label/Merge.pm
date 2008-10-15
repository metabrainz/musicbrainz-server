package MusicBrainz::Server::Form::Label::Merge;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

use Moderation;
use ModDefs;

sub mod_type { ModDefs::MOD_MERGE_LABEL }

sub build_options
{
    my ($self, $target) = @_;

    my $source = $self->item;

    return {
        source => $source,
        target => $target,
    };
}

1;
