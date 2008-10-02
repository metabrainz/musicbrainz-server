package MusicBrainz::Server::Form::Artist::Merge;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

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

sub perform_merge
{
    my ($self, $target) = @_;

    my $source = $self->item;
    my $user   = $self->context->user;

    my @mods = Moderation->InsertModeration(
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privs,
        type  => ModDefs::MOD_MERGE_ARTIST,

        source => $source,
        target => $target,
    );
    
    $mods[0]->InsertNote($user->id, $self->value('edit_note'))
        if $self->value('edit_note') =~ /\S/;
}

1;
