package MusicBrainz::Server::Edit::Alias::Delete;
use Moose;
use MooseX::ABC;

use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Edit::Utils qw( conditions_without_autoedit );

extends 'MusicBrainz::Server::Edit';

sub _alias_model { die 'Not implemented' }

use aliased 'MusicBrainz::Server::Entity::PartialDate';

has '+data' => (
    isa => Dict[
        alias_id  => Int,
        entity    => Dict[
            id   => Int,
            name => Str
        ],
        name      => Str,
        sort_name => Optional[Str],
        locale => Nullable[Str],
        begin_date => Nullable[PartialDateHash],
        end_date => Nullable[PartialDateHash],
        type_id => Nullable[Int],
        primary_for_locale => Nullable[Bool]
    ]
);

sub build_display_data
{
    my $self = shift;
    return {
        entity_type => $self->_alias_model->type,
        alias => $self->data->{name},
        locale => $self->data->{locale},
        sort_name => $self->data->{sort_name},
        type => $self->_alias_model->parent->alias_type->get_by_id($self->data->{type_id}),
        begin_date => PartialDate->new($self->data->{begin_date}),
        end_date => PartialDate->new($self->data->{end_date}),
        primary_for_locale => $self->data->{primary_for_locale}
    };
}

around edit_conditions => sub {
    my ($orig, $self, @args) = @_;
    return conditions_without_autoedit($self->$orig(@args));
};

has 'alias_id' => (
    isa => 'Int',
    is => 'rw',
    default => sub { shift->data->{alias_id} },
    lazy => 1
);

has 'alias' => (
    is => 'rw',
);

sub accept
{
    my $self = shift;
    my $model = $self->_alias_model;
    $model->delete($self->alias_id);
}

sub initialize
{
    my ($self, %opts) = @_;
    my $alias = $opts{alias} or die 'Missing required "alias" argument';
    my $entity = delete $opts{entity} or die 'Missing required "entity" argument';

    $self->data({
        entity    => {
            id   => $entity->id,
            name => $entity->name
        },
        alias_id  => $alias->id,
        name      => $alias->name,
        sort_name => $alias->sort_name,
        locale => $alias->locale,
        begin_date => partial_date_to_hash($alias->begin_date),
        end_date => partial_date_to_hash($alias->end_date),
        type_id => $alias->type_id,
        primary_for_locale => $alias->primary_for_locale
    });
}

sub edit_template { "remove_alias" };

__PACKAGE__->meta->make_immutable;
no Moose;
1;
