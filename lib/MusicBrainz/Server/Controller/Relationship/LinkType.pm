package MusicBrainz::Server::Controller::Relationship::LinkType;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use Sql;
use List::UtilsBy qw( partition_by sort_by );
use MusicBrainz::Server::Data::Relationship;
use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash type_to_model );
use MusicBrainz::Server::Constants qw(
    :direction
    $EDIT_RELATIONSHIP_ADD_TYPE
    $EDIT_RELATIONSHIP_EDIT_LINK_TYPE
    $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE
);
use MusicBrainz::Server::Translation qw( l );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'LinkType',
    entity_name => 'link_type',
};

sub base : Chained('/') PathPart('relationship') CaptureArgs(0) { }

sub show : PathPart('') Chained('load')
{
    my ($self, $c) = @_;

    my $relationship_type = $c->stash->{link_type};

    $c->model('LinkAttributeType')->load($relationship_type->all_attributes);
    $c->model('LinkType')->load_documentation($relationship_type);
    $c->stash(
        component_path  => 'relationship/linktype/RelationshipTypeIndex',
        component_props => { relType => $relationship_type->TO_JSON },
        current_view => 'Node',
    );
}

sub list : Path('/relationships') Args(0)
{
    my ($self, $c) = @_;

    my %by_second_type = partition_by { $_->[1] }
        MusicBrainz::Server::Data::Relationship->all_pairs;

    my @types = sort keys %by_second_type;

    my %props = (
        types => \@types,
        table => [ map { [ sort_by { $_->[0] } @{ $by_second_type{$_} } ] } @types ]
    );

    $c->stash(
        component_path  => 'relationship/linktype/RelationshipTypesList',
        component_props => \%props,
        current_view    => 'Node',
    );
}

sub type_specific : Chained('/') PathPart('relationships') CaptureArgs(1) {
    my ($self, $c, $types) = @_;

    my %allowed = map { join('-', @$_) => 1 }
        MusicBrainz::Server::Data::Relationship->all_pairs;

    if (!exists $allowed{$types}) {
        $c->stash(
            message  => l(
                "'{types}' is not a valid pair of types for relationships.",
                { types => $types }
            )
        );
        $c->detach('/error_400');
        $c->detach;
    }

    my ($type0, $type1) = split /-/, $types;
    $c->stash(
        type0 => $type0,
        type1 => $type1,
        type0_name => type_to_model($type0),
        type1_name => type_to_model($type1),
        types => $types
    );
}

sub tree : Chained('type_specific') PathPart('')
{
    my ($self, $c) = @_;

    my $root = $c->model('LinkType')->get_tree($c->stash->{type0},
                                                $c->stash->{type1});

    $c->stash(
        component_path  => 'relationship/linktype/RelationshipTypePairTree',
        component_props => {root => $root->TO_JSON},
        current_view    => 'Node',
    );
}

sub _get_attribute_values
{
    my ($self, $form) = @_;

    my @result;
    foreach my $field (@{$form->field('attributes')->fields}) {
        if ($field->field('active')->value) {
            push @result, {
                type => $field->field('type')->value,
                min  => $field->field('min')->value,
                max  => $field->field('max')->value,
            };
        }
    }
    return \@result;
}

sub create : Chained('type_specific') PathPart('create') RequireAuth(relationship_editor)
{
    my ($self, $c) = @_;

    my $attribs = $c->model('LinkType')->get_attribute_type_list();;
    my %attrib_names = map { $_->{type} => $_->{name} } @$attribs;
    $c->stash( attrib_names => \%attrib_names );

    my $form = $c->form(
        form => 'Admin::LinkType',
        init_object => { attributes => $attribs },
        root => $c->model('LinkType')->get_tree($c->stash->{type0}, $c->stash->{type1})
    );
    $form->field('parent_id')->_load_options;

    if ($c->form_posted_and_valid($form)) {
        my $values = { map { $_->name => $_->value } $form->edit_fields };
        $values->{entity0_type} = $c->stash->{type0};
        $values->{entity1_type} = $c->stash->{type1};
        $values->{attributes} = $self->_get_attribute_values($form);

        $c->model('MB')->with_transaction(sub {
            $self->_insert_edit(
                $c, $form,
                edit_type => $EDIT_RELATIONSHIP_ADD_TYPE,
                %$values
            );
        });

        $c->response->redirect($c->uri_for_action('/relationship/linktype/tree', [ $c->stash->{types} ]));
        $c->detach;
    }
}

