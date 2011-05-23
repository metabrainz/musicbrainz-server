package MusicBrainz::Server::Controller::Edit::Relationship;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_DELETE
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_CREATE
    );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Edit::Relationship::Delete;
use MusicBrainz::Server::Edit::Relationship::Edit;
use MusicBrainz::Server::Translation qw( l ln );
use JSON;

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
                descr => $root->description,
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

    my $values = {
        link_type_id => $rel->link->type_id,
        begin_date => $rel->link->begin_date,
        end_date => $rel->link->end_date,
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
        attr_tree => $attr_tree
    );
    $form->field('link_type_id')->_load_options;

    $c->stash( relationship => $rel );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        my @attributes;
        for my $attr ($attr_tree->all_children) {
            my $value = $form->field('attrs')->field($attr->name)->value;
            next unless defined($value);

            push @attributes, scalar($attr->all_children)
                ? @$value
                : $value ? $attr->id : ();
        }

        if ($c->model('Relationship')->exists($type0, $type1, {
            link_type_id => $form->field('link_type_id')->value,
            begin_date   => $form->field('begin_date')->value,
            end_date     => $form->field('end_date')->value,
            attributes   => [uniq @attributes],
            $form->field('direction')->value
                # User is changing the direction
                ? (entity0      => $form->field('entity1.id')->value,
                   entity1      => $form->field('entity0.id')->value)

                # User is not changing the direction
                : (entity0      => $form->field('entity0.id')->value,
                   entity1      => $form->field('entity1.id')->value)
        })) {
            $c->stash( exists => 1 );
            $c->detach;
        }

        my $values = $form->values;
        my $edit = $self->_insert_edit($c, $form,
            edit_type => $EDIT_RELATIONSHIP_EDIT,
            type0             => $type0,
            type1             => $type1,
            entity0_id        => $form->field('entity0.id')->value,
            entity1_id        => $form->field('entity1.id')->value,
            relationship      => $rel,
            link_type_id      => $form->field('link_type_id')->value,
            begin_date        => $form->field('begin_date')->value,
            end_date          => $form->field('end_date')->value,
            change_direction  => $form->field('direction')->value,
            attributes        => [uniq @attributes],
        );

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

    if ($source->id == $dest->id) {
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

    my $form = $c->form(
        form => 'Relationship',
        attr_tree => $attr_tree
    );
    $c->stash(
        source => $source, source_type => $type0,
        dest   => $dest,   dest_type   => $type1
    );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my @attributes;
        for my $attr ($attr_tree->all_children) {
            my $value = $form->field('attrs')->field($attr->name)->value;
            next unless defined($value);

            push @attributes, scalar($attr->all_children)
                ? @$value
                : $value ? $attr->id : ();
        }

        my $entity0 = $source;
        my $entity1 = $dest;

        if ($type0 eq $type1 && $form->field('direction')->value)
        {
            ($entity0, $entity1) = ($entity1, $entity0);
        }

        if ($c->model('Relationship')->exists($type0, $type1, {
            link_type_id => $form->field('link_type_id')->value,
            begin_date => $form->field('begin_date')->value,
            end_date => $form->field('end_date')->value,
            attributes => [uniq @attributes],
            entity0 => $entity0->id,
            entity1 => $entity1->id,
        })) {
            $c->stash( exists => 1 );
            $c->detach;
        }

        my $link_type = $c->model('LinkType')->get_by_id(
            $form->field('link_type_id')->value
        );

        $self->_insert_edit($c, $form,
            edit_type    => $EDIT_RELATIONSHIP_CREATE,
            type0        => $type0,
            type1        => $type1,
            entity0      => $entity0,
            entity1      => $entity1,
            begin_date   => $form->field('begin_date')->value,
            end_date     => $form->field('end_date')->value,
            link_type    => $link_type,
            attributes   => [uniq @attributes],
        );

        my $redirect = $c->controller(type_to_model($type0))->action_for('show');
        $c->response->redirect($c->uri_for_action($redirect, [ $source_gid ]));
        $c->detach;
    }
}

