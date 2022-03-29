package MusicBrainz::Server::Controller::Collection;
use Moose;
use Scalar::Util qw( looks_like_number );
use List::AllUtils qw( first uniq );

BEGIN { extends 'MusicBrainz::Server::Controller' };

with 'MusicBrainz::Server::Controller::Role::Load' => {
    entity_name => 'collection',
    model       => 'Collection',
};
with 'MusicBrainz::Server::Controller::Role::Subscribe';

use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Data::Utils qw(
    boolean_to_json
    load_everything_for_edits
    type_to_model
);
use MusicBrainz::Server::Constants qw( :edit_status entities_with );
use MusicBrainz::Server::Entity::Util::JSON qw(
    to_json_array
    to_json_object
);

sub base : Chained('/') PathPart('collection') CaptureArgs(0) { }

after 'load' => sub {
    my ($self, $c) = @_;
    my $collection = $c->stash->{collection};

    if ($c->user_exists) {
        $c->stash->{subscribed} = $c->model('Collection')->subscription->check_subscription(
            $c->user->id, $collection->id);
    }

    $c->model('Collection')->load_entity_count($collection);
    # Load editor and collaborators
    $c->model('Editor')->load_for_collection($collection);
    $c->model('CollectionType')->load($collection);

    my $is_collection_collaborator = $c->user_exists &&
        $c->model('Collection')->is_collection_collaborator($c->user->id, $collection->id);

    $c->stash(
        is_collection_collaborator => $is_collection_collaborator,
    )
};

sub own_collection : Chained('load') CaptureArgs(0) RequireAuth {
    my ($self, $c) = @_;

    my $collection = $c->stash->{collection};
    $c->detach('/error_403') if $c->user->id != $collection->editor_id;
}

sub collection_collaborator : Chained('load') CaptureArgs(0) RequireAuth {
    my ($self, $c) = @_;

    $c->detach('/error_403') if !$c->stash->{is_collection_collaborator};
}

sub _do_add_or_remove {
    my ($self, $c, $func_name) = @_;

    my $collection = $c->stash->{collection};
    my $entity_type = $collection->type->item_entity_type;
    my $entity_id = $c->request->params->{$entity_type};

    if ($entity_id) {
        my $entity = $c->model(type_to_model($entity_type))->get_by_id($entity_id);

        $c->model('Collection')->$func_name($entity_type, $collection->id, $entity_id);

        $c->redirect_back(
            fallback => $c->uri_for_action("/$entity_type/show", [ $entity->gid ]),
        );
        $c->detach;
    } else {
        $c->forward('show');
    }
}

sub add : Chained('collection_collaborator') RequireAuth {
    my ($self, $c) = @_;
    $self->_do_add_or_remove($c, 'add_entities_to_collection');
}

sub remove : Chained('collection_collaborator') RequireAuth {
    my ($self, $c) = @_;
    $self->_do_add_or_remove($c, 'remove_entities_from_collection');
}

