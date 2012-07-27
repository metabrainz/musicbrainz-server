package MusicBrainz::Server::Form::RelationshipEditor;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Form::Relationship::LinkType qw ( validate_link_type );

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
    type => 'Text',
    required => 1
);

has_field 'rels.action' => (
    type => 'Select',
    required => 1
);

has_field 'rels.link_type' => (
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

has_field 'rels.entity.comment' => (
    type      => '+MusicBrainz::Server::Form::Field::Comment',
    maxlength => 255
);

has_field 'rels.entity.work_type' => (
    type => 'Select'
);

has_field 'rels.entity.work_language' => (
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

sub options_rels_entity_work_type {
    shift->_select_all('WorkType');
}

sub options_rels_entity_work_language {
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

        my $link_type_field = $field->field('link_type');
        next if !$link_type_field->value || $link_type_field->has_errors;

        validate_link_type($c, $field->field('link_type'), $field->field('attrs'));

        my $begin_date = $field->field('begin_date');
        my $end_date = $field->field('end_date');

        if (!$begin_date->has_errors && !$end_date->has_errors) {

            my $y1 = $begin_date->field('year')->value;
            my $m1 = $begin_date->field('month')->value;
            my $d1 = $begin_date->field('day')->value;

            my $y2 = $end_date->field('year')->value;
            my $m2 = $end_date->field('month')->value;
            my $d2 = $end_date->field('day')->value;

            if (MusicBrainz::Server::Validation::IsDateEarlierThan(
                    $y2, $m2, $d2, $y1, $m1, $d1)) {

                $end_date->add_error(l('The end date cannot precede the begin date.'));
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
        my $loaded_entities = $c->stash->{loaded_entities};

        foreach my $ent_field (($entity0, $entity1)) {
            my $ent = $ent_field->value;

            my $valid_ids = MusicBrainz::Server::Validation::IsGUID($ent->{gid})
                && $ent->{id} =~ /^\d+$/;
            my $new_work = $ent->{type} eq 'work' && $ent->{id} eq $ent->{gid};

            if (!$valid_ids && !$new_work) {
                $ent_field->add_error(l('This entity has an invalid ID or MBID.'));

            } elsif (!$new_work && !defined($loaded_entities->{$ent->{gid}})) {
                my $model = type_to_model($ent->{type});
                my $ent_data = $c->model($model)->get_by_id($ent->{id});

                if ($ent_data) {
                    $loaded_entities->{$ent->{gid}} = $ent_data;
                } else {
                    $ent_field->add_error(l('This entity does not exist.'));
                }
            }
            $i++;
        }
        next if $field->field('id')->has_errors;

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
        $self->_get_errors($c, $field, $field->field('id')->value);
    }
};

sub _get_errors {
    my ($self, $c, $field, $id) = @_;

    if ($field->has_errors) {
        my $name = $field->full_name;
        $name =~ s/^rels\.\d+\.//;

        $c->stash->{error_fields}->{$id} //= {};
        $c->stash->{error_fields}->{$id}->{$name} = $field->errors;
    }
    if ($field->has_fields) {
        $self->_get_errors($c, $_, $id) for $field->fields;
    }
}

sub edit_field_names { qw() }

1;
