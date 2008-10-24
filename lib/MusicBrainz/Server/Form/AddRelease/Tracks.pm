package MusicBrainz::Server::Form::AddRelease::Tracks;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

sub profile
{
    return {
        required => {
            title   => 'Text',
            artist  => 'Text',
            event_1 => '+MusicBrainz::Server::Form::Field::ReleaseEvent',
        },
        optional => {
            edit_note => 'TextArea',
        }
    };
}

sub add_tracks
{
    my ($self, $count) = @_;

    for my $i (1..$count)
    {
        my $track_field = $self->make_field("track_$i", '+MusicBrainz::Server::Form::Field::Track');
        $track_field->sub_form->field('number')->value($i);
        $track_field->required(1);

        my $artist_field = $self->make_field("artist_$i", 'Text');
        $artist_field->required(1);

        my $artist_id = $self->make_field("artist_id_$i", 'Integer');

        $self->add_field($track_field);
        $self->add_field($artist_field);
        $self->add_field($artist_id);
    }
}

1;