sub show : Chained('load') PathPart('') {
    my ($self, $c) = @_;

    my $collection = $c->stash->{collection};
    my $entity_type = $collection->type->item_entity_type;

    if ($c->form_posted && $c->stash->{is_collection_collaborator}) {
        my $remove_params = $c->req->params->{remove};
        $c->model('Collection')->remove_entities_from_collection($entity_type,
            $collection->id,
            grep { looks_like_number($_) }
                ref($remove_params) ? @$remove_params : ($remove_params)
        );
    }

    $self->collection_collaborator($c) if !$collection->public;

    my $order = $c->req->params->{order};

    my $model = $c->model(type_to_model($entity_type));
    my $entities = $self->_load_paged($c, sub {
        $model->find_by_collection($collection->id, shift, shift, $order);
    });

    if ($model->can('load_related_info')) {
        $model->load_related_info(@$entities);
    }

    if ($model->can('load_meta')) {
        $model->load_meta(@$entities);
    }

    if ($model->does('MusicBrainz::Server::Data::Role::Rating') && $c->user_exists) {
        $model->rating->load_user_ratings($c->user->id, @$entities);
    }

    if ($entity_type eq 'area') {
        $c->model('AreaType')->load(@$entities);
        $c->model('Area')->load_containment(@$entities);
    } elsif ($entity_type eq 'artist') {
        $c->model('ArtistType')->load(@$entities);
        $c->model('Gender')->load(@$entities);
        $c->model('Area')->load(@$entities);
        $c->model('Area')->load_containment(map { $_->area } @$entities);
    } elsif ($entity_type eq 'instrument') {
        $c->model('InstrumentType')->load(@$entities);
    } elsif ($entity_type eq 'label') {
        $c->model('LabelType')->load(@$entities);
        $c->model('Area')->load(@$entities);
        $c->model('Area')->load_containment(map { $_->{area} } @$entities);
    } elsif ($entity_type eq 'release') {
        $c->model('ArtistCredit')->load(@$entities);
        $c->model('ReleaseGroup')->load(@$entities);
        $c->model('ReleaseGroup')->load_meta(map { $_->release_group } @$entities);
        if ($c->user_exists) {
            $c->model('ReleaseGroup')->rating->load_user_ratings($c->user->id, map { $_->release_group } @$entities);
        }
    } elsif ($entity_type eq 'release_group') {
        $c->model('ArtistCredit')->load(@$entities);
        $c->model('ReleaseGroupType')->load(@$entities);
        $c->model('ReleaseGroupSecondaryType')->load_for_release_groups(@$entities);
        $c->model('ReleaseGroup')->load_has_cover_art(@$entities);
    } elsif ($entity_type eq 'event') {
        $c->model('EventType')->load(@$entities);
        $model->load_performers(@$entities);
        $model->load_locations(@$entities);
    } elsif ($entity_type eq 'place') {
        $c->model('PlaceType')->load(@$entities);
        $c->model('Area')->load(@$entities);
        $c->model('Area')->load_containment(map { $_->area } @$entities);
    } elsif ($entity_type eq 'recording') {
        $c->model('ArtistCredit')->load(@$entities);
        $c->model('ISRC')->load_for_recordings(@$entities);
    } elsif ($entity_type eq 'series') {
        $c->model('SeriesType')->load(@$entities);
        $c->model('SeriesOrderingType')->load(@$entities);
    }

    my %props = (
        collection           => $collection->TO_JSON,
        collectionEntityType => $entity_type,
        entities             => to_json_array($entities),
        order                => $order,
        pager                => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        current_view => 'Node',
        component_path => 'collection/CollectionIndex.js',
        component_props => \%props,
    );
}

sub edits : Chained('load') PathPart RequireAuth {
    my ($self, $c) = @_;
    $self->_list_edits($c);
}

sub open_edits : Chained('load') PathPart RequireAuth {
    my ($self, $c) = @_;
    $self->_list_edits($c, 1);
}

sub _list_edits {
    my ($self, $c, $show_open_only) = @_;

    my $collection = $c->stash->{collection};

    $self->collection_collaborator($c) if !$collection->public;

    my $status = $show_open_only ? $STATUS_OPEN : undef;
    my $edits  = $self->_load_paged($c, sub {
        my ($limit, $offset) = @_;
        $c->model('Edit')->find_by_collection($collection->id, $limit, $offset, $status);
    });

    $c->stash(edits => $edits); # stash early in case an ISE occurs while loading the edits

    load_everything_for_edits($c, $edits);

    $c->stash(
        current_view => 'Node',
        component_path => 'entity/Edits',
        component_props => {
            editCountLimit => $c->stash->{edit_count_limit},
            edits => to_json_array($edits),
            entity => to_json_object($collection),
            pager => serialize_pager($c->stash->{pager}),
            showingOpenOnly => boolean_to_json($show_open_only),
        },
    );
}

sub _form_to_hash {
    my ($self, $form) = @_;
    return map { $form->field($_)->name => $form->field($_)->value } $form->edit_field_names;
}

