package MusicBrainz::Server::Controller::Role::RelationshipEditor;
use List::AllUtils qw( uniq_by );
use Moose::Role;

use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_CREATE
    $EDIT_RELATIONSHIP_DELETE
    $EDIT_RELATIONSHIPS_REORDER
);
use List::AllUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw(
    type_to_model
    split_relationship_by_attributes
);
use MusicBrainz::Server::Edit::Relationship::Edit;

=method try_and_edit

Try and edit an existing relationship.

First check if the relationship we will end up at already exists, and if so
notify the user and do not continue. Otherwise, insert an edit to edit the
relationship. Also takes care of some general book-keeping in regards to table
locking and race conditions.

=cut

sub try_and_edit {
    my ($self, $c, $form, %params) = @_;

    if (my $attributes = $params{attributes}) {
        @$attributes = uniq_by { $_->{type}{gid} } @$attributes;
    }

    my $edit;
    $c->model('MB')->with_transaction(sub {
        $edit = $self->_insert_edit(
            $c, $form, edit_type => $EDIT_RELATIONSHIP_EDIT, %params
        );
    });
    return $edit;
}

=method try_and_insert

Try and insert a new relationship.

First check if the relationship already exists, and if it does return false and
do not continue. Otherwise, insert the new relationship and return a true value.

Takes care of necessary bookkeeping such as exclusive locks on the relationship
table.

=cut

sub try_and_insert {
    my ($self, $c, $form, %params) = @_;

    my @edits;
    my $attributes = $c->model('LinkAttributeType')->get_by_gids(
        map { $_->{type}{gid} } @{ $params{attributes} // [] }
    );
    my @relationships = split_relationship_by_attributes($attributes, \%params);

    $c->model('MB')->with_transaction(sub {
        @edits = map {
            $self->_insert_edit(
                $c, $form, edit_type => $EDIT_RELATIONSHIP_CREATE, %$_
            )
        } @relationships
    });
    return @edits;
}

sub delete_relationship {
    my ($self, $c, $form, %params) = @_;

    my $edit;
    $c->model('MB')->with_transaction(sub {
        $edit = $self->_insert_edit(
            $c, $form, edit_type => $EDIT_RELATIONSHIP_DELETE, %params
        );
        return 1;
    });
    return $edit;
}

sub reorder_relationships {
    my ($self, $c, $form, %params) = @_;

    my $edit;
    $c->model('MB')->with_transaction(sub {
        $edit = $self->_insert_edit(
            $c, $form, edit_type => $EDIT_RELATIONSHIPS_REORDER, %params
        );
        return 1;
    });
    return $edit;
}

1;
