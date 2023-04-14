package MusicBrainz::Server::Controller::Relationship::LinkAttributeType;
use Moose;
use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_ADD_ATTRIBUTE
    $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE
    $EDIT_RELATIONSHIP_ATTRIBUTE
    $INSTRUMENT_ROOT_ID
);
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );

use MusicBrainz::Server::Validation qw( is_guid );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'LinkAttributeType',
    entity_name => 'link_attr_type',
};

BEGIN { extends 'MusicBrainz::Server::Controller' };

sub _load_tree
{
    my ($self, $c) = @_;

    my $tree = $c->model('LinkAttributeType')->get_tree(sub {
        my $attribute_type = shift;
        return (
            $attribute_type->root_id != $INSTRUMENT_ROOT_ID ||
            $attribute_type->id == $INSTRUMENT_ROOT_ID
        );
    });
    $c->stash( root => $tree );
}

sub base : Chained('/') PathPart('relationship-attribute') CaptureArgs(0) { }

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    my $attribute = $c->model('LinkAttributeType')->get_tree(
        undef, # don't filter
        $c->stash->{link_attr_type}->{id}
    );
    my @relationships = $c->model('LinkType')->find_by_attribute($attribute->{id});

    my %props = (
        attribute => $attribute->TO_JSON,
        relationships => to_json_array(\@relationships),
    );

    $c->stash(
        component_path  => 'relationship/linkattributetype/RelationshipAttributeTypeIndex',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub list : Path('/relationship-attributes') Args(0)
{
    my ($self, $c) = @_;

    $self->_load_tree($c);

    $c->stash(
        component_path  => 'relationship/linkattributetype/RelationshipAttributeTypesList',
        component_props => {root => $c->stash->{root}->TO_JSON},
        current_view    => 'Node',
    );
}

sub create : Path('/relationship-attributes/create') Args(0) RequireAuth(relationship_editor)
{
    my ($self, $c) = @_;

    $self->_load_tree($c);
    my $form = $c->form( form => 'Admin::LinkAttributeType' );

    my $gid = $c->request->params->{parent};
    my $parent_link_attr_type;

    if (is_guid($gid)) {
        $parent_link_attr_type =
            $c->model('LinkAttributeType')->get_by_gid($gid);
    }

    if ($parent_link_attr_type) {
        $form->field('parent_id')->value($parent_link_attr_type->id);
    }

    if ($c->form_posted_and_valid($form)) {
        my $attribute_edit = $c->model('MB')->with_transaction(sub {
            $self->_insert_edit(
                $c, $form,
                edit_type => $EDIT_RELATIONSHIP_ADD_ATTRIBUTE,
                map { $_->name => $_->value } $form->edit_fields
            );
        });

        $c->response->redirect($c->uri_for_action('relationship/linkattributetype/show', [ $attribute_edit->entity_gid ]));
        $c->detach;
    }
}

sub edit : Chained('load') RequireAuth(relationship_editor)
{
    my ($self, $c, $gid) = @_;

    my $link_attr_type = $c->stash->{link_attr_type};

    my $is_instrument_child =
        $link_attr_type->root_id == $INSTRUMENT_ROOT_ID &&
        $link_attr_type->id != $INSTRUMENT_ROOT_ID;
    $c->detach('/error_403') if $is_instrument_child;

    $self->_load_tree($c);

    my $form = $c->form( form => 'Admin::LinkAttributeType', init_object => $link_attr_type );

    my $attribute_in_use = $c->model('LinkAttributeType')->in_use($link_attr_type->id);

    if ($attribute_in_use) {
        $form->field('free_text')->disabled(1);
        if ($link_attr_type->creditable) {
            $form->field('creditable')->disabled(1);
        }
    }

    if ($c->form_posted_and_valid($form)) {
        my %values = map { $_->name => $_->value } $form->edit_fields;

        my $edit;

        $c->model('MB')->with_transaction(sub {
            $edit = $self->_insert_edit(
                $c, $form,
                edit_type => $EDIT_RELATIONSHIP_ATTRIBUTE,
                entity_id => $link_attr_type->id,
                new => \%values ,
                old => {
                    name => $link_attr_type->name,
                    description => $link_attr_type->description,
                    parent_id => $link_attr_type->parent_id,
                    child_order => $link_attr_type->child_order,
                    creditable => $link_attr_type->creditable,
                    free_text => $link_attr_type->free_text,
                }
            );
        });

        if ($edit) {
            $c->response->redirect($c->uri_for_action('relationship/linkattributetype/show', [ $link_attr_type->gid ]));
        }
    }
}

sub delete : Chained('load') RequireAuth(relationship_editor) SecureForm
{
    my ($self, $c, $gid) = @_;

    my $link_attr_type = $c->stash->{link_attr_type};

    my $is_instrument_child =
        $link_attr_type->root_id == $INSTRUMENT_ROOT_ID &&
        $link_attr_type->id != $INSTRUMENT_ROOT_ID;
    $c->detach('/error_403') if $is_instrument_child;

    my $form = $c->form(
        form => 'SecureConfirm'
    );

    if ($c->model('LinkAttributeType')->in_use($link_attr_type->id)) {
        $c->stash(
            component_path  => 'relationship/linkattributetype/RelationshipAttributeTypeInUse',
            component_props => {type => $link_attr_type->TO_JSON},
            current_view    => 'Node',
        );
        $c->detach;
    }

    $c->stash(
        component_path  => 'relationship/linkattributetype/DeleteRelationshipAttributeType',
        component_props => {
            form => $form->TO_JSON,
            type => $link_attr_type->TO_JSON,
        },
        current_view    => 'Node',
    );

    if ($c->form_posted_and_valid($form)) {
        if ($form->field('cancel')->input) {
            # Do nothing
        } else {
            $c->model('MB')->with_transaction(sub {
                $self->_insert_edit(
                    $c, $form,
                    edit_type => $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE,
                    name => $link_attr_type->name,
                    description => $link_attr_type->description,
                    parent_id => $link_attr_type->parent_id,
                    child_order => $link_attr_type->child_order,
                    id => $link_attr_type->id
                );
            });
        }

        $c->response->redirect(
            $c->uri_for_action('relationship/linkattributetype/list'),
        );
        $c->detach;
    }
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