sub _redirect_to_collection {
    my ($self, $c, $gid) = @_;
    $c->response->redirect($c->uri_for_action($self->action_for('show'), [ $gid ]));
}

sub create : Local RequireAuth {
    my ($self, $c) = @_;

    my $initial_entity_id;
    my $initial_entity_type;

    my @collection_types = $c->model('CollectionType')->get_all();

    for my $entity_type (entities_with('collections')) {
        my $initial_entity_param = $c->request->params->{$entity_type};
        if ($initial_entity_param) {
            if (ref($initial_entity_param) eq 'ARRAY') {
                # Can only insert one item.
                $initial_entity_id = $initial_entity_param->[0];
            } else {
                $initial_entity_id = $initial_entity_param;
            }
            $initial_entity_type = (first { $_->{item_entity_type} eq $entity_type } @collection_types);
            last;  # can create a collection with only one type of entity
        }
    }

    my $form;
    if ($initial_entity_type) {
        $form = $c->form( form => 'Collection', init_object => { allowed_entity_type => $initial_entity_type->item_entity_type, type_id => $initial_entity_type->id } );
    } else {
        $form = $c->form( form => 'Collection' );
    }

    if ($c->form_posted_and_valid($form)) {
        my %insert = $self->_form_to_hash($form);
        my $collection_ids = $c->model('Collection')->insert($c->user->id, \%insert);
        if ($initial_entity_id) {
            my $collection = $c->model('Collection')->get_by_gid($collection_ids->{gid});
            $c->model('CollectionType')->load($collection);
            # Avoid adding the entity if the collection entity type has changed somehow (MBS-11569)
            if ($initial_entity_type->item_entity_type eq $collection->type->item_entity_type) {
                $c->model('Collection')->add_entities_to_collection(
                    $initial_entity_type->item_entity_type, $collection->{id}, $initial_entity_id
                );
            }
        }

        $self->_redirect_to_collection($c, $collection_ids->{gid});
    }

    my %props = (
        collectionTypes => $form->options_type_id,
        form => $form->TO_JSON,
    );

    $c->stash(
        component_path => 'collection/CreateCollection',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub edit : Chained('own_collection') RequireAuth {
    my ($self, $c) = @_;

    my $collection = $c->stash->{collection};

    my $form = $c->form( form => 'Collection', init_object => $collection );

    if ($c->form_posted_and_valid($form)) {
        my %update = $self->_form_to_hash($form);

        $c->model('Collection')->update($collection->id, \%update);
        $self->_redirect_to_collection($c, $collection->gid);
    }

    my %props = (
        collection => $collection->TO_JSON,
        collectionTypes => $form->options_type_id,
        form => $form->TO_JSON,
    );

    $c->stash(
        component_path => 'collection/EditCollection',
        component_props => \%props,
        current_view => 'Node',
    );
}

with 'MusicBrainz::Server::Controller::Role::Merge';

sub _merge_form_arguments {
    my ($self, $c, @collections) = @_;

    return (requires_edit_note => 0);
}

sub _merge_load_entities {
    my ($self, $c, @collections) = @_;
    $c->model('Collection')->load_entity_count(@collections);
    $c->model('CollectionType')->load(@collections);

    for my $collection (@collections) {
        $c->model('Editor')->load_for_collection($collection);
    }

    my @entity_types = uniq map { $_->type->item_entity_type } @collections;
    my @privacy_settings = uniq map { $_->public } @collections;

    $c->stash(
        privacies_differ => @privacy_settings > 1,
        types_differ => @entity_types > 1,
    );
}

sub delete : Chained('own_collection') RequireAuth {
    my ($self, $c) = @_;

    my $collection = $c->stash->{collection};

    if ($c->form_posted) {
        $c->model('Collection')->delete($collection->id);

        $c->response->redirect(
            $c->uri_for_action('/user/collections', [ $c->user->name ]));
    }
    my %props = (
        collection => $collection->TO_JSON,
    );

    $c->stash(
        component_path => 'collection/DeleteCollection',
        component_props => \%props,
        current_view => 'Node',
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2010 Sean Burke

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
