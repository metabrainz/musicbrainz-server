package MusicBrainz::Server::Controller::Role::RelationshipEditor;
use Moose::Role;

use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_CREATE
    $EDIT_RELATIONSHIP_DELETE
);
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Edit::Relationship::Edit;

has attr_tree => ( is => 'rw' );

=method try_and_edit

Try and edit an existing relationship.

First check if the relationship we will end up at already exists, and if so
notify the user and do not continue. Otherwise, insert an edit to edit the
relationship. Also takes care of some general book-keeping in regards to table
locking and race conditions.

=cut

sub try_and_edit {
    my ($self, $c, $form, %params) = @_;

    my $edit;
    $c->model('Relationship')->lock_and_do(
        $params{type0}, $params{type1},
        sub {
            $edit = $self->_try_and_insert_edit(
                $c, $form, $EDIT_RELATIONSHIP_EDIT, %params
            );
        }
    );
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

    my $edit;
    $c->model('Relationship')->lock_and_do(
        $params{type0}, $params{type1},
        sub {
            $edit = $self->_try_and_insert_edit(
                $c, $form, $EDIT_RELATIONSHIP_CREATE, %params
            );
        }
    );
    return $edit;
}

sub delete {
    my ($self, $c, $form, %params) = @_;

    my $edit;
    $c->model('Relationship')->lock_and_do(
        $params{type0}, $params{type1},
        sub {
            $edit = $self->_insert_edit(
                $c, $form, edit_type => $EDIT_RELATIONSHIP_DELETE, %params
            );
            return 1;
        }
    );
    return $edit;
}

sub _try_and_insert_edit {
    my ($self, $c, $form, $edit_type, %params) = @_;

    return undef if $c->model('Relationship')->exists(
        $params{type0}, $params{type1}, {
        link_type_id => $params{link_type}->id,
        begin_date   => $params{begin_date},
        end_date     => $params{end_date},
        ended        => $params{ended},
        attributes   => $params{attributes},
        entity0_id   => $params{entity0}->id,
        entity1_id   => $params{entity1}->id,
    });

    return $self->_insert_edit($c, $form, edit_type => $edit_type, %params);
}

sub flatten_attributes {
    my ($self, $field) = @_;

    my @attributes;
    for my $attr ($self->attr_tree->all_children) {
        my $value = $field->field($attr->name)->value;
        next unless defined($value);

        push @attributes, scalar($attr->all_children)
            ? @$value
            : $value ? $attr->id : ();
    }
    return uniq(@attributes);
}

1;
