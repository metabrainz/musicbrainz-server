package MusicBrainz::Server::Controller::Relationship::LinkType;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' };

use Sql;
use MusicBrainz::Server::Data::Relationship;
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_ADD_TYPE
    $EDIT_RELATIONSHIP_EDIT_LINK_TYPE
    $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE
);

sub index : Path('/relationships') Args(0)
{
    my ($self, $c) = @_;

    my @types = MusicBrainz::Server::Data::Relationship->all_link_types;
    my @table;
    foreach my $type1 (@types) {
        my @row;
        foreach my $type0 (@types) {
            push @row, $type0 gt $type1 ? '' : "$type0-$type1";
        }
        push @table, \@row;
    }

    $c->stash(
        types => \@types,
        table => \@table,
    );
}

sub tree_setup : Chained PathPart('relationships') CaptureArgs(1)
{
    my ($self, $c, $types) = @_;

    my ($type0, $type1) = split /-/, $types;
    my $tree = $c->model('LinkType')->get_tree($type0, $type1);

    $c->stash(
        types => $types,
        type0 => $type0,
        type1 => $type1,
        type0_name => type_to_model($type0),
        type1_name => type_to_model($type1),
        root => $tree,
    );
}

sub tree : Chained('tree_setup') PathPart('')
{
    my ($self, $c) = @_;
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

sub create : Chained('tree_setup') RequireAuth(relationship_editor)
{
    my ($self, $c) = @_;

    my $attribs = $c->model('LinkType')->get_attribute_type_list();;
    my %attrib_names = map { $_->{type} => $_->{name} } @$attribs;
    $c->stash( attrib_names => \%attrib_names );

    my $form = $c->form( form => 'Admin::LinkType', init_object => {
        attributes => $attribs,
    });
    $form->field('parent_id')->_load_options;

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        my $values = { map { $_->name => $_->value } $form->edit_fields };
        $values->{entity0_type} = $c->stash->{type0};
        $values->{entity1_type} = $c->stash->{type1};
        $values->{attributes} = $self->_get_attribute_values($form);

        $self->_insert_edit($c, $form,
            edit_type => $EDIT_RELATIONSHIP_ADD_TYPE,
            %$values
        );

        my $url = $c->uri_for_action(
            '/relationship/linktype/tree',
            [ $c->stash->{types} ],
            { msg => 'created' }
        );
        $c->response->redirect($url);
        $c->detach;
    }
}

sub edit : Chained('tree_setup') Args(1) RequireAuth(relationship_editor)
{
    my ($self, $c, $gid) = @_;

    my $link_type = $c->model('LinkType')->get_by_gid($gid);
    unless (defined $link_type) {
        $c->detach('/error_404');
    }
    $c->stash( link_type => $link_type );

    my $attribs = $c->model('LinkType')->get_attribute_type_list($link_type->id);
    my %attrib_names = map { $_->{type} => $_->{name} } @$attribs;
    $c->stash( attrib_names => \%attrib_names );

    my $form = $c->form( form => 'Admin::LinkType', init_object => {
        attributes => $attribs,
        map { $_ => $link_type->$_ }
            qw( parent_id child_order name link_phrase reverse_link_phrase
                short_link_phrase description priority )
    });
    $form->field('parent_id')->_load_options;

    my $old_values = { map { $_->name => $_->value } $form->edit_fields };
    $old_values->{attributes} = [
        map +{
            # We don't want the 'active' field
            min => $_->{min},
            max => $_->{max},
            type => $_->{type},
        }, grep { $_->{active} } @{ $old_values->{attributes} }
    ];

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        my $values = { map { $_->name => $_->value } $form->edit_fields };
        $values->{attributes} = $self->_get_attribute_values($form);

        $self->_insert_edit($c, $form,
            edit_type => $EDIT_RELATIONSHIP_EDIT_LINK_TYPE,
            old => $old_values,
            new => $values,
            link_id => $link_type->id
        );

        my $url = $c->uri_for_action('/relationship/linktype/tree', [ $c->stash->{types} ], { msg => 'updated' });
        $c->response->redirect($url);
        $c->detach;
    }
}

sub delete : Chained('tree_setup') Args(1) RequireAuth(relationship_editor)
{
    my ($self, $c, $gid) = @_;

    my $link_type = $c->model('LinkType')->get_by_gid($gid);
    unless (defined $link_type) {
        $c->detach('/error_404');
    }

    $c->stash( link_type => $link_type );

    if ($c->model('LinkType')->in_use($link_type->id)) {
        $c->stash( template => 'relationship/linktype/in_use.tt' );
        $c->detach;
    }

    my $form = $c->form( form => 'Confirm' );

    if ($c->form_posted && $form->process( params => $c->req->params )) {
        $self->_insert_edit($c, $form,
            edit_type => $EDIT_RELATIONSHIP_REMOVE_LINK_TYPE,
            link_type_id => $link_type->id,
            types => [ $link_type->entity0_type, $link_type->entity1_type ],
            name => $link_type->name,
            link_phrase => $link_type->link_phrase,
            short_link_phrase => $link_type->short_link_phrase,
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

        my $url = $c->uri_for_action('/relationship/linktype/tree', [ $c->stash->{types} ], { msg => 'deleted' });
        $c->response->redirect($url);
        $c->detach;
    }
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2011 MetaBrainz Foundation

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
