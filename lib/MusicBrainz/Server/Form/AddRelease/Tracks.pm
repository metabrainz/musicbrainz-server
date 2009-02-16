package MusicBrainz::Server::Form::AddRelease::Tracks;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use Rose::Object::MakeMethods::Generic(
    scalar => [ 'track_count', 'event_count' ]
);

sub name { 'add-release-tracks' }

sub profile
{
    shift->with_mod_fields({
        required => {
            title   => {
                type => 'Text',
                size => 50,
            },
            event_1 => '+MusicBrainz::Server::Form::Field::ReleaseEvent',
        },
        optional => {
            more_events => 'Checkbox',
        }
    });
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

sub insert
{
    my ($self, $artists_id_map, $labels_id_map) = @_;
    
    die "Not yet implemented!";
}

sub mod_type { ModDefs::MOD_ADD_RELEASE }

sub build_options
{
    my ($self, $artists_id_map, $labels_id_map) = @_;

    my $opts = {
        AlbumName => $self->value('title'),
        artist    => $self->item->id,
        HasMultipleTrackArtists => 1,
    };

    for my $i (1 .. $self->track_count)
    {
        $opts->{"Track$i"}    = $self->value("track_$i")->{name};
        $opts->{"ArtistID$i"} = $artists_id_map->{"artist_$i"}->{id};
        $opts->{"TrackDur$i"} = $self->value("track_$i")->{duration};
    }

    for my $i (1 .. $self->event_count)
    {
        my $event = $self->value("event_$i");
        $opts->{"Release$i"} = sprintf("%s,%s,%s,%s,%s,%s",
            $event->{country},
            $event->{date},
            $labels_id_map->{"event_$i.label"}->{id},
            $event->{catalog},
            $event->{barcode},
            $event->{format},
        );
    }

    return $opts;
}

1;
