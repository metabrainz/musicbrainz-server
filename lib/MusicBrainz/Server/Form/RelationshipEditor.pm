package MusicBrainz::Server::Form::RelationshipEditor;
use Moose;
use MusicBrainz::Server::CGI::Expand;
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_guid );
use Scalar::Util qw( looks_like_number );

with 'MusicBrainz::Server::Form::Role::LinkType' => {
    -alias    => { field_list => '_field_list' },
    -excludes => 'field_list'
};

has ctx => (
    isa => 'Object',
    required => 1,
    is => 'ro'
);

with 'MusicBrainz::Server::Form::Role::SelectAll';

has link_type_tree => (
    is => 'ro',
    required => 1
);

has language_options => (
    is => 'ro',
    required => 1
);

my %actions = map { $_ => 1 } qw( remove add edit );

my %relatable_entity_types = map { $_ => 1 }
    qw( artist label recording release release_group url work );

sub validate {
    my ($self, $submission) = @_;

    my $expanded = MusicBrainz::Server::CGI::Expand->expand_hash($submission);

    # Basic structure parsing
    return undef unless (
        $expanded &&
        ref($expanded) eq 'HASH' &&
        exists($expanded->{'rel-editor'}) &&
        ref($expanded->{'rel-editor'}) eq 'HASH' &&
        exists($expanded->{'rel-editor'}->{rels}) &&
        ref($expanded->{'rel-editor'}{rels}) eq 'ARRAY'
    );

    my $form_like = bless $expanded->{'rel-editor'}, 'ApparentlyAForm';

    foreach my $field ($form_like->field('rels')->fields) {
        $field->field('id')->add_error(l('ID must be an integer'))
            unless defined($field->field('id')->value) &&
                looks_like_number($field->field('id')->value);

        my $link_type_field = $field->field('link_type');
        next if !$link_type_field->value || $link_type_field->has_errors;

        $field->field('action')->add_error(l('Unknown action'))
            unless exists($actions{$field->field('action')->value});
        my $action = $field->field('action')->value;
        my $link_type = $self->validate_link_type(
                $self->ctx, $field->field('link_type'), $field->field('attrs'),
                $action eq 'remove');

        my $entity0 = $field->field('entity')->field('0');
        my $entity1 = $field->field('entity')->field('1');

        if (!($entity0 && scalar($entity0->value) && $entity1 && scalar($entity1->value))) {
            $field->add_error(l('The relationship is missing one or both entities.'));
            next;
        }
        next if ($entity0->field('type')->has_errors || $entity1->field('type')->has_errors);

        # Check that these types are valid for the link type
        my $type0 = $entity0->field('type')->value;
        my $type1 = $entity1->field('type')->value;

        $entity0->field('type')->add_error(l('Unknown entity type'))
            unless $relatable_entity_types{$type0};

        $entity1->field('type')->add_error(l('Unknown entity type'))
            unless $relatable_entity_types{$type1};

        if ($type0 ne $link_type->entity0_type || $type1 ne $link_type->entity1_type) {
            $link_type_field->add_error(
                l('This relationship type is not valid between the given types of entities.'));
        }

        next if $link_type_field->has_errors;

        my $i = 0;
        my $loaded_entities = $self->ctx->stash->{loaded_entities};

        foreach my $ent_field (($entity0, $entity1)) {
            my $ent = $ent_field->value;

            if (!is_guid($ent->{gid})) {
                $ent_field->add_error(l('This entity has an invalid ID or MBID.'));

            } elsif (!defined($loaded_entities->{$ent->{gid}})) {
                my $model = type_to_model($ent->{type});
                my $ent_data = $self->ctx->model($model)->get_by_gid($ent->{gid});

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

        if ($action =~ /^(edit|remove)$/) {
            my $id = $id_field->value;

            if (!defined($id)) {
                $id_field->add_error(l('Required field.'));
                next;
            }
            my $types = $type0 . '-' . $type1;
            my $rel = $self->ctx->model('Relationship')->get_by_id($type0, $type1, $id);

            if ($rel) {
                $self->ctx->model('Link')->load($rel);
                $self->ctx->model('LinkType')->load($rel->link);
                $self->ctx->stash->{loaded_relationships}->{$types} //= {};
                $self->ctx->stash->{loaded_relationships}->{$types}->{$id} = $rel;
            } else {
                $field->add_error(l('This relationship no longer exists.'));
            }
        }
    }
    my $num = 0;
    foreach my $field ($form_like->field('rels')->fields) {
        $self->_get_errors($self->ctx, $field, $num++);
    }

    return $form_like;
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

package ApparentlyAForm;

sub field {
    my ($self, $field) = @_;
    return bless { val => $self->{$field} }, 'ApparentlyAField';
}

sub does {
    my ($self, $role) = @_;
    return $role eq 'MusicBrainz::Server::Form::Role::Edit';
}

package ApparentlyAField;

sub fields {
    my $self = shift;

    my @fields =
        ref ($self->value) eq 'ARRAY' ? @{ $self->value } :
        ref ($self->value) eq 'HASH'  ? values %{ $self->value }
                                      : ();

    return map { bless { val => $_ }, 'ApparentlyAField' } @fields;
}

sub field {
    my ($self, $field) = @_;

    if (!defined($self->value)) {
        return bless { val => undef }, 'ApparentlyAField';
    }
    elsif ($field =~ /^\d+$/ && exists($self->value->[$field])) {
        return bless { val => $self->value->[$field] }, 'ApparentlyAField';
    }
    elsif (exists ($self->value->{$field})) {
        return bless { val => $self->value->{$field} }, 'ApparentlyAField';
    }
    else {
        return bless { val => undef }, 'ApparentlyAField';
    }
}

sub value { shift->{val} }

sub has_errors { 0 }

sub has_fields {
    my $self = shift;
    return ref($self->value) ? 1 : 0;
}

sub add_error {
    my ($self, $error) = @_;
    push @{ $self->{errors} //= [] }, $error;
}

1;
