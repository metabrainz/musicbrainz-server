package MusicBrainz::Server::Form::AddRelease::Tracks;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form::EditForm';

use Rose::Object::MakeMethods::Generic(
    scalar => [ 'track_count', 'event_count' ]
);

sub profile
{
    return {
        required => {
            title   => {
                type => 'Text',
                size => 50,
            },
            event_1 => '+MusicBrainz::Server::Form::Field::ReleaseEvent',
        },
        optional => {
            edit_note   => 'TextArea',
            more_events => 'Checkbox',
        }
    };
}

sub add_tracks
{
    my ($self, $count, $artist) = @_;
    $self->track_count($count);

    for my $i (1..$count)
    {
        my $track_field = $self->make_field("track_$i", '+MusicBrainz::Server::Form::Field::Track');
        $track_field->sub_form->field('number')->value($i);
        $track_field->required(1);

        my $artist_field = $self->make_field("artist_$i", { type => 'Text', size => 50 });
        $artist_field->required(1);
        $artist_field->value($artist->name);

        $self->add_field($track_field);
        $self->add_field($artist_field);
    }
}

sub add_events
{
    my ($self, $count) = @_;
    $self->event_count($count);

    for my $i (1 .. $count)
    {
        my $event_field = $self->make_field("event_$i", '+MusicBrainz::Server::Form::Field::ReleaseEvent');
        $self->add_field($event_field);
    }
}

sub mod_type { ModDefs::MOD_ADD_RELEASE }

sub build_options
{
    my ($self, $artists_id_map) = @_;

    my $opts = {
        AlbumName => $self->value('title'),
        artist    => $self->item->id,
    };

    for my $i (1 .. $self->track_count)
    {
        $opts->{"Track$i"}    = $self->value("track_$i")->{name};
        $opts->{"ArtistID$i"} = $artists_id_map->{"artist_$i"}->{id};
        $opts->{"TrackDur$i"} = $self->value("track_$i")->{duration};
    }

    return $opts;
}

1;
