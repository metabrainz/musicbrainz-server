package MusicBrainz::Server::Controller::Attributes;
use Moose;
use namespace::autoclean;
use utf8;

use MusicBrainz::Server::Data::Utils qw( contains_string );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

BEGIN { extends 'MusicBrainz::Server::Controller' }

my @entity_type_models = qw(
    AreaType
    ArtistType
    CollectionType
    EventType
    InstrumentType
    LabelType
    PlaceType
    ReleaseGroupType
    ReleaseGroupSecondaryType
    SeriesType
    WorkType
);

my @alias_type_models = qw(
    AreaAliasType
    ArtistAliasType
    EventAliasType
    GenreAliasType
    InstrumentAliasType
    LabelAliasType
    PlaceAliasType
    RecordingAliasType
    ReleaseAliasType
    ReleaseGroupAliasType
    SeriesAliasType
    WorkAliasType
);

my @other_models = qw(
    CoverArtType
    Gender
    Language
    MediumFormat
    ReleaseStatus
    ReleasePackaging
    Script
    WorkAttributeType
);

my @all_models = (@entity_type_models, @alias_type_models, @other_models);
# Missing: WorkAttributeTypeAllowedValue

sub index : Path('/attributes') Args(0) {
    my ($self, $c) = @_;

    $c->stash(
        current_view => 'Node',
        component_path => 'attributes/AttributesList',
        component_props => {
            aliasTypeModels => \@alias_type_models,
            entityTypeModels => \@entity_type_models,
            otherModels => \@other_models,
        },
    );
}

sub attribute_base : Chained('/') PathPart('attributes') CaptureArgs(1) {
    my ($self, $c, $model) = @_;

    $c->detach('/error_404') unless contains_string(\@all_models, $model);

    $c->stash->{model} = $model;
}

sub attribute_index : Chained('attribute_base') PathPart('') {
    my ($self, $c) = @_;
    my $model = $c->stash->{model};
    my @attr = $c->model($model)->get_all();

    my %component_paths = (
        Language => 'attributes/Language',
        Script => 'attributes/Script',
    );
    my $component_path = $component_paths{$model} // 'attributes/Attribute';

    $c->stash(
        current_view => 'Node',
        component_path => $component_path,
        component_props => {
            attributes => to_json_array(\@attr),
            model => $model,
        },
    );
}

sub create : Chained('attribute_base') RequireAuth(relationship_editor) SecureForm {
    my ($self, $c) = @_;
    my $model = $c->stash->{model};

    my %forms = (
        Language => 'Attributes::Language',
        Script => 'Attributes::Script',
    );
    my $form_name = $forms{$model} // 'Attributes::Generic';
    my $form = $c->form( form => $form_name );

    if ($c->form_posted_and_valid($form)) {
        $c->model('MB')->with_transaction(sub {
            $c->model($model)->insert({ map { $_->name => $_->value } $form->edit_fields });
        });

        $c->response->redirect($c->uri_for('/attributes', $model));
        $c->detach;
    }
}

sub edit : Chained('attribute_base') Args(1) RequireAuth(relationship_editor) SecureForm {
    my ($self, $c, $id) = @_;
    my $model = $c->stash->{model};
    my $attr = $c->model($model)->get_by_id($id);

    my %forms = (
        Language => 'Attributes::Language',
        Script => 'Attributes::Script',
    );
    my $form_name = $forms{$model} // 'Attributes::Generic';
    my $form = $c->form( form => $form_name, init_object => $attr );

    if ($c->form_posted_and_valid($form)) {
        $c->model('MB')->with_transaction(sub {
            $c->model($model)->update($id, { map { $_->name => $_->value } $form->edit_fields });
        });

        $c->response->redirect($c->uri_for('/attributes', $model));
        $c->detach;
    }
}

sub delete : Chained('attribute_base') Args(1) RequireAuth(relationship_editor) SecureForm {
    my ($self, $c, $id) = @_;
    my $model = $c->stash->{model};
    my $attr = $c->model($model)->get_by_id($id)
        or $c->detach(
            '/error_404',
            [ "Found no attribute of type “$model” with ID “$id”." ],
        );
    my $form = $c->form(form => 'SecureConfirm');
    $c->stash->{attribute} = $attr;

    if ($c->model($model)->in_use($id)) {
        my $attr_name = $attr->name;
        my $error_message = "You cannot remove the attribute “$attr_name” because it is still in use.";

        $c->stash(
            current_view => 'Node',
            component_path => 'attributes/CannotRemoveAttribute',
            component_props => {message => $error_message},
        );

        $c->detach;
    }

    if ($c->model($model)->has_children($id)) {
        my $attr_name = $attr->name;
        my $error_message = "You cannot remove the attribute “$attr_name” because it is the parent of other attributes.";

        $c->stash(
            current_view => 'Node',
            component_path => 'attributes/CannotRemoveAttribute',
            component_props => {message => $error_message},
        );

        $c->detach;
    }

    $c->stash(
        component_path  => 'attributes/DeleteAttribute',
        component_props => {
            attribute => $attr->TO_JSON,
            form => $form->TO_JSON,
        },
        current_view    => 'Node',
    );

    if ($c->form_posted_and_valid($form)) {
        if ($form->field('cancel')->input) {
            # Do nothing
        } else {
            $c->model('MB')->with_transaction(sub {
                $c->model($model)->delete($id);
            });
        }

        $c->response->redirect($c->uri_for('/attributes', $model));
        $c->detach;
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
