package MusicBrainz::Server::Form::Release::Title;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditForm';

sub profile
{
    return {
        required => {
            title => 'Text',
        },
        optional => {
            edit_note => 'TextArea',
        },
    }
}

sub init_value
{
    my ($self, $field, $item) = @_;
    
    use Switch;
    switch ($field->name)
    {
        case ('title') { return $item->name; }
    }
}

sub mod_type { ModDefs::MOD_EDIT_RELEASE_NAME }

sub build_options
{
    my $self = shift;

    my $release = $self->item;

    return {
        album   => $release,
        newname => $self->value('title'),
    };
}

1;
