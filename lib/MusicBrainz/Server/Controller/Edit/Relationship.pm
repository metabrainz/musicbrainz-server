package MusicBrainz::Server::Controller::Edit::Relationship;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use MusicBrainz::Server::Constants qw( $EDIT_RELATIONSHIP_DELETE );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Edit::Relationship::Delete;
use MusicBrainz::Server::Edit::Relationship::Edit;
use MusicBrainz::Server::Translation qw( l ln );
use JSON;

with 'MusicBrainz::Server::Controller::Role::RelationshipEditor';

sub build_type_info
{
    my ($tree) = @_;

    sub _builder
    {
        my ($root, $info) = @_;

        if ($root->id) {
            my %attrs = map { $_->type_id => [
                defined $_->min ? 0 + $_->min : undef,
                defined $_->max ? 0 + $_->max : undef,
            ] } $root->all_attributes;
            $info->{$root->id} = {
                descr => $root->l_description,
                attrs => \%attrs,
            };
        }
        foreach my $child ($root->all_children) {
            _builder($child, $info);
        }
    }

    my %type_info;
    _builder($tree, \%type_info);
    return %type_info;
}

=method detach_existing

Notify the user that the relationship already exists, and do not do any more
work.

=cut

sub detach_existing {
    my ($self, $c) = @_;
    $c->stash( exists => 1 );
    $c->detach;
}

sub edit : Local RequireAuth Edit
{
    my ($self, $c) = @_;

    my $id = $c->req->params->{id};
    my $type0 = $c->req->params->{type0};
    my $type1 = $c->req->params->{type1};

    my $rel = $c->model('Relationship')->get_by_id($type0, $type1, $id);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);
    $c->model('Relationship')->load_entities($rel);

    my $tree = $c->model('LinkType')->get_tree($type0, $type1);
    my %type_info = build_type_info($tree);

    if (!%type_info) {
        $c->stash(
            template => 'edit/relationship/cannot_create.tt',
            type0 => $type0,
            type1 => $type1
        );
        $c->detach;
    }

    $c->stash(
        root => $tree,
        type_info => JSON->new->latin1->encode(\%type_info),
        rel => $rel
    );

    my $attr_tree = $c->model('LinkAttributeType')->get_tree();
    $c->stash( attr_tree => $attr_tree );
    $self->attr_tree($attr_tree);

    my $values = {
        link_type_id => $rel->link->type_id,
        period => {
            begin_date => $rel->link->begin_date,
            end_date => $rel->link->end_date,
            ended => $rel->link->ended,
        },
        attrs => {},
    };
    my %attr_multi;
    foreach my $attr ($attr_tree->all_children) {
        $attr_multi{$attr->id} = scalar $attr->all_children;
    }
    foreach my $attr ($rel->link->all_attributes) {
        my $name = $attr->root->name;
        if ($attr_multi{$attr->root->id}) {
            if (exists $values->{attrs}->{$name}) {
                push @{$values->{attrs}->{$name}}, $attr->id;
            }
            else {
                $values->{attrs}->{$name} = [ $attr->id ];
            }
        }
        else {
            $values->{attrs}->{$name} = 1;
        }
    }

    $values->{entity0}->{id} = $rel->entity0_id;
    $values->{entity1}->{id} = $rel->entity1_id;
    $values->{entity0}->{name} = $rel->entity0->name;
    $values->{entity1}->{name} = $rel->entity1->name;

    my $form = $c->form(
        form => 'Relationship',
        init_object => $values,
        attr_tree => $attr_tree,
        root => $tree
    );
    $form->field('link_type_id')->_load_options;

    $c->stash( relationship => $rel );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        my @attributes = $self->flatten_attributes($form->field('attrs'));

        my @ids = $form->field('direction')->value
                # User is changing the direction
                ? ($form->field('entity1.id')->value
                  ,$form->field('entity0.id')->value)

                # User is not changing the direction
                : ($form->field('entity0.id')->value
                  ,$form->field('entity1.id')->value);

        my $model0 = $c->model(type_to_model($type0));
        my $model1 = $c->model(type_to_model($type1));

        my @selected = (
            $model0->get_by_id($form->field('entity0.id')->value),
            $model1->get_by_id($form->field('entity1.id')->value)
        );

        $c->stash( selected => \@selected );

        $c->model('MB')->with_transaction(sub {
            $self->try_and_edit(
                $c, $form,
                $type0, $type1, $rel,
                entity0_id       => $ids[0],
                entity1_id       => $ids[1],
                attributes       => \@attributes,
                new_link_type_id => $form->field('link_type_id')->value,
                new_begin_date   => $form->field('period.begin_date')->value,
                new_end_date     => $form->field('period.end_date')->value,
                ended            => $form->field('period.ended')->value
            ) or
                $self->detach_existing($c);
        });

        my $redirect = $c->req->params->{returnto} || $c->uri_for('/search');
        $c->response->redirect($redirect);
        $c->detach;
    }
}

