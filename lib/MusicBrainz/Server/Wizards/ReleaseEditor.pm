package MusicBrainz::Server::Wizards::ReleaseEditor;
use Moose;
use MooseX::AttributeHelpers;
use MooseX::Storage;

use ModDefs;
use MusicBrainz::Server::Track;

with Storage;
with 'MusicBrainz::Server::Wizards::ReleaseEditor::ConfirmedArtist';

has 'name' => (
    isa => 'Str',
    is  => 'rw',
);

has 'id' => (
    isa => 'Int',
    is  => 'rw',
    clearer => 'clear_id',
    predicate => 'is_edit',
);

has 'tracks' => (
    isa => 'ArrayRef',
    is  => 'ro',
    default => sub { [] },
    metaclass => 'Collection::Array',
    provides => {
        get => 'get_track',
        count => 'track_count',
        push => 'add_track',
        clear => 'clear_tracks',
    }
);

has 'release_events' => (
    isa => 'ArrayRef',
    is  => 'ro',
    default => sub { [] },
    metaclass => 'Collection::Array',
    provides => {
        get => 'get_event',
        push => 'add_release_event',
        count => 'release_event_count',
        clear => 'clear_release_events',
    },
);

has 'has_checked_duplicates' => (
    isa => 'Bool',
    is  => 'rw',
    default => 0,
);

has ['release_type', 'release_status'] => (
    is  => 'rw',
);

has ['language', 'script'] => (
    is  => 'rw',
);

has 'edit_note' => ( is => 'rw' );

sub unconfirmed_artists
{
    my ($self) = @_;
    my @artists = grep { !$_->confirmed_artist } @{ $self->tracks };
    unshift @artists, $self unless $self->confirmed_artist;

    return \@artists;
}

sub has_unconfirmed_artists
{
    return scalar @{ shift->unconfirmed_artists } > 0;
}

sub unconfirmed_labels
{
    my ($self) = @_;
    return [ grep { $_->label && !$_->confirmed } @{ $self->release_events } ];
}

sub has_unconfirmed_labels
{
    return scalar @{ shift->unconfirmed_labels } > 0;
}

sub fill_in_form
{
    my ($self, $form) = @_;

    $form->field('title')->value($self->name);
    $form->field('release_artist')->value($self->artist);

    # Tracks
    $form->add_tracks($self->track_count, $self->artist);
    for my $i (1 .. $self->track_count)
    {
        my $track = $self->get_track($i - 1);
        $form->field("track_$i")->value($track->to_track);
        $form->field("track_$i")->sub_form->field('remove')->value($track->removed);
        $form->field("artist_$i")->value($track->artist);
    }

    # Release Events
    $form->add_events($self->release_event_count);
    for my $i (1 ... $self->release_event_count)
    {
        my $event = $self->get_event($i - 1);
        $form->field("event_$i")->value($event->to_event);
        $form->field("event_$i")->sub_form->field('remove')->value($event->removed);
    }

    $form->field('release_type')->value($self->release_type);
    $form->field('release_status')->value($self->release_status);
    $form->field('language')->value($self->language);
    $form->field('script')->value($self->script);
    $form->field('edit_note')->value($self->edit_note);
}

sub update
{
    my ($self, $form) = @_;

    $self->name($form->value('title'));
    $self->artist($form->value('release_artist'));

    # Update tracks and artists
    for my $i (1 .. $self->track_count)
    {
        my $track = $self->get_track($i - 1);
        $track->artist($form->value("artist_$i"));
        $track->name($form->value("track_$i")->{name});
        $track->sequence($form->value("track_$i")->{number});
        $track->duration($form->value("track_$i")->{duration});
        $track->removed($form->value("track_$i")->{remove});
    }

    # Update release events
    for my $i (1 .. $self->release_event_count)
    {
        my $event = $self->get_event($i - 1);
        $event->format($form->value("event_$i")->{format});
        $event->barcode($form->value("event_$i")->{barcode});
        $event->label($form->value("event_$i")->{label} || '');
        $event->country($form->value("event_$i")->{country});
        $event->catno($form->value("event_$i")->{catalog});
        $event->removed($form->value("event_$i")->{remove});
        $event->date($form->value("event_$i")->{date});
    }

    $self->language($form->value('language'));
    $self->script($form->value('script'));
    $self->release_type($form->value('release_type'));
    $self->release_status($form->value('release_status'));

    $self->edit_note($form->value('edit_note'));
}

sub to_release
{
    my ($self) = @_;

    my $track_count;
    for my $track (@{ $self->tracks }) {
        next if $track->removed;
        $track_count++;
    }

    my $rel = MusicBrainz::Server::Release->new(
        undef,
        name => $self->name,
        track_count => $track_count,
        language => $self->language,
        script => $self->script,
        quality => ModDefs::QUALITY_UNKNOWN,
    );

    $rel->attributes($self->release_type, $self->release_status);

    return $rel;
}

sub accepted_tracks
{
    my $self = shift;
    return [ grep { !$_->removed } @{ $self->tracks } ];
}

sub accepted_release_events
{
    my $self = shift;
    return [ grep { !$_->removed } @{ $self->release_events } ];
}

1;
