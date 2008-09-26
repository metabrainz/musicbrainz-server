package MusicBrainz::Server::Form::AddNonAlbumTrack;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        required => {
            track => {
                type => '+MusicBrainz::Server::Form::Field::Track',

                # Don't require a track number for non album tracks
                with_track_number => 0, 
            }
        },
        optional => {
            edit_note => 'TextArea',
        }
    }
}

sub update_model
{
    my $self = shift;

    my $artist = $self->item;
    my $user   = $self->context->user;

    my @mods = Moderation->InsertModeration(
        DBH   => $self->context->mb->{DBH},
        uid   => $user->id,
        privs => $user->privs,
        type  => ModDefs::MOD_ADD_TRACK_KV,

        artist      => $artist,
        trackname   => $self->value('track')->{name},
        tracklength => $self->value('track')->{duration} || 0,
    );

    if (scalar @mods)
    {
        $mods[0]->InsertNote($user->id, $self->value('edit_note'))
            if $mods[0] and $self->value('edit_note') =~ /\S/;

        return \@mods;
    }
    else
    {
        die "Could not insert track";
    }
}

=head2 update_from_form

A small helper method to validate the form and update the database if validation succeeds in one easy call.

=cut

sub update_from_form
{
    my ($self, $data) = @_;

    return unless $self->validate($data);
    $self->update_model;
}

1;
