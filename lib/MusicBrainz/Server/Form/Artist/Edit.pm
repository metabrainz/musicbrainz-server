package MusicBrainz::Server::Form::Artist::Edit;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Artist::Base';

sub update_model
{
    my $self = shift;
    
    my $artist = $self->item;
    my $user   = $self->context->user;

    my ($begin, $end) =
        (
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('start') || '') ],
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('end') || '') ],
        );

    my @mods = Moderation->InsertModeration(
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privs,
        type  => ModDefs::MOD_EDIT_ARTIST,

        artist      => $artist,
        name        => $self->value('name')        || $artist->name,
        sortname    => $self->value('sortname')    || $artist->sort_name,
        artist_type => $self->value('artist_type') || $artist->type,
        resolution  => $self->value('resolution')  || $artist->resolution,

        begindate => $begin,
        enddate   => $end,
    );

    $mods[0]->InsertNote($user->id, $self->value('edit_note'))
        if $mods[0] and $self->value('edit_note') =~ /\S/;

    return \@mods;
}

1;
