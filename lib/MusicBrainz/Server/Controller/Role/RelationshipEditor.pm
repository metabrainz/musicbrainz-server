package MusicBrainz::Server::Controller::Role::RelationshipEditor;
use Moose::Role;

use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_EDIT
    $EDIT_RELATIONSHIP_CREATE
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
    my ($self, $c, $form, $type0, $type1, $rel, %params) = @_;

    $c->model('Relationship')->lock_and_do(
        $type0, $type1,
        sub {
            if ($c->model('Relationship')->exists($type0, $type1, {
                link_type_id => $params{new_link_type_id},
                begin_date   => $params{new_begin_date},
                end_date     => $params{new_end_date},
                ended        => $params{ended},
                attributes   => $params{attributes},
                entity0_id   => $params{entity0_id},
                entity1_id   => $params{entity1_id},
            })) {
                return 0;
            }

            my $link_type = $c->model('LinkType')->get_by_id(
                $params{new_link_type_id}
            );

            my $model0 = $c->model(type_to_model($type0));
            my $model1 = $c->model(type_to_model($type1));

            my $edit = $self->_insert_edit(
                $c, $form,
                edit_type         => $EDIT_RELATIONSHIP_EDIT,
                type0             => $type0,
                type1             => $type1,
                entity0           => $model0->get_by_id($params{entity0_id}),
                entity1           => $model1->get_by_id($params{entity1_id}),
                relationship      => $rel,
                link_type         => $link_type,
                begin_date        => $params{new_begin_date},
                end_date          => $params{new_end_date},
                ended             => $params{ended},
                attributes        => $params{attributes}
            );

            return 1;
        }
    );
}

=method try_and_insert

Try and insert a new relationship.

First check if the relationship already exists, and if it does return false and
do not continue. Otherwise, insert the new relationship and return a true value.

Takes care of necessary bookkeeping such as exclusive locks on the relationship
table.

=cut

sub try_and_insert {
    my ($self, $c, $form, $type0, $type1, %params) = @_;

    $c->model('Relationship')->lock_and_do(
        $type0, $type1,
        sub {
            if ($c->model('Relationship')->exists($type0, $type1, {
                link_type_id => $params{link_type_id},
                begin_date   => $params{begin_date},
                end_date     => $params{end_date},
                ended        => $params{ended},
                attributes   => $params{attributes},
                entity0_id   => $params{entity0}->id,
                entity1_id   => $params{entity1}->id,
            })) {
                return 0;
            }

            my $link_type = $c->model('LinkType')->get_by_id(
                $params{link_type_id}
            );

            $self->_insert_edit(
                $c, $form,
                edit_type    => $EDIT_RELATIONSHIP_CREATE,
                type0        => $type0,
                type1        => $type1,
                entity0      => $params{entity0},
                entity1      => $params{entity1},
                begin_date   => $params{begin_date},
                end_date     => $params{end_date},
                link_type    => $link_type,
                attributes   => $params{attributes},
                ended        => $params{ended}
            );

            return 1;
        }
    );
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
