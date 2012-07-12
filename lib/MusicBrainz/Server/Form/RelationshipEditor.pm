package MusicBrainz::Server::Form::RelationshipEditor;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Data::Utils qw( type_to_model );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'rel-editor' );

has link_type_tree => (
    is => 'ro',
    required => 1
);

has attr_tree => (
    is => 'ro',
    required => 1
);

has language_options => (
    is => 'ro',
    required => 1
);

has_field 'rels' => (
    type => 'Repeatable'
);

has_field 'rels.id' => (
    type => 'Integer'
);

has_field 'rels.action' => (
    type => 'Select',
    required => 1
);

has_field 'rels.link_type' => (
    type => 'Integer',
    required => 1
);

has_field 'rels.num' => (
    type => 'Integer',
    required => 1
);

has_field 'rels.entity' => (
    type => 'Repeatable',
    required => 1
);

has_field 'rels.entity.id' => (
    type => 'Text',
    required => 1
);

has_field 'rels.entity.name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1
);

has_field 'rels.entity.gid' => (
    type => 'Text',
    required => 1
);

has_field 'rels.entity.type' => (
    type => 'Select',
    required => 1
);

has_field 'rels.entity.sortname' => (
    type => '+MusicBrainz::Server::Form::Field::Text'
);

has_field 'rels.entity.work_comment' => (
    type      => '+MusicBrainz::Server::Form::Field::Comment',
    maxlength => 255
);

has_field 'rels.entity.work_type_id' => (
    type => 'Select'
);

has_field 'rels.entity.work_language_id' => (
    type => 'Select'
);

has_field 'rels.begin_date' => (
    type => '+MusicBrainz::Server::Form::Field::PartialDate'
);

has_field 'rels.end_date' => (
    type => '+MusicBrainz::Server::Form::Field::PartialDate'
);

has_field 'rels.ended' => (
    type => 'Boolean'
);

has_field 'rels.attrs' => (
    type => 'Compound'
);

has_field 'rels.direction' => (
    type => 'Select'
);

sub options_rels_work_type_id {
    shift->_select_all('WorkType');
}

sub options_rels_work_language_id {
    return shift->language_options;
}

sub options_rels_action {
    return [
        'remove' => 'remove',
        'add' => 'add',
        'edit' => 'edit'
    ];
}

sub options_rels_direction {
    return [
        'forward' => 'forward',
        'backward' => 'backward'
    ];
}

sub options_rels_entity_type {
    return [
        'artist' => 'artist',
        'label' => 'label',
        'recording' => 'recording',
        'release' => 'release',
        'url' => 'url',
        'work' => 'work'
    ];
}

sub options_rels_link_type
{
    my ($self) = @_;

    my @options;
    for my $root (@{ $self->link_type_tree }) {
        push @options, $self->_build_options($root, 'ROOT');
    }
    return \@options;
}

sub _build_options
{
    my ($self, $root, $ignore) = @_;

    my @options;
    if ($root->id && $root->name ne $ignore) {
        push @options, { value => $root->id, label => $root->name };
    }
    foreach my $child ($root->all_children) {
        push @options, $self->_build_options($child, $ignore);
    }
    return @options;
}

sub field_list
{
    my ($self) = @_;

    my @fields;
    foreach my $attr ($self->attr_tree->all_children) {
        if ($attr->all_children) {
            my @options = $self->_build_options($attr, $attr->name);
            push @fields, 'rels.attrs.' . $attr->name, { type => 'Repeatable' };
            push @fields, 'rels.attrs.' . $attr->name . '.contains', {
                type => 'Select',
                options => \@options,
            };
        } else {
            push @fields, 'rels.attrs.' . $attr->name, { type => 'Boolean' };
        }
    }
    return \@fields;
}

