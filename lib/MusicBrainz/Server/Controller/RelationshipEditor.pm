package MusicBrainz::Server::Controller::RelationshipEditor;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

use Encode;
use Text::Unaccent qw( unac_string_utf16 );
use MusicBrainz::Server::Constants qw(
    $EDIT_RELATIONSHIP_DELETE
    $EDIT_WORK_CREATE
);
use MusicBrainz::Server::Form::Utils qw( language_options );

with 'MusicBrainz::Server::Controller::Role::Load' => {
    entity_name => 'release',
    model       => 'Release',
};
with 'MusicBrainz::Server::Controller::Role::RelationshipEditor';

__PACKAGE__->config( namespace => 'release' );

has loaded_entities => (
    is => 'rw',
    isa => 'HashRef'
);

has loaded_relationships => (
    is => 'rw',
    isa => 'HashRef'
);

has edited_fields => (
    is => 'rw',
    isa => 'HashRef'
);

has removed_fields => (
    is => 'rw',
    isa => 'HashRef'
);

has added_fields => (
    is => 'rw',
    isa => 'ArrayRef'
);

sub base : Chained('/') PathPart('release') CaptureArgs(0) { }

after 'load' => sub
{
    my ($self, $c) = @_;
    my $release = $c->stash->{release};
    $c->model('Release')->load_meta($release);
    $c->model('ArtistCredit')->load($release);
    $c->model('ReleaseGroup')->load($release);
};

sub edit_relationships : Chained('load') PathPart('edit-relationships') Edit RequireAuth
{
    my ($self, $c) = @_;

    $self->loaded_entities({});
    $self->loaded_relationships({});
    $self->edited_fields({});
    $self->removed_fields({});
    $self->added_fields([]);

    my $release = $c->stash->{release};

    my @link_type_tree = $c->model('LinkType')->get_full_tree;
    my $attr_tree = $c->model('LinkAttributeType')->get_tree;
    my $attr_map = $c->model('LinkAttributeType')->get_map($attr_tree);
    $self->attr_tree($attr_tree);

    my $language_options = language_options($c);

    # unnaccent instrument attributes names
    unaccent_attributes($attr_map->{$_}, $attr_map) for @{ $attr_map->{14}->{children} };

    $c->stash(
        release => $release,
        work_types => [ $c->model('WorkType')->get_all ],
        work_languages => $self->build_work_languages($c, $language_options),
        type_info => $self->build_type_info($c, @link_type_tree),
        attr_map => $attr_map,
        loaded_entities => $self->loaded_entities,
        loaded_relationships => $self->loaded_relationships,
        error_fields => {},
        params => $c->req->body_parameters,
    );

    my $form = $c->form(
        form => 'RelationshipEditor',
        link_type_tree => \@link_type_tree,
        attr_tree => $attr_tree,
        language_options => $language_options,
    );

    # remove duplicate params
    my $params = $c->req->body_parameters;
    foreach my $key (keys %$params) {
        if (ref($params->{$key}) eq 'ARRAY') {
            $params->{$key} = $params->{$key}->[0];
        }
    }

    if ($c->form_posted && $form->submitted_and_valid($c->req->body_parameters)) {
        $self->submit_edits($c, $form);

        $c->res->redirect($c->uri_for_action('/release/show', [ $release->gid ]));
        $c->detach;
    }
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

    $root->{unaccented} = decode("utf-16", unac_string_utf16(encode("utf-16", $root->{name})));

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

sub is_new_work {
    my $ent = shift;
    return ($ent->{type} eq 'work') && ($ent->{gid} =~ /^new-\d+$/);
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
            # prevents people from submitting a remove and edit action on the same relationship
            $self->removed_fields->{$types} //= {};
            $self->removed_fields->{$types}->{$rel->{id}} = 1;

            my $relationship = $self->loaded_relationships->{$types}->{$rel->{id}};

            $c->model('MB')->with_transaction(sub {
                $self->_insert_edit(
                    $c, $form,
                    edit_type => $EDIT_RELATIONSHIP_DELETE,
                    relationship => $relationship,
                );
            });
        } else {
            my $new_work = is_new_work($entity0) ? $entity0 : (
                           is_new_work($entity1) ? $entity1 : undef);

            if ($new_work && !defined($self->loaded_entities->{$new_work->{gid}})) {
                $self->create_new_work($c, $form, $new_work);
            }
            if ($action eq 'add') {
                push @{ $self->added_fields }, $field;

            } elsif ($action eq 'edit') {
                $self->edited_fields->{$types} //= {};
                $self->edited_fields->{$types}->{$rel->{id}} = $field;
            }
        }
    }
    $self->submit_added_relationships($c, $form);
    $self->submit_edited_relationships($c, $form);
}

sub submit_added_relationships {
    my ($self, $c, $form) = @_;

    foreach my $field (@{ $self->added_fields }) {
        my $rel = $field->value;
        my $entity0 = $rel->{entity}->[0];
        my $entity1 = $rel->{entity}->[1];
        my @attributes = $self->flatten_attributes($field->field('attrs'));

        $self->try_and_insert(
            $c, $form, $entity0->{type}, $entity1->{type}, (
                entity0 => $self->loaded_entities->{$entity0->{gid}},
                entity1 => $self->loaded_entities->{$entity1->{gid}},
                link_type_id => $rel->{link_type},
                attributes => \@attributes,
                begin_date => $rel->{begin_date},
                end_date => $rel->{end_date},
                ended => $rel->{ended},
        ));
    }
}

sub submit_edited_relationships {
    my ($self, $c, $form) = @_;

    foreach my $types (keys %{ $self->edited_fields }) {
        my $edited = $self->edited_fields->{$types};
        my $removed = $self->removed_fields->{$types};

        foreach my $id (keys %$edited) {
            next if exists $removed->{$id};
            my $field = $edited->{$id};
            my $rel = $field->value;
            my $entity0 = $rel->{entity}->[0];
            my $entity1 = $rel->{entity}->[1];

            my $relationship = $self->loaded_relationships->{$types}->{$rel->{id}};
            my @attributes = $self->flatten_attributes($field->field('attrs'));

            $self->try_and_edit(
                $c, $form, $entity0->{type}, $entity1->{type}, $relationship, (
                    new_link_type_id => $rel->{link_type},
                    new_begin_date => $rel->{begin_date},
                    new_end_date => $rel->{end_date},
                    ended => $rel->{ended},
                    attributes => \@attributes,
                    entity0_id => $self->loaded_entities->{$entity0->{gid}}->id,
                    entity1_id => $self->loaded_entities->{$entity1->{gid}}->id,
            ));
        }
    }
}

sub create_new_work {
    my ($self, $c, $form, $new_work) = @_;

    my $edit;
    $c->model('MB')->with_transaction(sub {
        $edit = $self->_insert_edit(
            $c, $form,
            edit_type => $EDIT_WORK_CREATE,
            name => $new_work->{name},
            comment => $new_work->{comment},
            type_id => $new_work->{work_type},
            language_id => $new_work->{work_language}
        );
    });

    $self->loaded_entities->{$new_work->{gid}} =
        $c->model('Work')->get_by_id($edit->entity_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
