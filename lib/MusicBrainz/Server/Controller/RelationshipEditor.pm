package MusicBrainz::Server::Controller::RelationshipEditor;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use JSON;
use Encode;
use Text::Unaccent qw( unac_string_utf16 );
use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_DELETE
    $EDIT_WORK_CREATE
);
use MusicBrainz::Server::Form::Utils qw( language_options );
use MusicBrainz::Server::Translation qw( l );

with 'MusicBrainz::Server::Controller::Role::RelationshipEditor';

__PACKAGE__->config( namespace => 'relationship_editor' );

sub base : Path('/relationship-editor') Args(0) Edit RequireAuth {
    my ($self, $c) = @_;

    my $json = JSON::XS->new;
    $c->res->content_type('application/json; charset=utf-8');

    if ($c->form_posted) {
        my $form = $self->load_form($c);

        # remove duplicate params
        my $params = $c->req->body_parameters;
        foreach my $key (keys %$params) {
            if (ref($params->{$key}) eq 'ARRAY') {
                $params->{$key} = $params->{$key}->[0];
            }
        }
        if ($form->submitted_and_valid($c->req->body_parameters)) {
            $self->submit_edits($c, $form);
            $c->res->body($json->encode({message => 'OK'}));
        } else {
            $c->res->status(400);
            $c->res->body($json->encode({
                message => l('There were errors in your submission. Please fix ' .
                             'them and try again.'),
                errors => $c->stash->{errors},
            }));
        }
    } else {
        $c->res->status(400);
        $c->res->body($json->encode({message => l('Invalid submission.')}));
    }
}

sub load_form : Private {
    my ($self, $c) = @_;

    my $language_options = language_options($c);
    my @link_type_tree = $c->model('LinkType')->get_full_tree;
    my $attr_tree = $c->model('LinkAttributeType')->get_tree;
    $self->attr_tree($attr_tree);

    $c->stash(
        loaded_entities => {},
        loaded_relationships => {},
        errors => {},
    );

    return $c->form(
        form => 'RelationshipEditor',
        link_type_tree => \@link_type_tree,
        attr_tree => $attr_tree,
        language_options => $language_options,
    );
}

sub load : Private {
    my ($self, $c) = @_;

    my $form = $self->load_form($c);
    my $json = JSON::XS->new;
    my $attr_map = $c->model('LinkAttributeType')->get_map($self->attr_tree);

    # unnaccent instrument attributes names
    unaccent_attributes($attr_map->{$_}, $attr_map) for @{ $attr_map->{14}->{children} };

    $c->stash(
        attr_map => $json->encode($attr_map),
        type_info => $json->encode($self->build_type_info($c, @{ $form->link_type_tree })),
        work_types => [ $c->model('WorkType')->get_all ],
        work_languages => $self->build_work_languages($c, $form->language_options),
    );
}

sub build_type_info {
    my ($self, $c, @link_type_tree) = @_;

    my %type_info;
    foreach (@link_type_tree) {
        next if $_->name !~ /(recording|work|release(?!_group))/;
        my %tmp = $c->model('LinkType')->build_type_info($_);
        @type_info{ keys %tmp } = values %tmp;
    }
    return \%type_info;
}

sub unaccent_attributes {
    my ($root, $map) = @_;

    my $unaccented = decode("utf-16", unac_string_utf16(encode("utf-16", $root->{name})));
    if ($unaccented ne $root->{name}) {
        $root->{unaccented} = $unaccented;
    }
    if (defined $root->{children}) {
        unaccent_attributes($map->{$_}, $map) for @{ $root->{children} };
    }
}

sub build_work_languages {
    my ($self, $c, $language_options) = @_;

    my @work_languages;
    foreach my $lang (@$language_options) {

        my $i = $lang->{optgroup_order} - 1;
        $work_languages[$i] //= { optgroup => $lang->{optgroup}, options  => [] };

        push @{ $work_languages[$i]{options} },
              { label => $lang->{label}, value => $lang->{value} };
    }
    return \@work_languages;
}

sub submit_edits {
    my ($self, $c, $form) = @_;

    foreach my $field ($form->field('rels')->fields) {
        my $rel = $field->value;

        my $action = $rel->{action};
        my $entity0 = $rel->{entity}->[0];
        my $entity1 = $rel->{entity}->[1];
        my $types =  $entity0->{type} . '-' . $entity1->{type};

        if ($action eq 'remove') {
            $self->remove_relationship($c, $form, $field, $types);

        } elsif ($action eq 'add') {
            $self->add_relationship($c, $form, $field);

        } elsif ($action eq 'edit') {
            $self->edit_relationship($c, $form, $field, $types);
        }
    }
}

sub remove_relationship {
    my ($self, $c, $form, $field, $types) = @_;

    my $id = $field->field('id')->value;
    my $relationship = $c->stash->{loaded_relationships}->{$types}->{$id};

    $c->model('MB')->with_transaction(sub {
        $self->_insert_edit(
            $c, $form,
            edit_type => $EDIT_RELATIONSHIP_DELETE,
            relationship => $relationship,
        );
    });
}

sub add_relationship {
    my ($self, $c, $form, $field) = @_;

    my $rel = $field->value;
    my $entity0 = $rel->{entity}->[0];
    my $entity1 = $rel->{entity}->[1];
    my @attributes = $self->flatten_attributes($field->field('attrs'));

    $self->try_and_insert(
        $c, $form, $entity0->{type}, $entity1->{type}, (
            entity0 => $c->stash->{loaded_entities}->{$entity0->{gid}},
            entity1 => $c->stash->{loaded_entities}->{$entity1->{gid}},
            link_type_id => $rel->{link_type},
            attributes => \@attributes,
            begin_date => $rel->{begin_date},
            end_date => $rel->{end_date},
            ended => 0,
    ));
}

sub edit_relationship {
    my ($self, $c, $form, $field, $types) = @_;

    my $rel = $field->value;
    my $entity0 = $rel->{entity}->[0];
    my $entity1 = $rel->{entity}->[1];

    my $relationship = $c->stash->{loaded_relationships}->{$types}->{$rel->{id}};
    my @attributes = $self->flatten_attributes($field->field('attrs'));

    $self->try_and_edit(
        $c, $form, $entity0->{type}, $entity1->{type}, $relationship, (
            new_link_type_id => $rel->{link_type},
            new_begin_date => $rel->{begin_date},
            new_end_date => $rel->{end_date},
            attributes => \@attributes,
            entity0_id => $c->stash->{loaded_entities}->{$entity0->{gid}}->id,
            entity1_id => $c->stash->{loaded_entities}->{$entity1->{gid}}->id,
            ended => $relationship->link->ended,
    ));
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
