package MusicBrainz::Server::Controller::Series;
use JSON;
use Moose;
use MusicBrainz::Server::Constants qw(
    $EDIT_SERIES_CREATE
    $EDIT_SERIES_DELETE
    $EDIT_SERIES_EDIT
    $EDIT_SERIES_MERGE
);
use MusicBrainz::Server::Translation qw( l );

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model       => 'Series',
    entity_name => 'series',
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Cleanup';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::Subscribe';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';

sub base : Chained('/') PathPart('series') CaptureArgs(0) { }

after load => sub {
    my ($self, $c) = @_;

    my $series = $c->stash->{series};

    if ($c->user_exists) {
        $c->stash->{subscribed} = $c->model('Series')
            ->subscription->check_subscription($c->user->id, $series->id);
    }

    $self->_load_entities($c, $series);
};

sub show : PathPart('') Chained('load') {
    my ($self, $c) = @_;

    my $entities = $self->_load_paged($c, sub {
        $c->model('Series')->get_entities($c->stash->{series}, shift, shift);
    });

    $c->stash(
        template => 'series/index.tt',
        entities => $entities,
    );
}

sub _load_entities {
    my ($self, $c, @series) = @_;

    $c->model('Relationship')->load(@series);
    $c->model('SeriesType')->load(@series);
    $c->model('SeriesOrderingType')->load(@series);
    $c->model('LinkAttributeType')->load(@series);
}

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_SERIES_MERGE,
};

sub _merge_load_entities {
    my ($self, $c, @series) = @_;

    $self->_load_entities($c, @series);
}

around _merge_submit => sub {
    my ($orig, $self, $c, $form, $entities) = @_;

    my %ordering_attributes = map { $_->ordering_attribute => 1 } @$entities;
    my %entity_types = map { $_->type->entity_type => 1 } @$entities;

    if (scalar(keys %ordering_attributes) == 1 && scalar(keys %entity_types) == 1) {
        $self->$orig($c, $form, $entities);
    } else {
        $form->field('target')->add_error(
            l('Series that contain different entity types, or have different ordering attributes cannot be merged.')
        );
    }
};

with 'MusicBrainz::Server::Controller::Role::Create' => {
    form      => 'Series',
    edit_type => $EDIT_SERIES_CREATE,
    dialog_template => 'series/edit_form.tt',
};

with 'MusicBrainz::Server::Controller::Role::Edit' => {
    form           => 'Series',
    edit_type      => $EDIT_SERIES_EDIT,
};

with 'MusicBrainz::Server::Controller::Role::Delete' => {
    edit_type      => $EDIT_SERIES_DELETE,
};

before qw( edit create ) => sub {
    my ($self, $c) = @_;

    my $series_types = {
        map { $_->id => $_->to_json_hash } $c->model('SeriesType')->get_all
    };

    my $series_ordering_types = {
        map { $_->id => $_->to_json_hash } $c->model('SeriesOrderingType')->get_all
    };

    $c->stash(
        series_types => encode_json($series_types),
        series_ordering_types => encode_json($series_ordering_types),
    );
};

1;
