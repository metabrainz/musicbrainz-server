package MusicBrainz::Server::Form::MoveRelease;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use Moderation;

sub profile
{
    return {
        optional => {
            edit_note => 'TextArea',
            move_tracks => 'Checkbox',
        }
    };
}

sub update_model
{
    my ($self) = @_;

    my $release = $self->item;
    my $user    = $self->context->user;
    my $artist  = $self->context->model('Artist')->load($release->artist);

    my @mods = Moderation->InsertModeration(
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privs,
        type  => ModDefs::MOD_MOVE_RELEASE,

        album              => $release,
        oldartist          => $artist,
        artistname         => $artist->name,
        artistsortname     => $artist->sort_name,
        artistid           => $artist->id,
        movetracks         => $self->value('move_tracks'),
    );

    if (scalar @mods)
    {

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
