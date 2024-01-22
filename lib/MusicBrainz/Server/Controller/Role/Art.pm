package MusicBrainz::Server::Controller::Role::Art;
use MooseX::MethodAttributes::Role;
use MooseX::Role::Parameterized;
use namespace::autoclean;

use HTTP::Status qw( :constants );
use List::AllUtils qw( first );
use Scalar::Util qw( looks_like_number );

use DBDefs;
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::ControllerUtils::Delete qw( cancel_or_action );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

parameter 'art_archive_name' => (
    isa => 'Str',
    required => 1,
);

parameter 'art_archive_model_name' => (
    isa => 'Str',
    required => 1,
);

parameter 'add_art_edit_type' => (
    isa => 'Int',
    required => 1,
);

parameter 'edit_art_edit_type' => (
    isa => 'Int',
    required => 1,
);

parameter 'remove_art_edit_type' => (
    isa => 'Int',
    required => 1,
);

parameter 'reorder_art_edit_type' => (
    isa => 'Int',
    required => 1,
);

role {
    my $params = shift;
    my %extra = @_;

    my $archive = $params->art_archive_name;
    my $art_archive_model_name = $params->art_archive_model_name;

    $extra{consumer}->name->config(
        action => {
            "${archive}_art" => {
                Chained => 'load',
                PathPart => "$archive-art",
            },
            "${archive}_art_uploaded" => {
                Chained => 'load',
                PathPart => "$archive-art-uploaded",
            },
            "add_${archive}_art" => {
                Chained => 'load',
                PathPart => "add-$archive-art",
                Edit => undef,
            },
            "edit_${archive}_art" => {
                Chained => 'load',
                PathPart => "edit-$archive-art",
                Args => 1,
                Edit => undef,
            },
            "remove_${archive}_art" => {
                Chained => 'load',
                PathPart => "remove-$archive-art",
                Args => 1,
                Edit => undef,
            },
            "reorder_${archive}_art" => {
                Chained => 'load',
                PathPart => "reorder-$archive-art",
                Edit => undef,
            },
        },
    );

    my $may_have_art = sub {
        my ($entity) = @_;

        my $may_have_art_method = "may_have_${archive}_art";
        return $entity->$may_have_art_method;
    };

    my $get_entity = sub {
        my ($c) = @_;
        my $entity = $c->stash->{entity};
        my $entity_model = $c->model($art_archive_model_name)->entity_model;
        if ($entity_model->can('load_meta')) {
            $entity_model->load_meta($entity);
        }
        return $entity;
    };

    method _entity_art_page => sub : Private {
        my ($self, $c, $entity) = @_;
        $c->uri_for_action(
            '/' . $entity->entity_type . "/${archive}_art",
            [ $entity->gid ],
        );
    };

    method _redirect_to_entity_art_page => sub : Private {
        my ($self, $c, $entity) = @_;
        $c->response->redirect($self->_entity_art_page($c, $entity));
    };

    method _load_artwork => sub : Private {
        my ($self, $c, $entity, $artwork_id) = @_;

        my $all_artwork = [];
        if ($may_have_art->($entity)) {
            my $art_archive_model = $c->model($art_archive_model_name);
            $all_artwork =
                $art_archive_model->art_model->find_by_entity([$entity]);
            $art_archive_model->art_type_model->load_for(@$all_artwork);
        }

        my $artwork;
        if (defined $artwork_id) {
            $artwork = first { $_->id == $artwork_id } @$all_artwork;
            $c->detach('/error_404', [
                l('Found no artwork with ID “{id}”.',
                { id => $artwork_id },
            )]) unless defined $artwork;
        }

        return ($all_artwork, $artwork);
    };

    method _darkened_check => sub : Private {
        my ($self, $c, $entity) = @_;

        if (!$may_have_art->($entity)) {
            my $art_archive_model = $c->model($art_archive_model_name);
            my $entity_type = $art_archive_model->art_archive_entity;
            $c->stash(
                current_view => 'Node',
                component_path => "$entity_type/" .
                    $art_archive_model->art_model_name . 'Darkened',
                component_props => {
                    $entity_type => $entity->TO_JSON,
                },
            );
            $c->detach;
        }
    };

    method "${archive}_art" => sub :
        Chained('load')
        PathPart("$archive-art")
    {
        my ($self, $c) = @_;

        my $entity = $get_entity->($c);
        my $art_archive_model = $c->model($art_archive_model_name);
        my $entity_type = $art_archive_model->art_archive_entity;

        my ($all_artwork) = $self->_load_artwork($c, $entity);

        $c->stash(
            # Needed for JSON-LD
            "${archive}_art" => $all_artwork,
            current_view => 'Node',
            component_path => "$entity_type/" .
                $art_archive_model->art_model_name,
            component_props => {
                "${archive}Art" => to_json_array($all_artwork),
                $entity_type => $entity->TO_JSON,
            },
        );
    };

    method "${archive}_art_uploaded" => sub :
        Chained('load')
        PathPart("$archive-art-uploaded")
    {
        my ($self, $c) = @_;

        $c->stash->{filename} = $c->req->params->{key};
    };

    method "add_${archive}_art" => sub :
        Chained('load')
        PathPart("add-$archive-art")
        Edit
    {
        my ($self, $c) = @_;

        my $entity = $get_entity->($c);
        my $art_archive_model = $c->model($art_archive_model_name);
        my $entity_type = $art_archive_model->art_archive_entity;

        $self->_darkened_check($c, $entity);

        my ($all_artwork) = $self->_load_artwork($c, $entity);

        my $artwork_id = $art_archive_model->fresh_id;

        $c->stash({
            id => $artwork_id,
            index_url => $art_archive_model->download_prefix .
                '/' . $ENTITIES{$entity_type}{url} .
                '/' . $entity->gid . '/',
            images => $all_artwork,
            mime_types => [ map {
                $_->{mime_type}
            } @{ $art_archive_model->mime_types } ],
            access_key => DBDefs->INTERNET_ARCHIVE_ACCESS_KEY // '',
            "${archive}_art_types_json" => $c->json->encode(
                [ map {
                    { name => $_->name, l_name => $_->l_name, id => $_->id }
                } $art_archive_model->art_type_model->get_all ],
            ),
        });

        my $form = $c->form(
            form => $art_archive_model->entity_model_name .
                '::Add' . $art_archive_model->art_model_name,
            item => {
                id => $artwork_id,
                position => 1,
            },
        );

        my $accept = $c->req->header('Accept');
        my $returning_json = defined $accept &&
            $accept =~ m{\bapplication/json\b};

        if ($c->form_posted_and_valid($form)) {
            $c->model('MB')->with_transaction(sub {
                $self->_insert_edit(
                    $c, $form,
                    edit_type => $params->add_art_edit_type,
                    $entity_type => $entity,
                    "${archive}_art_types" => [
                        grep { defined $_ && looks_like_number($_) }
                            @{ $form->field('type_id')->value },
                        ],
                    "${archive}_art_position" =>
                        $form->field('position')->value,
                    "${archive}_art_id" => $form->field('id')->value,
                    "${archive}_art_comment" =>
                        $form->field('comment')->value || '',
                    "${archive}_art_mime_type" =>
                        $form->field('mime_type')->value,
                );
            });

            unless ($returning_json) {
                $self->_redirect_to_entity_art_page($c, $entity);
                $c->detach;
            }
        } elsif ($c->form_posted) {
            $c->response->status(HTTP_INTERNAL_SERVER_ERROR);
        } elsif (%{ $c->req->query_params }) {
            # Process query parameters to support seeding fields.
            my $merged = { ( %{$form->fif}, %{$c->req->query_params} ) };
            $form->process( params => $merged );
            $form->clear_errors;
        }

        if ($returning_json) {
            $c->response->body($c->json_utf8->encode($form->TO_JSON));
            $c->response->content_type('application/json; charset=utf-8');
        }
    };

    method "edit_${archive}_art" => sub :
        Chained('load')
        PathPart("edit-$archive-art")
        Args(1)
        Edit
    {
        my ($self, $c, $artwork_id) = @_;

        my $entity = $get_entity->($c);
        my $art_archive_model = $c->model($art_archive_model_name);
        my $entity_type = $art_archive_model->art_archive_entity;

        my ($all_artwork, $artwork) =
            $self->_load_artwork($c, $entity, $artwork_id);

        $c->stash({
            artwork => $artwork,
            images => $all_artwork,
            index_url => $art_archive_model->download_prefix .
                '/' . $ENTITIES{$entity_type}{url} .
                '/' . $entity->gid . '/',
        });

        my @type_ids = map { $_->id }
            $art_archive_model->art_type_model->get_by_name(
                @{ $artwork->type_names },
            );

        my $form = $c->form(
            form => $art_archive_model->entity_model_name .
                '::Edit' . $art_archive_model->art_model_name,
            item => {
                id => $artwork_id,
                type_id => \@type_ids,
                comment => $artwork->comment,
            },
        );

        if ($c->form_posted_and_valid($form)) {
            $c->model('MB')->with_transaction(sub {
                $self->_insert_edit(
                    $c, $form,
                    edit_type => $params->edit_art_edit_type,
                    $entity_type => $entity,
                    artwork_id => $artwork->id,
                    old_types => [
                        grep { defined $_ && looks_like_number($_) }
                            @type_ids,
                    ],
                    old_comment => $artwork->comment,
                    new_types => [
                        grep { defined $_ && looks_like_number($_) }
                            @{ $form->field('type_id')->value },
                    ],
                    new_comment => $form->field('comment')->value || '',
                );
            });

            $self->_redirect_to_entity_art_page($c, $entity);
            $c->detach;
        }
    };

    method "remove_${archive}_art" => sub :
        Chained('load')
        PathPart("remove-$archive-art")
        Args(1)
        Edit
    {
        my ($self, $c, $artwork_id) = @_;

        my $entity = $get_entity->($c);
        my $art_archive_model = $c->model($art_archive_model_name);
        my $entity_type = $art_archive_model->art_archive_entity;

        my ($all_artwork, $artwork) =
            $self->_load_artwork($c, $entity, $artwork_id);

        $c->stash( artwork => $all_artwork );

        my $edit = $c->model('Edit')->find_creation_edit(
            $params->add_art_edit_type,
            $artwork->id,
            id_field => "${archive}_art_id",
        );
        cancel_or_action(
            $c,
            $edit,
            $self->_entity_art_page($c, $entity),
            sub {
                $self->edit_action($c,
                    form        => 'Confirm',
                    form_args   => { requires_edit_note => 1 },
                    type        => $params->remove_art_edit_type,
                    edit_args   => {
                        $entity_type => $entity,
                        to_delete => $artwork,
                    },
                    on_creation => sub {
                        $self->_redirect_to_entity_art_page($c, $entity);
                    },
                );
            },
        );

        $c->stash(
            current_view => 'Node',
            component_path => "$entity_type/Remove" .
                $art_archive_model->art_model_name,
            component_props => {
                artwork => $artwork->TO_JSON,
                form => $c->stash->{form}->TO_JSON,
                $entity_type => $entity->TO_JSON,
            },
        );
    };

    method "reorder_${archive}_art" => sub :
        Chained('load')
        PathPart("reorder-$archive-art")
        Edit
    {
        my ($self, $c) = @_;

        my $entity = $get_entity->($c);
        my $art_archive_model = $c->model($art_archive_model_name);
        my $entity_type = $art_archive_model->art_archive_entity;

        $self->_darkened_check($c, $entity);

        my ($all_artwork) = $self->_load_artwork($c, $entity);

        $c->stash( images => $all_artwork );

        my $count = 1;
        my @positions = map {
            { id => $_->id, position => $count++ }
        } @$all_artwork;

        my $form = $c->form(
            form => $art_archive_model->entity_model_name .
                '::Reorder' . $art_archive_model->art_model_name,
            init_object => { artwork => \@positions },
        );
        if ($c->form_posted_and_valid($form)) {
            $c->model('MB')->with_transaction(sub {
                $self->_insert_edit(
                    $c, $form,
                    edit_type => $params->reorder_art_edit_type,
                    $entity_type => $entity,
                    old => \@positions,
                    new => $form->field('artwork')->value,
                );
            });

            $self->_redirect_to_entity_art_page($c, $entity);
            $c->detach;
        }
    };
};

no Moose::Role;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
