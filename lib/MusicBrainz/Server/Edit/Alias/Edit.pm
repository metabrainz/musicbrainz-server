package MusicBrainz::Server::Edit::Alias::Edit;
use 5.10.0;
use Moose;
use namespace::autoclean;

use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Data::Utils qw( type_to_model boolean_to_json );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    date_closure
    merge_partial_date
);
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

use aliased 'MusicBrainz::Server::Entity::PartialDate';

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::Alias',
     'MusicBrainz::Server::Edit::CheckForConflicts',
     'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit',
     'MusicBrainz::Server::Edit::Role::CheckOverlongString' => {
        get_string => sub { shift->{new}{name} },
     },
     'MusicBrainz::Server::Edit::Role::CheckOverlongString' => {
        get_string => sub { shift->{new}{sort_name} },
     },
     'MusicBrainz::Server::Edit::Role::DatePeriod';

sub _alias_model { die 'Not implemented' }

subtype 'AliasHash'
    => as Dict[
        name => Optional[Str],
        sort_name => Optional[Str],
        locale => Nullable[Str],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
        type_id => Nullable[Int],
        primary_for_locale => Nullable[Bool],
        ended      => Optional[Bool],
    ];

has '+data' => (
    isa => Dict[
        alias_id => Int,
        entity => Dict[
            id   => Int,
            name => Str,
        ],
        current_locale => Nullable[Str],
        primary_for_locale => Nullable[Bool],
        previous_primary_for_locale => Nullable[Str],
        new => find_type_constraint('AliasHash'),
        old => find_type_constraint('AliasHash'),
    ],
);

has alias => (
    is => 'ro',
    lazy => 1,
    builder => '_load_alias',
);

sub _load_alias {
    my $self = shift;
    return $self->_alias_model->get_by_id($self->alias_id);
}

sub alias_id { shift->data->{alias_id} }

sub foreign_keys
{
    my $self = shift;
    my $model = type_to_model($self->_alias_model->type);
    return {
        $model => [ $self->data->{entity}{id} ],
    };
}

sub build_display_data
{
    my ($self, $loaded) = @_;

    my $type = $self->_alias_model->type;
    my $model = type_to_model($type);

    my $current_alias = $self->current_instance;
    my $locale = $self->data->{current_locale} // $self->data->{new}{locale} // $current_alias->locale;
    use Data::Dumper;
    print Dumper($locale);
    my $is_primary = $current_alias->primary_for_locale;

    my $is_adding_primary = ($self->data->{new}{primary_for_locale} == 1) &&
        ($self->data->{old}{primary_for_locale} == 0);
    my $is_changing_locale_for_primary = $self->data->{new}{locale} &&
        $is_primary;

    my $previous_primary_for_locale = $self->data->{previous_primary_for_locale};
    if ($self->is_open &&
        !defined $previous_primary_for_locale &&
        ($is_adding_primary || $is_changing_locale_for_primary)) {
        my $primary_aliases =
            $self->_alias_model->find_primary_aliases_by_entity_id($self->data->{entity}{id});
        $previous_primary_for_locale = %$primary_aliases{$locale} // '';
    }

    return {
        entity_type => $type,
        $locale ? (current_locale => $locale) : (),
        $previous_primary_for_locale ? (previous_primary_for_locale => $previous_primary_for_locale) : (),
        $is_primary ? (is_primary => $is_primary) : (),
        alias => {
            new => $self->data->{new}{name},
            old => $self->data->{old}{name},
        },
        sort_name => {
            new => $self->data->{new}{sort_name},
            old => $self->data->{old}{sort_name},
        },
        locale => {
            new => $self->data->{new}{locale},
            old => $self->data->{old}{locale},
        },
        $type => to_json_object(
            $loaded->{$model}{ $self->data->{entity}{id} }
            || $self->c->model($model)->_entity_class->new(
                name => $self->data->{entity}{name},
            )),
        type => {
            new => to_json_object($self->_alias_model->parent->alias_type->get_by_id($self->data->{new}{type_id})),
            old => to_json_object($self->_alias_model->parent->alias_type->get_by_id($self->data->{old}{type_id})),
        },
        begin_date => {
            new => to_json_object(PartialDate->new_from_row($self->data->{new}{begin_date})),
            old => to_json_object(PartialDate->new_from_row($self->data->{old}{begin_date})),
        },
        end_date => {
            new => to_json_object(PartialDate->new_from_row($self->data->{new}{end_date})),
            old => to_json_object(PartialDate->new_from_row($self->data->{old}{end_date})),
        },
        primary_for_locale => {
            new => boolean_to_json($self->data->{new}{primary_for_locale}),
            old => boolean_to_json($self->data->{old}{primary_for_locale}),
        },
        ended => {
            new => boolean_to_json($self->data->{new}{ended}),
            old => boolean_to_json($self->data->{old}{ended}),
        },
    };
}

sub _mapping
{
    return (
        begin_date => date_closure('begin_date'),
        end_date => date_closure('end_date'),
    );
}

around extract_property => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my ($property, $ancestor, $current, $new) = @_;
    if ($property eq 'begin_date') {
        return merge_partial_date('begin_date' => $ancestor, $current, $new);
    }
    elsif ($property eq 'end_date') {
        return merge_partial_date('end_date' => $ancestor, $current, $new);
    }
    else {
        return ($self->$orig(@_));
    }
};

sub accept
{
    my $self = shift;
    my $model = $self->_alias_model;
    my $update_data = 0;

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'This alias no longer exists',
    ) unless $self->_load_alias;

    my $current_alias = $self->current_instance;
    my $is_primary = $current_alias->primary_for_locale;

    my $final_locale = $self->data->{new}{locale};

    if (!$final_locale) {
        my $final_locale = $current_alias->locale;
        # We add the alias locale at the time of editing to the edit data
        $self->data->{current_locale} = $final_locale;
        $update_data = 1;
    }

    my $is_adding_primary = ($self->data->{new}{primary_for_locale} == 1) &&
        ($self->data->{old}{primary_for_locale} == 0);
    my $is_changing_locale_for_primary = $self->data->{new}{locale} &&
        $is_primary;

    if ($is_adding_primary || $is_changing_locale_for_primary) {
        my $primary_aliases =
            $model->find_primary_aliases_by_entity_id($self->data->{entity}{id});
        my $previous_primary_for_locale = %$primary_aliases{$final_locale} // '';

        # We add the previous primary locale that was replaced by the edit to the edit data
        $self->data->{previous_primary_for_locale} = $previous_primary_for_locale;
        $update_data = 1;
    }

    if ($update_data) {
        my $json = JSON::XS->new;
        $self->c->sql->update_row('edit_data', { data => $json->encode($self->to_hash) }, { edit => $self->id });
    }

    $model->update($self->data->{alias_id}, $self->merge_changes);
}

sub initialize
{
    my ($self, %opts) = @_;
    my $alias = delete $opts{alias};
    die 'You must specify the alias object to edit' unless defined $alias;
    my $entity = delete $opts{entity} or die 'Missing "entity" argument';

    $self->enforce_dependencies(\%opts);

    $self->data({
        alias_id => $alias->id,
        entity => {
            id => $entity->id,
            name => $entity->name,
        },
        $self->_change_data($alias, %opts),
    });
}

sub current_instance {
    my $self = shift;
    $self->_load_alias;
}

sub edit_template { 'EditAlias' }

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    my $alias = $self->alias;
    $json->{alias} = $alias ? $alias->TO_JSON : undef;
    return $json;
};

__PACKAGE__->meta->make_immutable;

1;
