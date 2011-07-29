package MusicBrainz::Server::Edit::Alias::Edit;
use Moose;
use MooseX::ABC;

use Clone 'clone';
use Moose::Util::TypeConstraints qw( as subtype find_type_constraint );
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Data::Utils qw( type_to_model );
use MusicBrainz::Server::Edit::Types qw( Nullable );
use MusicBrainz::Server::Validation qw( normalise_strings );

extends 'MusicBrainz::Server::Edit::WithDifferences';
with 'MusicBrainz::Server::Edit::CheckForConflicts';

sub _alias_model { die 'Not implemented' }

subtype 'AliasHash'
    => as Dict[
        name   => Optional[Str],
        locale => Nullable[Str]
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
        locale => {
            new => $self->data->{new}{locale},
            old => $self->data->{old}{locale}
        },
        $type => $loaded->{$model}{ $self->data->{entity}{id} }
            || $self->c->model($model)->_entity_class->new(
                name => $self->data->{entity}{name}
            )
    };
}

sub accept
{
    my $self = shift;
    my $model = $self->_alias_model;
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
    my ($old, $new) = normalise_strings($self->data->{old}{name},
                                        $self->data->{new}{name});

    return $old eq $new;
}

sub current_instance {
    my $self = shift;
    $self->_load_alias;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
