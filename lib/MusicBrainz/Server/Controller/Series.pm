package MusicBrainz::Server::Controller::Series;
use JSON;
use Moose;
use MusicBrainz::Server::Constants qw(
    $EDIT_SERIES_CREATE
    $EDIT_SERIES_EDIT
    $EDIT_SERIES_MERGE
);
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
use MusicBrainz::Server::Translation qw( l );

BEGIN { extends 'MusicBrainz::Server::Controller'; }

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model           => 'Series',
    entity_name     => 'series',
    relationships => {
        cardinal => ['edit'],
        subset => {show => ['artist', 'label', 'place', 'series', 'url']},
        default => ['url']
    },
};
with 'MusicBrainz::Server::Controller::Role::LoadWithRowID';
with 'MusicBrainz::Server::Controller::Role::Annotation';
with 'MusicBrainz::Server::Controller::Role::Alias';
with 'MusicBrainz::Server::Controller::Role::Cleanup';
with 'MusicBrainz::Server::Controller::Role::Details';
with 'MusicBrainz::Server::Controller::Role::Tag';
with 'MusicBrainz::Server::Controller::Role::EditListing';
with 'MusicBrainz::Server::Controller::Role::Subscribe';
with 'MusicBrainz::Server::Controller::Role::EditRelationships';
with 'MusicBrainz::Server::Controller::Role::WikipediaExtract';
with 'MusicBrainz::Server::Controller::Role::CommonsImage';
with 'MusicBrainz::Server::Controller::Role::Collection' => {
    entity_type => 'series'
};

sub base : Chained('/') PathPart('series') CaptureArgs(0) { }

after load => sub {
    my ($self, $c) = @_;

    my $series = $c->stash->{series};

    $c->model('SeriesType')->load($series);
    $c->model('SeriesOrderingType')->load($series);

    if ($c->user_exists) {
        $c->stash->{subscribed} = $c->model('Series')
            ->subscription->check_subscription($c->user->id, $series->id);
    }
};

sub show : PathPart('') Chained('load') {
    my ($self, $c) = @_;

    my $series = $c->stash->{series};

    my $items = $self->_load_paged($c, sub {
        $c->model('Series')->get_entities($series, shift, shift);
    });

    my @entities;
    my @item_numbers;

    for (@$items) {
        push @entities, $_->{entity};
        push @item_numbers, $_->{ordering_key};
    }

    if ($series->type->item_entity_type eq 'artist') {
        $c->model('Artist')->load_related_info(@entities);
        $c->model('Artist')->load_meta(@entities);
        $c->model('Artist')->rating->load_user_ratings($c->user->id, @entities) if $c->user_exists;
    }

    if ($series->type->item_entity_type eq 'event') {
        $c->model('Event')->load_related_info(@entities);
        $c->model('Event')->load_areas(@entities);
        $c->model('Event')->load_meta(@entities);
        $c->model('Event')->rating->load_user_ratings($c->user->id, @entities) if $c->user_exists;
    }

    if ($series->type->item_entity_type eq 'recording') {
        $c->model('ISRC')->load_for_recordings(@entities);
        $c->model('ArtistCredit')->load(@entities);
        $c->model('Recording')->load_meta(@entities);
        $c->model('Recording')->rating->load_user_ratings($c->user->id, @entities) if $c->user_exists;
    }

    if ($series->type->item_entity_type eq 'release') {
        $c->model('Release')->load_related_info(@entities);
        $c->model('ArtistCredit')->load(@entities);
    }

    if ($series->type->item_entity_type eq 'release_group') {
        $c->model('ArtistCredit')->load(@entities);
        $c->model('ReleaseGroupType')->load(@entities);
        $c->model('ReleaseGroup')->load_meta(@entities);
        $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, @entities) if $c->user_exists;
    }

    if ($series->type->item_entity_type eq 'work') {
        $c->model('Work')->load_related_info(@entities);
        $c->model('Work')->load_meta(@entities);
        $c->model('Work')->rating->load_user_ratings($c->user->id, @entities) if $c->user_exists;
    }

    my %props = (
        entities          => to_json_array(\@entities),
        numberOfRevisions => $c->stash->{number_of_revisions},
        pager             => serialize_pager($c->stash->{pager}),
        series            => $series->TO_JSON,
        seriesItemNumbers => \@item_numbers,
        wikipediaExtract  => to_json_object($c->stash->{wikipedia_extract}),
    );

    $c->stash(
        component_path => 'series/SeriesIndex',
        component_props => \%props,
        current_view => 'Node',
    );
}

after [qw( show collections details tags aliases subscribers )] => sub {
    my ($self, $c) = @_;
    $self->_stash_collections($c);
};

with 'MusicBrainz::Server::Controller::Role::Merge' => {
    edit_type => $EDIT_SERIES_MERGE,
};

sub _merge_load_entities {
    my ($self, $c, @series) = @_;

    $c->model('Relationship')->load(@series);
    $c->model('SeriesType')->load(@series);
    $c->model('SeriesOrderingType')->load(@series);
}

around _merge_submit => sub {
    my ($orig, $self, $c, $form, $entities) = @_;

    my %entity_types = map { $_->type->item_entity_type => 1 } @$entities;

    if (scalar(keys %entity_types) == 1) {
        $self->$orig($c, $form, $entities);
    } else {
        $form->field('target')->add_error(
            l('Series that have different entity types cannot be merged.')
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

before qw( edit create ) => sub {
    my ($self, $c) = @_;

    my $series_types = {
        map { $_->id => $_->TO_JSON } $c->model('SeriesType')->get_all
    };

    my $series_ordering_types = {
        map { $_->id => $_->TO_JSON } $c->model('SeriesOrderingType')->get_all
    };

    $c->stash(
        series_types => $series_types,
        series_ordering_types => $series_ordering_types,
    );
};

1;