sub edit : Chained('load') RequireAuth(relationship_editor)
{
    my ($self, $c, $gid) = @_;

    my $link_type = $c->stash->{link_type};
    $c->model('LinkType')->load_documentation($link_type);

    my $attribs = $c->model('LinkType')->get_attribute_type_list($link_type->id);
    my %attrib_names = map { $_->{type} => $_->{name} } @$attribs;
    $c->stash( attrib_names => \%attrib_names );

    my $form = $c->form(
        form => 'Admin::LinkType::Edit',
        init_object => {
            attributes => $attribs,
            map { $_ => $link_type->$_ }
                qw( parent_id child_order name link_phrase reverse_link_phrase
                    long_link_phrase description priority documentation
                    examples is_deprecated has_dates entity0_cardinality entity1_cardinality
                    orderable_direction )
        },
        root => $c->model('LinkType')->get_tree($link_type->entity0_type,
                                                $link_type->entity1_type)
    );
    $form->field('parent_id')->_load_options;

    my $relationship_map = {
        map { $_->relationship->id => $_->relationship }
            $link_type->all_examples
    };

    $c->stash( relationship_map => $relationship_map );

    my $old_values = { map { $_->name => $_->value } $form->edit_fields };
    $old_values->{attributes} = [
        map +{
            # We don't want the 'active' field
            min => $_->{min},
            max => $_->{max},
            type => $_->{type},
            name => $attrib_names{$_->{type}},
        }, grep { $_->{active} } @{ $old_values->{attributes} }
    ];

    if ($c->form_posted) {
        my $valid = $form->process( params => $c->req->params );

        # Load any relationships the user may have subsequently added as
        # examples.
        my @load_subdata;
        for my $relationship_id (
            grep { $_ && !exists $relationship_map->{$_} }
                map { $_->field('relationship')->field('id')->input }
                    $form->field('examples')->fields
        ) {
            my $rel = $relationship_map->{$relationship_id} =
                $c->model('Relationship')->get_by_id(
                    $link_type->entity0_type, $link_type->entity1_type,
                    $relationship_id
                );

            push @load_subdata, $rel;
        }

        $c->model('Link')->load(@load_subdata);
        $c->model('LinkType')->load(map { $_->link } @load_subdata);
        $c->model('Relationship')->load_entities(@load_subdata);

        if ($valid) {
            my $values = { map { $_->name => $_->value } $form->edit_fields };
            $values->{attributes} = [
                map {
                    my %attr = (%{$_}, name => $attrib_names{$_->{type}});
                    \%attr
                } @{ $self->_get_attribute_values($form) }
            ];

            # Inflate the provided example relationships so we have sufficient
            # information for edit history.
            for my $example (
                @{ $values->{examples} }, @{ $old_values->{examples} }
            ) {
                my $relationship =
                    $relationship_map->{$example->{relationship}{id}}
                        or die 'Unable to find example relationship';

                # We have to store relationships in the forward direction.
                my ($e0, $e1) =
                    $relationship->direction == $DIRECTION_FORWARD
                        ? ($relationship->entity0, $relationship->entity1)
                        : ($relationship->entity1, $relationship->entity0);

                $example->{relationship}{entity0} = {
                    id => $e0->id,
                    name => $e0->name,
                    gid => $e0->gid,
                    comment => $e0->can('comment') ? $e0->comment : ''
                };

                $example->{relationship}{entity1} = {
                    id => $e1->id,
                    name => $e1->name,
                    gid => $e1->gid,
                    comment => $e1->can('comment') ? $e1->comment : ''
                };

                $example->{relationship}{link} = {
                    begin_date =>
                        partial_date_to_hash($relationship->link->begin_date),
                    end_date =>
                        partial_date_to_hash($relationship->link->end_date),
                    link_type => {
                        entity0_type => $link_type->entity0_type,
                        entity1_type => $link_type->entity1_type,
                    }
                };


                $example->{relationship}{verbose_phrase} =
                    $relationship->verbose_phrase;
            }

            # Anything a user submits is immediately published.
            for my $example (@{ $values->{examples} }) {
                $example->{published} = 1;
            }

            # Preserve the published flag for existing relationships
            my %old_examples = map { $_->relationship->id => $_ }
                $link_type->all_examples;
            for my $example (@{ $old_values->{examples} }) {
                $example->{published} =
                    $old_examples{$example->{relationship}{id}}->published;
            }

            $c->model('MB')->with_transaction(sub {
                $self->_insert_edit(
                    $c, $form,
                    edit_type => $EDIT_RELATIONSHIP_EDIT_LINK_TYPE,
                    old => $old_values,
                    new => $values,
                    link_id => $link_type->id
                );
            });

            $c->response->redirect($c->uri_for_action('/relationship/linktype/show', [ $link_type->gid ]));
            $c->detach;
        }
    }
}

sub delete : Chained('load') RequireAuth(relationship_editor) SecureForm
{
    my ($self, $c, $gid) = @_;

    my $link_type = $c->stash->{link_type};

    if ($c->model('LinkType')->in_use($link_type->id)) {
        $c->stash(
            component_path  => 'relationship/linktype/RelationshipTypeInUse',
            component_props => {type => $link_type->TO_JSON},
            current_view    => 'Node',
        );
        $c->detach;
    }

    my $form = $c->form( form => 'SecureConfirm' );

    if ($c->form_posted_and_valid($form)) {
        $c->model('MB')->with_transaction(sub {
            $self->_insert_edit(
                $c, $form,
                edit_type => $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE,
                link_type_id => $link_type->id,
                types => [ $link_type->entity0_type, $link_type->entity1_type ],
                name => $link_type->name,
                link_phrase => $link_type->link_phrase,
                long_link_phrase => $link_type->long_link_phrase,
                reverse_link_phrase => $link_type->reverse_link_phrase,
                description => $link_type->description,
                attributes => [
                    map +{
                        type => $_->type_id,
                        min => $_->min,
                        max => $_->max
                    }, $link_type->all_attributes
                ]
            );
        });

        $c->response->redirect($c->uri_for_action('/relationship/linktype/tree', [ $c->stash->{types} ]));
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
