package MusicBrainz::Server::Form::Artist::Create;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::Artist::Base';

sub create_artist
{
    my $self = shift;
    my $user = $self->context->user;

    my ($begin, $end) =
        (
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('start') || '') ],
            [ map {$_ == '00' ? '' : $_} (split m/-/, $self->value('end') || '') ],
        );

    my @mods = Moderation->InsertModeration(
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privs,
        type  => ModDefs::MOD_ADD_ARTIST,

        name              => $self->value('name'),
        sortname          => $self->value('sortname'),
        mbid              => '',
        artist_type       => $self->value('artist_type'),
        artist_resolution => $self->value('resolution') || '',

        artist_begindate => $begin,
        artist_enddate   => $end,
    );

    $mods[0]->InsertNote($user->id, $self->value('edit_note'))
        if $mods[0] and $self->value('edit_note') =~ /\S/;

    return \@mods;
}

1;
