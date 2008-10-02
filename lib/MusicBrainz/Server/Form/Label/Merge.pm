package MusicBrainz::Server::Form::Label::Merge;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditNote';

use Moderation;
use ModDefs;

sub perform_merge
{
    my ($self, $target) = @_;

    my $source = $self->item;
    my $user   = $self->context->user;

    my @mods = Moderation->InsertModeration(
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privs,
        type  => ModDefs::MOD_MERGE_LABEL,

        source => $source,
        target => $target,
    );

    if (@mods)
    {
        $mods[0]->InsertNote($c->user->id, $form->value('edit_note'))
            if $form->value('edit_note') =~ /\S/;
    }

    return \@mods;
}

1;
