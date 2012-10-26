package MusicBrainz::Server::Form::RelationshipEditor;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Validation qw( is_guid );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::LinkType' => {
    -alias    => { field_list => '_field_list' },
    -excludes => 'field_list'
};

has '+name' => ( default => 'rel-editor' );

has link_type_tree => (
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
    type => 'Integer',
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

has_field 'rels.entity.gid' => (
    type => 'Text',
    required => 1
);

has_field 'rels.entity.type' => (
    type => 'Select',
    required => 1
);

has_field 'rels.period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod'
);

has_field 'rels.attrs' => (
    type => 'Compound'
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

sub options_rels_entity_type {
    return [
        'artist' => 'artist',
        'label' => 'label',
        'recording' => 'recording',
        'release' => 'release',
        'release_group' => 'release_group',
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

sub field_list
{
    my ($self) = @_;

    return $self->_field_list('rels.', undef);
}

after validate => sub {
    my ($self) = @_;

    my $c = $self->ctx;

    foreach my $field ($self->field('rels')->fields) {

        my $link_type_field = $field->field('link_type');
        next if !$link_type_field->value || $link_type_field->has_errors;

        $self->validate_link_type($c, $field->field('link_type'), $field->field('attrs'));

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

            if (!is_guid($ent->{gid})) {
                $ent_field->add_error(l('This entity has an invalid ID or MBID.'));

            } elsif (!defined($loaded_entities->{$ent->{gid}})) {
                my $model = type_to_model($ent->{type});
                my $ent_data = $c->model($model)->get_by_gid($ent->{gid});

                if ($ent_data) {
                    $loaded_entities->{$ent->{gid}} = $ent_data;
                } else {
                    $ent_field->add_error(l('This entity does not exist.'));
                }
            }
            $i++;
        }
        my $id_field = $field->field('id');
        next if $id_field->has_errors;

        if ($field->field('action')->value =~ /^(edit|remove)$/) {
            my $id = $id_field->value;

            if (!defined($id)) {
                $id_field->add_error(l('Required field.'));
                next;
            }
            my $type0 = $entity0->field('type')->value;
            my $type1 = $entity1->field('type')->value;
            my $types = $type0 . '-' . $type1;
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
    my $num = 0;
    foreach my $field ($self->field('rels')->fields) {
        $self->_get_errors($c, $field, $num++);
    }
};

sub _get_errors {
    my ($self, $c, $field, $num) = @_;

    if ($field->has_errors) {
        my $name = $field->full_name;
        $name =~ s/^rels\.\d+\.//;

        $c->stash->{errors}->{$num} //= {};
        $c->stash->{errors}->{$num}->{$name} = $field->errors;
    }
    if ($field->has_fields) {
        $self->_get_errors($c, $_, $num) for $field->fields;
    }
}

sub edit_field_names { qw() }

1;
