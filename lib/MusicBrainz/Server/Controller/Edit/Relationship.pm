package MusicBrainz::Server::Controller::Edit::Relationship;
use Moose;

BEGIN { extends 'Catalyst::Controller' };

use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_DELETE
    $EDIT_RELATIONSHIP_EDIT
    );
use MusicBrainz::Server::Edit::Relationship::Delete;
use MusicBrainz::Server::Edit::Relationship::Edit;
use JSON;

sub edit : Local RequireAuth
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

    sub build_type_info
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
            build_type_info($child, $info);
        }
    }

    my %type_info;
    build_type_info($tree, \%type_info);

    $c->stash(
        root => $tree,
        type_info => JSON->new->latin1->encode(\%type_info),
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
    my $form = $c->form( form => 'Relationship', init_object => $values );
    $form->field('link_type_id')->_load_options;

    $c->stash( relationship => $rel );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
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

        my $values = $form->values;
        my $edit = $c->model('Edit')->create(
            edit_type => $EDIT_RELATIONSHIP_EDIT,
            editor_id => $c->user->id,

            type0        => $type0,
            type1        => $type1,
            relationship => $rel,
            link_type_id => $values->{link_type_id},
            begin_date   => $values->{begin_date},
            end_date     => $values->{end_date},
            attributes   => \@attributes
        );

        my $redirect = $c->req->params->{returnto} || $c->uri_for('/search');
        $c->response->redirect($redirect);
        $c->detach;
    }
}

sub delete : Local RequireAuth
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

        my $edit = $c->model('Edit')->create(
            edit_type    => $EDIT_RELATIONSHIP_DELETE,
            editor_id    => $c->user->id,

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
