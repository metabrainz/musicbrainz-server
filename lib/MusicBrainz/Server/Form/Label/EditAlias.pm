package MusicBrainz::Server::Form::Label::EditAlias;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Label::AddAlias';

sub mod_type { ModDefs::MOD_EDIT_LABELALIAS }

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
    my ($self, $label) = @_;

    return {
        label   => $label,
        alias   => $self->item,
        newname => $self->value('alias'),
    };
}

1;
