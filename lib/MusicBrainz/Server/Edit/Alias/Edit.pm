package MusicBrainz::Server::Edit::Alias::Edit;
use 5.10.0;
use Moose;
use MooseX::ABC;

use Clone 'clone';
use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Data::Utils qw(
    type_to_model
);
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw(
    date_closure
    merge_partial_date
);
use MusicBrainz::Server::Validation qw( normalise_strings );

no if $] >= 5.018, warnings => "experimental::smartmatch";

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::CheckForConflicts';

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
        ended      => Optional[Bool]
    ];

has '+data' => (
    isa => Dict[
        alias_id => Int,
        entity => Dict[
            id   => Int,
            name => Str
        ],
        new => find_type_constraint('AliasHash'),
        old => find_type_constraint('AliasHash'),
    ]
);

has alias => (
    is => 'ro',
    lazy => 1,
    builder => '_load_alias'
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

    return {
        alias => {
            new => $self->data->{new}{name},
            old => $self->data->{old}{name}
        },
        sort_name => {
            new => $self->data->{new}{sort_name},
            old => $self->data->{old}{sort_name}
        },
        locale => {
            new => $self->data->{new}{locale},
            old => $self->data->{old}{locale}
        },
        $type => $loaded->{$model}{ $self->data->{entity}{id} }
            || $self->c->model($model)->_entity_class->new(
                name => $self->data->{entity}{name}
            ),
        type => {
            new => $self->_alias_model->parent->alias_type->get_by_id($self->data->{new}{type_id}),
            old => $self->_alias_model->parent->alias_type->get_by_id($self->data->{old}{type_id}),
        },
        begin_date => {
            new => MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{new}{begin_date}),
            old => MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{old}{begin_date}),
        },
        end_date => {
            new => MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{new}{end_date}),
            old => MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{old}{end_date}),
        },
        primary_for_locale => {
            new => $self->data->{new}{primary_for_locale},
            old => $self->data->{old}{primary_for_locale},
        },
        ended => {
            new => $self->data->{new}{ended},
            old => $self->data->{old}{ended}
        }
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
    given ($property) {
        when ('begin_date') {
            return merge_partial_date('begin_date' => $ancestor, $current, $new);
        }

        when ('end_date') {
            return merge_partial_date('end_date' => $ancestor, $current, $new);
        }

        default {
            return ($self->$orig(@_));
        }
    }
};

sub accept
{
    my $self = shift;
    my $model = $self->_alias_model;

    MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
        'This alias no longer exists'
    ) unless $self->_load_alias;

    $model->update($self->data->{alias_id}, $self->merge_changes);
}

sub initialize
{
    my ($self, %opts) = @_;
    my $alias = delete $opts{alias};
    die "You must specify the alias object to edit" unless defined $alias;
    my $entity = delete $opts{entity} or die 'Missing "entity" argument';
    $self->data({
        alias_id => $alias->id,
        entity => {
            id => $entity->id,
            name => $entity->name
        },
        $self->_change_data($alias, %opts)
    });
}

sub allow_auto_edit
{
    my $self = shift;

    {
        my ($old, $new) = normalise_strings($self->data->{old}{name},
                                            $self->data->{new}{name});
        return 0 if $old ne $new;
    }

    {
        my ($old, $new) = normalise_strings($self->data->{old}{sort_name},
                                            $self->data->{new}{sort_name});
        return 0 if $old ne $new;
    }

    return 0 if $self->data->{old}{type_id};

    return 0 if exists $self->data->{old}{begin_date}
        and MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{old}{begin_date})->format ne '';
    return 0 if exists $self->data->{old}{end_date}
        and MusicBrainz::Server::Entity::PartialDate->new_from_row($self->data->{old}{end_date})->format ne '';

    return 0 if exists $self->data->{old}{ended}
        and $self->data->{old}{ended} != $self->data->{new}{ended};

    return 0 if $self->data->{old}{locale};

    return 0 if exists $self->data->{new}{primary_for_locale};

    return 1;
}

sub current_instance {
    my $self = shift;
    $self->_load_alias;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
