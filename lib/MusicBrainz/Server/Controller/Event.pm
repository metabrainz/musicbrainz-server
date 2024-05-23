package MusicBrainz::Server::Controller::Event;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;
use MusicBrainz::Server::Constants qw(
    $EDIT_EVENT_CREATE
    $EDIT_EVENT_EDIT
    $EDIT_EVENT_MERGE
    $EDIT_EVENT_ADD_EVENT_ART
    $EDIT_EVENT_EDIT_EVENT_ART
    $EDIT_EVENT_REMOVE_EVENT_ART
    $EDIT_EVENT_REORDER_EVENT_ART
);

extends 'MusicBrainz::Server::Controller';

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'Event',
    entity_name => 'event',
    relationships   => { all => ['show'], cardinal => ['edit'], default => ['url'] },
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Art' => {
    art_archive_name => 'event',
    art_archive_model_name => 'EventArtArchive',
    add_art_edit_type => $EDIT_EVENT_ADD_EVENT_ART,
    edit_art_edit_type => $EDIT_EVENT_EDIT_EVENT_ART,
    remove_art_edit_type => $EDIT_EVENT_REMOVE_EVENT_ART,
    reorder_art_edit_type => $EDIT_EVENT_REORDER_EVENT_ART,
};
with 'MusicBrainz::Server::Controller::Role::Cleanup';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::Rating';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';
with 'MusicBrainz::Server::Controller::Role::CommonsImage';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';
with 'MusicBrainz::Server::Controller::Role::Collection' => {
    entity_type     => 'event',
};

use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

use Sql;

=head2 base

Base action to specify that all actions live in the C<event>
namespace

=cut

sub base : Chained('/') PathPart('event') CaptureArgs(0) { }

after 'load' => sub {
    my ($self, $c) = @_;

    my $event = $c->stash->{event};

    my $event_model = $c->model('Event');
    $event_model->load_meta($event);
    if ($c->user_exists) {
        $event_model->rating->load_user_ratings($c->user->id, $event);
    }

    $c->model('EventType')->load($event);

    if ($event->may_have_event_art) {
        my $artwork =
            $c->model('EventArt')->find_front_artwork_by_event($event);
        $c->stash->{event_artwork} = $artwork->[0];

        my $artwork_count =
            $c->model('EventArt')->find_count_by_event($event->id);
        $c->stash->{event_artwork_count} = $artwork_count;
    }
};

# Stuff that has the side bar and thus needs to display collection information
after [qw( show collections details tags ratings aliases
           event_art add_event_art edit_event_art reorder_event_art)] => sub {
    my ($self, $c) = @_;
    $self->_stash_collections($c);
};

=head2 show

Shows an event's main landing page.

=cut

sub show : PathPart('') Chained('load') {
    my ($self, $c) = @_;
    my $event = $c->stash->{event};

    $c->model('Event')->load_performers($event);
    $c->model('Relationship')->load($event->related_series);

    my %props = (
        event             => $c->stash->{event}->TO_JSON,
        numberOfRevisions => $c->stash->{number_of_revisions},
        wikipediaExtract  => to_json_object($c->stash->{wikipedia_extract}),
    );

    $c->stash(
        component_path => 'event/EventIndex',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub _merge_load_entities {
    my ($self, $c, @events) = @_;
    $c->model('Event')->load_related_info(@events);
}

=head2 WRITE METHODS

=cut

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_EVENT_MERGE,
};

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Event',
    edit_type => $EDIT_EVENT_CREATE,
    dialog_template => 'event/edit_form.tt',
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'Event',
    edit_type      => $EDIT_EVENT_EDIT,
};

before qw( create edit ) => sub {
    my ($self, $c) = @_;
    my %event_types = map {$_->id => $_} $c->model('EventType')->get_all();
    $c->stash->{event_types} = \%event_types;
};

1;
