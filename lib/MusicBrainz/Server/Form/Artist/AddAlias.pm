package MusicBrainz::Server::Form::Artist::AddAlias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditForm';

sub profile
{
    return {
        required => {
            alias => 'Text',
        },
        optional => {
            edit_note => 'TextArea',
        }
    }
}

sub mod_type { ModDefs::MOD_ADD_ARTISTALIAS }

sub build_options
{
    my ($self) = @_;

    my $source = $self->item;

    return {
        artist   => $source,
        newalias => $self->value('alias'),
    }
}

1;
