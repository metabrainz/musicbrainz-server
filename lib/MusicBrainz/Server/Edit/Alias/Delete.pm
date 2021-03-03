package MusicBrainz::Server::Edit::Alias::Delete;
use Moose;
use MooseX::ABC;

use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Data::Utils qw( partial_date_to_hash boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );

extends 'MusicBrainz::Server::Edit';
with 'MusicBrainz::Server::Edit::Alias';
with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

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
        primary_for_locale => Nullable[Bool],
        ended => Optional[Bool],
    ]
);

sub build_display_data
{
    my $self = shift;

    my $end_date = PartialDate->new($self->data->{end_date});
    return {
        entity_type => $self->_alias_model->type,
        alias => $self->data->{name},
        locale => $self->data->{locale},
        sort_name => $self->data->{sort_name},
        type => to_json_object($self->_alias_model->parent->alias_type->get_by_id($self->data->{type_id})),
        begin_date => to_json_object(PartialDate->new($self->data->{begin_date})),
        end_date => to_json_object($end_date),
        # `ended` info was not stored prior to fixing MBS-10460
        ended => boolean_to_json($end_date->is_empty ? $self->data->{ended} : 1),
        primary_for_locale => boolean_to_json($self->data->{primary_for_locale})
    };
}

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
        ended => $alias->ended,
        type_id => $alias->type_id,
        primary_for_locale => $alias->primary_for_locale
    });
}

sub edit_template_react { "AddRemoveAlias" };

__PACKAGE__->meta->make_immutable;
no Moose;
1;
