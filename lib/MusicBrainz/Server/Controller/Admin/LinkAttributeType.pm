package MusicBrainz::Server::Controller::Admin::LinkAttributeType;
use Moose;
use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_ADD_ATTRIBUTE
    $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE
    $EDIT_RELATIONSHIP_ATTRIBUTE
);

BEGIN { extends 'MusicBrainz::Server::Controller' };

sub _load_tree
{
    my ($self, $c) = @_;

    my $tree = $c->model('LinkAttributeType')->get_tree();
    $c->stash( root => $tree );
}

sub _load_link_attr_type
{
    my ($self, $c, $id) = @_;

    my $link_attr_type = $c->model('LinkAttributeType')->get_by_id($id);
    unless (defined $link_attr_type) {
        $c->detach('/error_404');
    }
    $c->stash( link_attr_type => $link_attr_type );

    return $link_attr_type;
}

sub index : Path Args(0)
{
    my ($self, $c) = @_;

    $self->_load_tree($c);
}

sub instruments : Path('/admin/linkattributetype/instruments')
{
    my ($self, $c) = @_;

    my $tree = $c->model('LinkAttributeType')->get_tree();
    my $instruments;

    for my $i ($tree->all_children) {
        next unless $i->{'name'} eq "instrument";
        $instruments = $i;
    }

    $c->stash( root => $instruments );
}

sub create : Local Args(0) RequireAuth(relationship_editor)
{
    my ($self, $c) = @_;

    $self->_load_tree($c);
    my $form = $c->form( form => 'Admin::LinkAttributeType' );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        $self->_insert_edit($c, $form,
            edit_type => $EDIT_RELATIONSHIP_ADD_ATTRIBUTE,
            map { $_->name => $_->value } $form->edit_fields
        );

        my $url = $c->uri_for_action('/admin/linkattributetype/index', { msg => 'created' });
        $c->response->redirect($url);
        $c->detach;
    }
}

sub edit : Local Args(1) RequireAuth(relationship_editor)
{
    my ($self, $c, $id) = @_;

    my $link_attr_type = $self->_load_link_attr_type($c, $id);
    $self->_load_tree($c);

    my $form = $c->form( form => 'Admin::LinkAttributeType', init_object => $link_attr_type );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        $self->_insert_edit($c, $form,
            edit_type => $EDIT_RELATIONSHIP_ATTRIBUTE,
            entity_id => $link_attr_type->id,
            new => { map { $_->name => $_->value } $form->edit_fields },
            old => {
                name => $link_attr_type->name,
                description => $link_attr_type->description,
                parent_id => $link_attr_type->parent_id,
                child_order => $link_attr_type->child_order,
            }
        );

        my $url = $c->uri_for_action('/admin/linkattributetype/index', { msg => 'updated' });
        $c->response->redirect($url);
        $c->detach;
    }
}

sub delete : Local Args(1) RequireAuth(relationship_editor)
{
    my ($self, $c, $id) = @_;

    my $link_attr_type = $self->_load_link_attr_type($c, $id);
    my $form = $c->form( form => 'Confirm' );

    if ($c->model('LinkAttributeType')->in_use($id)) {
        $c->stash( template => $c->namespace . '/in_use.tt');
        $c->detach;
    }

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        $self->_insert_edit($c, $form,
            edit_type => $EDIT_RELATIONSHIP_REMOVE_LINK_ATTRIBUTE,
            name => $link_attr_type->name,
            description => $link_attr_type->description,
            parent_id => $link_attr_type->parent_id,
            child_order => $link_attr_type->child_order,
            id => $link_attr_type->id
        );

        my $url = $c->uri_for_action('/admin/linkattributetype/index', { msg => 'deleted' });
        $c->response->redirect($url);
        $c->detach;
    }
}

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
