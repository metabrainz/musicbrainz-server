package MusicBrainz::Server::Form::AddRelease::Tracks;

use strict;
use warnings;

use base 'MusicBrainz::Server::Form';

use MusicBrainz::Server::Release;

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
            release_type => 'Select',
            release_status => 'Select',
            language => 'Select',
            script   => 'Select',
        }
    });
}

sub options_release_type
{
    my $self = shift;

    map {
        $_ => MusicBrainz::Server::Release::attribute_name($_),
    } (MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_START ..
       MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END)
}

sub options_release_status
{
    my $self = shift;

    map {
        $_ => MusicBrainz::Server::Release::attribute_name($_),
    } (MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_START ..
       MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_END)
}

sub options_language
{
    my $self = shift;

    my $mb = new MusicBrainz;
    $mb->Login;

    my $c = MusicBrainz::Server::Language->new($mb->{dbh});

    return map { $_->id => $_->name } $c->All;
}

sub options_script
{
    my $self = shift;

    my $mb = new MusicBrainz;
    $mb->Login;

    my $c = MusicBrainz::Server::Script->new($mb->{dbh});

    return map { $_->id => $_->name } $c->All;
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

sub cross_validate {
    my ($self) = @_;

    my $last_seq = 0;
    for my $i (1 .. $self->track_count) {
        my $track = $self->value("track_$i");
        next if $track->{remove};

        if ($track->{number} != ($last_seq + 1)) {
            $self->field("track_$i")->sub_form->field('number')->add_error("Track numbers must be a continuous sequence starting from 1");
        }

        $last_seq++;
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

1;