sub create : Local RequireAuth Edit
{
    my ($self, $c) = @_;

    my $qp = $c->req->query_params;
    my ($type0, $type1)         = ($qp->{type0},  $qp->{type1});
    my ($source_gid, $dest_gid) = ($qp->{entity0}, $qp->{entity1});
    if (!$type0 || !$type1 || !$source_gid || !$dest_gid) {
        $c->stash( message => l('Invalid arguments') );
        $c->detach('/error_500');
    }

    if ($type0 gt $type1) {
        # FIXME We should really support entering relationships backwards
        # (ie work -> recording, not just recording -> work)
        ($type0, $type1) = ($type1, $type0);
        ($source_gid, $dest_gid) = ($dest_gid, $source_gid);
    }

    my $source_model = $c->model(type_to_model($type0));
    my $dest_model   = $c->model(type_to_model($type1));
    if (!$source_model || !$dest_model) {
        $c->stash( message => l('Invalid entities') );
        $c->detach('/error_500');
    }

    my $source = $source_model->get_by_gid($source_gid);
    my $dest   = $dest_model->get_by_gid($dest_gid);

    if ($type0 eq $type1 && $source->id == $dest->id) {
        $c->stash( message => l('A relationship requires 2 different entities') );
        $c->detach('/error_500');
    }

    my $tree = $c->model('LinkType')->get_tree($type0, $type1);
    my %type_info = build_type_info($tree);

    if (!%type_info) {
        $c->stash(
            template => 'edit/relationship/cannot_create.tt',
            type0 => $type0,
            type1 => $type1
        );
        $c->detach;
    }

    $c->stash(
        root      => $tree,
        type_info => JSON->new->latin1->encode(\%type_info),
    );

    my $attr_tree = $c->model('LinkAttributeType')->get_tree();
    $c->stash( attr_tree => $attr_tree );
    $self->attr_tree($attr_tree);

    my $form = $c->form(
        form => 'Relationship',
        attr_tree => $attr_tree,
        root => $tree
    );
    $c->stash(
        source => $source, source_type => $type0,
        dest   => $dest,   dest_type   => $type1
    );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my @attributes = $self->flatten_attributes($form->field('attrs'));

        my $entity0 = $source;
        my $entity1 = $dest;

        if ($type0 eq $type1 && $form->field('direction')->value)
        {
            ($entity0, $entity1) = ($entity1, $entity0);
        }

        $c->model('MB')->with_transaction(sub {
            $self->try_and_insert(
                $c, $form,
                $type0, $type1,
                begin_date   => $form->field('period.begin_date')->value,
                end_date     => $form->field('period.end_date')->value,,
                attributes   => \@attributes,
                link_type_id => $form->field('link_type_id')->value,
                entity0      => $entity0,
                entity1      => $entity1,
                ended        => $form->field('period.ended')->value
            ) or
                $self->detach_existing($c);
        });

        delete $c->session->{relationship};
        my $redirect = $c->req->params->{returnto} ||
            $c->uri_for_action($c->controller(type_to_model($type0))->action_for('show'), [ $source_gid ]);
        $c->response->redirect($redirect);
        $c->detach;
    }
}

sub create_url : Local RequireAuth Edit
{
    my ($self, $c) = @_;
    my $qp = $c->req->query_params;
    my $type = $qp->{type};
    my $gid = $qp->{entity};

    if ($type eq 'url') {
        $c->stash( message => l('Invalid type') );
        $c->detach('/error_500');
    }

    my @types = sort ($type, 'url');

    my $model = $c->model(type_to_model($type));
    unless (defined $model) {
        $c->stash( message => l('Invalid type') );
        $c->detach('/error_500');
    }

    my $entity = $model->get_by_gid($gid);
    unless (defined $entity) {
        $c->stash( message => l('Entity not found') );
        $c->detach('/error_404');
    }

    my $tree = $c->model('LinkType')->get_tree(@types);
    my %type_info = build_type_info($tree);

    if (!%type_info) {
        $c->stash(
            template => 'edit/relationship/cannot_create.tt',
            type0 => $types[0],
            type1 => $types[1]
        );
        $c->detach;
    }

    $c->stash(
        root      => $tree,
        type_info => JSON->new->latin1->encode(\%type_info),
    );

    my $attr_tree = $c->model('LinkAttributeType')->get_tree;
    $c->stash( attr_tree => $attr_tree );
    $self->attr_tree($attr_tree);

    my $form = $c->form(
        form => 'Relationship::URL',
        reverse => $types[0] eq 'url',
        root => $tree,
        attr_tree => $attr_tree
    );

    $c->stash(
        entity => $entity,
        type => $type,
    );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my @attributes = $self->flatten_attributes($form->field('attrs'));
        my $url = $c->model('URL')->find_or_insert($form->field('url')->value);

        my $e0 = $types[0] eq 'url' ? $url : $entity;
        my $e1 = $types[1] eq 'url' ? $url : $entity;

        $c->stash( url => $form->field('url')->value );
        $c->model('MB')->with_transaction(sub {
            $self->try_and_insert(
                $c, $form,
                @types,
                entity0 => $e0,
                entity1 => $e1,
                link_type_id => $form->field('link_type_id')->value,
                attributes => \@attributes,
                ended => 0
            ) or $self->detach_existing($c);
        });

        my $redirect = $c->controller(type_to_model($type))->action_for('show');
        $c->response->redirect($c->uri_for_action($redirect, [ $gid ]));
        $c->detach;
    }
}

sub delete : Local RequireAuth Edit
{
    my ($self, $c) = @_;

    my $id = $c->req->params->{id};
    my $type0 = $c->req->params->{type0};
    my $type1 = $c->req->params->{type1};

    my $rel = $c->model('Relationship')->get_by_id($type0, $type1, $id);
    $c->model('Link')->load($rel);
    $c->model('LinkType')->load($rel->link);
    $c->model('Relationship')->load_entities($rel);

    my $form = $c->form( form => 'Confirm' );
    $c->stash( relationship => $rel );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        $c->model('MB')->with_transaction(sub {
            my $edit = $self->_insert_edit(
                $c, $form,
                edit_type    => $EDIT_RELATIONSHIP_DELETE,

                type0        => $type0,
                type1        => $type1,
                relationship => $rel,
            );
        });

        my $redirect = $c->req->params->{returnto} || $c->uri_for('/search');
        $c->response->redirect($redirect);
        $c->detach;
    }

    $c->stash( relationship => $rel );
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
