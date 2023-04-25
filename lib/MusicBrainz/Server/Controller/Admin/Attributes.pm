package MusicBrainz::Server::Controller::Admin::Attributes;
use Moose;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

use MusicBrainz::Server::Translation qw( l );

no if $] >= 5.018, warnings => 'experimental::smartmatch';

BEGIN { extends 'MusicBrainz::Server::Controller' };

my @models = qw(
    AreaType
    ArtistType
    CollectionType
    CoverArtType
    EventType
    Gender
    InstrumentType
    LabelType
    Language
    MediumFormat
    PlaceType
    ReleaseGroupType
    ReleaseGroupSecondaryType
    ReleaseStatus
    ReleasePackaging
    Script
    SeriesType
    WorkType
    WorkAttributeType
);
# Missing: Alias types, WorkAttributeTypeAllowedValue

sub index : Path('/admin/attributes') Args(0) RequireAuth(account_admin) {
    my ($self, $c) = @_;

    $c->stash(
        current_view => 'Node',
        component_path => 'admin/attributes/Index',
        component_props => {models => \@models}
    );
}

sub attribute_base : Chained('/') PathPart('admin/attributes') CaptureArgs(1) RequireAuth(account_admin) {
    my ($self, $c, $model) = @_;

    $c->detach('/error_404') unless $model ~~ @models;

    $c->stash->{model} = $model;
}

sub attribute_index : Chained('attribute_base') PathPart('') RequireAuth(account_admin) {
    my ($self, $c) = @_;
    my $model = $c->stash->{model};
    my @attr = $c->model($model)->get_all();

    my %component_paths = (
        Language => 'admin/attributes/Language',
        Script => 'admin/attributes/Script'
    );
    my $component_path = $component_paths{$model} // 'admin/attributes/Attribute';

    $c->stash(
        current_view => 'Node',
        component_path => $component_path,
        component_props => {
            attributes => to_json_array(\@attr),
            model => $model,
        }
    );
}

sub create : Chained('attribute_base') RequireAuth(account_admin) SecureForm {
    my ($self, $c) = @_;
    my $model = $c->stash->{model};

    my %forms = (
        Language => 'Admin::Attributes::Language',
        Script => 'Admin::Attributes::Script'
    );
    my $form_name = $forms{$model} // 'Admin::Attributes';
    my $form = $c->form( form => $form_name );

    if ($c->form_posted_and_valid($form)) {
        $c->model('MB')->with_transaction(sub {
            $c->model($model)->insert({ map { $_->name => $_->value } $form->edit_fields });
        });

        $c->response->redirect($c->uri_for('/admin/attributes', $model));
        $c->detach;
    }
}

sub edit : Chained('attribute_base') Args(1) RequireAuth(account_admin) SecureForm {
    my ($self, $c, $id) = @_;
    my $model = $c->stash->{model};
    my $attr = $c->model($model)->get_by_id($id);

    my %forms = (
        Language => 'Admin::Attributes::Language',
        Script => 'Admin::Attributes::Script'
    );
    my $form_name = $forms{$model} // 'Admin::Attributes';
    my $form = $c->form( form => $form_name, init_object => $attr );

    if ($c->form_posted_and_valid($form)) {
        $c->model('MB')->with_transaction(sub {
            $c->model($model)->update($id, { map { $_->name => $_->value } $form->edit_fields });
        });

        $c->response->redirect($c->uri_for('/admin/attributes', $model));
        $c->detach;
    }
}

sub delete : Chained('attribute_base') Args(1) RequireAuth(account_admin) SecureForm {
    my ($self, $c, $id) = @_;
    my $model = $c->stash->{model};
    my $attr = $c->model($model)->get_by_id($id);
    my $form = $c->form(form => 'SecureConfirm');
    $c->stash->{attribute} = $attr;

    if ($c->model($model)->in_use($id)) {
        my $error_message = l('You cannot remove the attribute "{name}" because it is still in use.', { name => $attr->name });

        $c->stash(
            current_view => 'Node',
            component_path => 'admin/attributes/CannotRemoveAttribute',
            component_props => {message => $error_message}
        );

        $c->detach;
    }

    if ($c->model($model)->has_children($id)) {
        my $error_message = l('You cannot remove the attribute “{name}” because it is the parent of other attributes.', { name => $attr->name });

        $c->stash(
            current_view => 'Node',
            component_path => 'admin/attributes/CannotRemoveAttribute',
            component_props => {message => $error_message}
        );

        $c->detach;
    }

    $c->stash(
        component_path  => 'admin/attributes/DeleteAttribute',
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

        $c->response->redirect($c->uri_for('/admin/attributes', $model));
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
