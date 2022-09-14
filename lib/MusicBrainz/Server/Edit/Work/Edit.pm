package MusicBrainz::Server::Edit::Work::Edit;
use Moose;
use 5.10.0;

use Clone qw( clone );
use JSON;
use MooseX::Types::Moose qw( ArrayRef Int Maybe Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Constants qw(
    $EDIT_WORK_CREATE
    $EDIT_WORK_EDIT
);
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Edit::Utils qw(
    changed_relations
    changed_display_data
);
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
use MusicBrainz::Server::Translation qw( N_l );
use Set::Scalar;

use aliased 'MusicBrainz::Server::Entity::Work';

extends 'MusicBrainz::Server::Edit::Generic::Edit';
with 'MusicBrainz::Server::Edit::Work::RelatedEntities';
with 'MusicBrainz::Server::Edit::Work';
with 'MusicBrainz::Server::Edit::CheckForConflicts';
with 'MusicBrainz::Server::Edit::Role::AllowAmending' => {
    create_edit_type => $EDIT_WORK_CREATE,
    entity_type => 'work',
};
with 'MusicBrainz::Server::Edit::Role::ValueSet' => {
    prop_name => 'attributes',
    get_current => sub { shift->current_instance->attributes },
    extract_value => \&_work_attribute_to_edit,
    hash => sub {
        my $input = shift;
        state $json = JSON->new->allow_blessed->canonical;

        # The various string append and 0 additions here are to create a
        # canonical form for hashing, as we will later be doing a string
        # comparison on the JavaScript. Thus "foo":0 and "foo":"0" will be
        # different, so we need to make sure all keys are normalised.
        return $json->encode({
            attribute_text => '' . ($input->{attribute_text} // ''),
            attribute_type_id => 0 + $input->{attribute_type_id},
            attribute_value_id => 0 + ($input->{attribute_value_id} // 0),
        });
    }
};
with 'MusicBrainz::Server::Edit::Role::ValueSet' => {
    prop_name => 'languages',
    get_current => sub {
        my $self = shift;

        $self->c->model('Work')->language->find_by_entity_id($self->entity_id);
    },
    extract_value => sub { shift->language_id },
};

sub _mapping {
    my $self = shift;
    return (
        attributes => sub {
            my $instance = shift;
            return [
                map { _work_attribute_to_edit($_) } $instance->all_attributes
            ];
        },
        languages => sub {
            return [map { $_->language_id } shift->all_languages];
        },
    );
}

sub _work_attribute_to_edit {
    my $work_attribute = shift;
    return {
        attribute_text =>
            $work_attribute->value_id ? undef : $work_attribute->value,
        attribute_value_id => $work_attribute->value_id,
        attribute_type_id => $work_attribute->type->id
    };
}

sub edit_type { $EDIT_WORK_EDIT }
sub edit_name { N_l('Edit work') }
sub edit_template { 'EditWork' }
sub _edit_model { 'Work' }
sub work_id { shift->entity_id }

sub change_fields
{
    return Dict[
        name          => Optional[Str],
        comment       => Nullable[Str],
        type_id       => Nullable[Str],
        language_id   => Nullable[Int],
        languages     => Optional[ArrayRef[Int]],
        iswc          => Nullable[Str],
        attributes    => Optional[ArrayRef[Dict[
            attribute_text => Maybe[Str],
            attribute_value_id => Maybe[Int],
            attribute_type_id => Int
        ]]]
    ];
}

has '+data' => (
    isa => Dict[
        entity => Dict[
            id => Int,
            gid => Optional[Str],
            name => Str
        ],
        new => change_fields(),
        old => change_fields()
    ],
);

sub foreign_keys
{
    my $self = shift;
    my $data = $self->data;
    my $relations = {};
    changed_relations($data, $relations,
        WorkType => 'type_id',
    );

    $relations->{Work} = [ $self->entity_id ];

    for my $side (qw( old new )) {
        $relations->{Language}{$_} = []
            for @{ $data->{$side}{languages} // [] };
    }

    return $relations;
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my %map = (
        name      => 'name',
        comment   => 'comment',
        type      => [ qw( type_id WorkType ) ],
        iswc      => 'iswc',
    );

    my $data = $self->data;
    my $display = changed_display_data($data, $loaded, %map);

    $display->{work} = to_json_object(
        $loaded->{Work}{ $self->entity_id } ||
        Work->new( name => $data->{entity}{name} )
    );

    if (exists $data->{new}{attributes}) {
        $display->{attributes} = {};

        my %new = $self->grouped_attributes_by_type($data->{new}{attributes});
        my %old = $self->grouped_attributes_by_type($data->{old}{attributes});

        my $changed_types = Set::Scalar->new(keys %new, keys %old);

        while (defined(my $type = $changed_types->each)) {
            my @new_values = map { $_->l_value } @{ $new{$type} //= [] };
            my @old_values = map { $_->l_value } @{ $old{$type} //= [] };

            unless (Set::Scalar->new(@new_values) == Set::Scalar->new(@old_values)) {
                $display->{attributes}{$type} = { new => \@new_values, old => \@old_values };
            }
        }
    }

    if (exists $data->{new}{languages}) {
        for my $side (qw( old new )) {
            $display->{languages}{$side} = to_json_array[
                map { $loaded->{Language}{$_} } @{ $data->{$side}{languages} // [] }
            ];
        }
    }

    if (exists $display->{type}) {
        $display->{type}{old} = to_json_object($display->{type}{old});
        $display->{type}{new} = to_json_object($display->{type}{new});
    }

    return $display;
}

around allow_auto_edit => sub {
    my ($orig, $self, @args) = @_;

    return 1 if $self->can_amend($self->entity_id);

    return 0 if @{ $self->data->{old}{languages} // [] };

    return 0 if !$self->$orig(@args);

    return 1 if defined $self->data->{old}{attributes} && scalar $self->data->{old}{attributes} == 0;

    if (exists $self->data->{new}{attributes}) {
        my %new = $self->grouped_attributes_by_type($self->data->{new}{attributes});
        my %old = $self->grouped_attributes_by_type($self->data->{old}{attributes});

        my $changed_types = Set::Scalar->new(keys %new, keys %old);

        while (defined(my $type = $changed_types->each)) {
            my @new_values = map { $_->l_value } @{ $new{$type} //= [] };
            my @old_values = map { $_->l_value } @{ $old{$type} //= [] };

            unless (scalar @old_values == 0 || Set::Scalar->new(@new_values) == Set::Scalar->new(@old_values)) {
                return 0;
            }
        }
    }

    return 1;
};

sub current_instance {
    my $self = shift;
    my $work = $self->c->model('Work')->get_by_id($self->entity_id);
    $self->c->model('WorkAttribute')->load_for_works($work);
    $self->c->model('Language')->load_for_works($work);
    return $work;
}

around new_data => sub {
    my $orig = shift;
    my $self = shift;
    my $d = clone($self->$orig);
    delete $d->{iswc};
    return $d;
};

sub _edit_hash {
    my ($self, $data) = @_;
    my $d = $self->merge_changes;
    delete $d->{iswc};
    return $d;
};

after accept => sub {
    my $self = shift;

    if (exists $self->data->{new}{iswc}) {
        my @iswcs = $self->c->model('ISWC')->find_by_works($self->work_id);

        # This adds a new ISWC
        if (!$self->data->{old}{iswc} && @iswcs == 0) {
            $self->c->model('ISWC')->insert({ work_id => $self->work_id,
                                              iswc => $self->data->{new}{iswc} });
        }
        elsif (@iswcs == 1 && ($self->data->{old}{iswc} // '') eq $iswcs[0]->iswc){
            $self->c->model('ISWC')->delete($iswcs[0]->id);
            if (my $iswc = $self->data->{new}{iswc}) {
                $self->c->model('ISWC')->insert({ work_id => $self->work_id,
                                                  iswc => $iswc });
            }
        }
        else {
            MusicBrainz::Server::Edit::Exceptions::FailedDependency
                  ->throw('Data has changed since this edit was created, and now conflicts ' .
                              'with changes made in this edit.');
        }
    }

    if (my $attributes = $self->_edit_hash->{attributes}) {
        $self->c->model('Work')->set_attributes($self->work_id, @$attributes);
    }

    if (my $languages = $self->_edit_hash->{languages}) {
        $self->c->model('Work')->language->set($self->work_id, @$languages);
    }
};

sub restore {
    my ($self, $data) = @_;

    for my $side (qw( old new )) {
        $data->{$side}{languages} = [ delete $data->{$side}{language_id} // () ]
            if exists $data->{$side}{language_id};
    }

    $self->data($data);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
