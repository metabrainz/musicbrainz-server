package MusicBrainz::Server::Form::Artist::EditAlias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Artist::AddAlias';

sub mod_type { ModDefs::MOD_EDIT_ARTISTALIAS }

sub init_value
{
    my ($self, $field, $item) = @_;
    $item ||= $self->item;

    return unless defined $item;

    use Switch;
    switch ($field->name)
    {
        case ('alias') { return $item->name; }
    }
}

sub build_options
{
    my ($self, $artist) = @_;

    return {
        artist  => $artist,
        alias   => $self->item,
        newname => $self->value('alias'),
    };
}

1;
