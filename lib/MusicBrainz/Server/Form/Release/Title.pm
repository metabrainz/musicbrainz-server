package MusicBrainz::Server::Form::ReleaseTitle;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

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

sub update_model
{
    my $self = shift;

    my $release = $self->item;
    my $user    = $self->context->user;

    my @mods = Moderation->InsertModeration(
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privs,
        type  => ModDefs::MOD_EDIT_RELEASE_NAME,

        album   => $release,
        newname => $self->value('title'),
    );

    if (scalar @mods)
    {
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $self->value('edit_note') =~ /\S/;
    }

    return \@mods;
}

sub update_from_form
{
    my $self = shift;

    return unless $self->validate(@_);
    $self->update_model;

    return 1;
}

1;