after validate => sub {
    my ($self) = @_;

    my $c = $self->ctx;

    foreach my $field ($self->field('rels')->fields) {
        my $link_type_id = $field->field('link_type')->value;
        return if !$link_type_id;

        my $link_type = $c->model('LinkType')->get_by_id($link_type_id);

        if (!$link_type->description) {
            $field->field('link_type')->add_error(
                l('This relationship type is used to group other relationships. '.
                  'Please select a subtype of the currently selected '.
                  'relationship type.')
            );
            return;
        } elsif ($link_type->description =~ /This relationship type is <strong>deprecated<\/strong>/) {
            $field->field('link_type')->add_error(
                l("This relationship type is deprecated.")
            );
            return
        }

        my %attribute_bounds = map { $_->type_id => [$_->min, $_->max] }
            $link_type->all_attributes;

        foreach my $attr ($self->attr_tree->all_children) {
            # Try and find the values for the current attribute (attributes may
            # have more than 1 value)
            my @values = ();
            if (my $value = $field->field('attrs')->field($attr->name)->value) {
                @values = $attr->all_children ? @{ $value } : ($attr->id);
            }

            # If we have some values, make sure this attribute is allowed for
            # the current link type
            if (@values && !exists $attribute_bounds{ $attr->id }) {
                $field->field('attrs')->field($attr->name)->add_error(
                    l('This attribute is not supported for the selected relationship type.'));
            }

            # No values, continue if the attribute is not present (no further checks)
            next unless exists $attribute_bounds{ $attr->id };

            # This attribute is allowed on this attirbute, make sure we're
            # within min and max
            my ($min, $max) = @{ $attribute_bounds{$attr->id} };
            if (defined($min) && @values < $min) {
                $field->field('attrs')->field($attr->name)->add_error(
                    l('This attribute is required.'));
            }

            if (defined($max) && scalar(@values) > $max) {
                $field->field('attrs')->field($attr->name)->add_error(
                    l('This attribute can only be specified {max} times. '.
                      'You specified {n}.', {
                          max => $max,
                          n => scalar(@values)
                      }));
            }
        }

        my $entity0 = $field->field('entity')->field('0');
        my $entity1 = $field->field('entity')->field('1');

        if (!($entity0 && scalar($entity0->value) && $entity1 && scalar($entity1->value))) {
            $field->add_error(l('The relationship is missing one or both entities.'));
            next;
        }
        next if ($entity0->field('type')->has_errors || $entity1->field('type')->has_errors);

        my $i = 0;
        foreach my $ent_field (($entity0, $entity1)) {
            my $ent = $ent_field->value;

            my $valid_ids = MusicBrainz::Server::Validation::IsGUID($ent->{gid})
                && $ent->{id} =~ /^\d+$/;
            my $new_work = $ent->{type} eq 'work' && $ent->{id} eq $ent->{gid};

            if (!$valid_ids && !$new_work) {
                $ent_field->add_error(l('This entity has an invalid ID or MBID.'));
            } elsif (!$new_work) {
                my $model = type_to_model($ent->{type});
                my $ent_data = $c->model($model)->get_by_id($ent->{id});

                if ($ent_data) {
                    $c->stash->{loaded_entities}->{$ent->{gid}} = $ent_data;
                } else {
                    $ent_field->add_error(l('This entity does not exist.'));
                }
            }
            $i++;
        }

        if ($field->field('action')->value =~ /^(edit|remove)$/) {
            my $type0 = $entity0->field('type')->value;
            my $type1 = $entity1->field('type')->value;
            my $types = $type0 . '-' . $type1;
            my $id = $field->field('id')->value;
            my $rel = $c->model('Relationship')->get_by_id($type0, $type1, $id);

            if ($rel) {
                $c->model('Link')->load($rel);
                $c->model('LinkType')->load($rel->link);
                $c->stash->{loaded_relationships}->{$types} //= {};
                $c->stash->{loaded_relationships}->{$types}->{$id} = $rel;
            } else {
                $field->add_error(l('This relationship no longer exists.'));
            }
        }
    }
    foreach my $field ($self->field('rels')->fields) {
        $self->_get_errors($c, $field, $field->field('num')->value);
    }
};

sub _get_errors {
    my ($self, $c, $field, $num) = @_;

    if ($field->has_errors) {
        (my $name = $field->html_name) =~ s/rels\.\d+/rels\.$num/;
        $c->stash->{error_fields}->{$name} = $field->errors;
    }
    if ($field->has_fields) {
        foreach my $subfield ($field->fields) {
            $self->_get_errors($c, $subfield, $num);
        }
    }
}

sub edit_field_names { qw() }

1;