sub create_batch : Path('/edit/relationship/create-recordings') RequireAuth Edit
{
    my ($self, $c) = @_;

    my $qp = $c->req->query_params;

    if (!$qp->{gid}) {
        $c->stash( template => 'edit/relationship/no-start.tt' );
        $c->detach;
    }

    my $release_gid = $qp->{release};
    my $type = $qp->{type};
    my $gid = $qp->{gid};

    if (!$release_gid || !$type || !$gid) {
        $c->stash( message => l('Invalid arguments') );
        $c->detach('/error_500');
    }

    my $model = $c->model(type_to_model($type));
    if (!$model) {
        $c->stash( message => l('Invalid entities') );
        $c->detach('/error_500');
    }

    my $release = $c->model('Release')->get_by_gid($release_gid);
    if (!$release) {
        $c->stash( message => l('Release not found') );
        $c->detach('/error_500');
    }

    $c->model('Medium')->load_for_releases($release);
    $c->model('MediumFormat')->load($release->all_mediums);
    $c->model('Track')->load_for_tracklists(map { $_->tracklist } $release->all_mediums);
    $c->model('ArtistCredit')->load(map { $_->tracklist->all_tracks } $release->all_mediums);
    $c->model('Recording')->load(map { $_->tracklist->all_tracks } $release->all_mediums);

    my $dest = $model->get_by_gid($gid);
    if (!$dest) {
        $c->stash( message => l('Target entity not found') );
        $c->detach('/error_500');
    }

    my $tree = $c->model('LinkType')->get_tree($type => 'recording');
    my %type_info = build_type_info($tree);

    if (!%type_info) {
        $c->stash(
            template => 'edit/relationship/cannot_create.tt',
            type0 => $type,
            type1 => 'recording'
        );
        $c->detach;
    }

    $c->stash(
        root      => $tree,
        type_info => JSON->new->latin1->encode(\%type_info),
    );

    my $attr_tree = $c->model('LinkAttributeType')->get_tree();
    $c->stash( attr_tree => $attr_tree );

    my $form = $c->form( form => 'Relationship' );
    $c->stash(
        release => $release,
        dest    => $dest,
        type    => $type
    );

    $form = $c->form( form => 'Relationship::Recordings' );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my @attributes;
        foreach my $attr ($attr_tree->all_children) {
            my $value = $form->field('attrs')->field($attr->name)->value;
            if (defined $value) {
                if (scalar $attr->all_children) {
                    push @attributes, @{ $value };
                }
                elsif ($value) {
                    push @attributes, $attr->id;
                }
            }
        }

        my $req_param = $c->req->params->{recording_id};
        my @recording_ids = ref($req_param) ? @$req_param : ($req_param);
        my %recordings = %{ $c->model('Recording')->get_by_ids(@recording_ids) };

        my $link_type = $c->model('LinkType')->get_by_id(
            $form->field('link_type_id')->value
        );

        for my $recording_id (@recording_ids) {
            $self->_insert_edit(
                $c, $form,
                edit_type    => $EDIT_RELATIONSHIP_CREATE,
                type0        => $type,
                type1        => 'recording',
                entity0      => $dest,
                entity1      => $recordings{$recording_id},
                link_type    => $link_type,
                begin_date   => $form->field('begin_date')->value,
                end_date     => $form->field('end_date')->value,
                attributes   => \@attributes
            );
        }

        $c->response->redirect($c->uri_for_action('/release/show', [ $release_gid ]));
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

    my $form = $c->form( form => 'Relationship::URL', reverse => $types[0] eq 'url' );

    $c->stash(
        entity => $entity,
        type => $type,
    );

    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        my $url = $c->model('URL')->find_or_insert($form->field('url')->value);

        my $e0 = $types[0] eq 'url' ? $url : $entity;
        my $e1 = $types[1] eq 'url' ? $url : $entity;

        if ($c->model('Relationship')->exists(@types, {
            link_type_id => $form->field('link_type_id')->value,
            entity0 => $e0->id,
            entity1 => $e1->id,
        })) {
            $c->stash(
                exists => 1,
                url => $form->field('url')->value
            );
            $c->detach;
        }

        my $link_type = $c->model('LinkType')->get_by_id(
            $form->field('link_type_id')->value
        );

        $self->_insert_edit($c, $form,
            edit_type    => $EDIT_RELATIONSHIP_CREATE,
            type0        => $types[0],
            type1        => $types[1],
            entity0      => $e0,
            entity1      => $e1,
            link_type    => $link_type,
            attributes   => [],
        );
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
        my $values = $form->values;

        my $edit = $self->_insert_edit($c, $form,
            edit_type    => $EDIT_RELATIONSHIP_DELETE,

            type0        => $type0,
            type1        => $type1,
            relationship => $rel,
        );

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
