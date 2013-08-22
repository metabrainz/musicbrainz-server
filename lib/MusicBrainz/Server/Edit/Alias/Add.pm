package MusicBrainz::Server::Edit::Alias::Add;
use Moose;
use MooseX::ABC;

use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );

extends 'MusicBrainz::Server::Edit';

sub _alias_model { die 'Not implemented' }

use aliased 'MusicBrainz::Server::Entity::PartialDate';

has '+data' => (
    isa => Dict[
        name => Str,
        sort_name => Optional[Str],
        entity => Dict[
            id   => Int,
            name => Str
        ],
        locale => Nullable[Str],
        begin_date => Nullable[PartialDateHash],
        end_date   => Nullable[PartialDateHash],
        type_id => Nullable[Int],
        primary_for_locale => Nullable[Bool],
        ended      => Optional[Bool]
    ]
);

sub foreign_keys
{
    my $self = shift;
    return {};
}

sub build_display_data
{
    my $self = shift;

    return {
        alias => $self->data->{name},
        locale => $self->data->{locale},
        sort_name => $self->data->{sort_name},
        type => $self->_alias_model->parent->alias_type->get_by_id($self->data->{type_id}),
        begin_date => PartialDate->new($self->data->{begin_date}),
        end_date => PartialDate->new($self->data->{end_date}),
        primary_for_locale => $self->data->{primary_for_locale},
        ended      => $self->data->{ended} // 0
    };
}

has 'alias' => (
    is => 'rw'
);

has 'alias_id' => (
    isa => 'Int',
    is => 'rw',
);

sub insert
{
    my $self = shift;
    my %data = %{ $self->data };
    my $model = $self->_alias_model;

    $self->alias_id(
        $model->insert({
            # FIXME
            # We have to remap this, as alias wants to see 'artist_id'
            # for example, not 'entity_id'
            $model->type . '_id' => $data{entity}{id},
            name => $data{name},
            locale => $data{locale},
            sort_name => $data{sort_name},
            begin_date => $data{begin_date},
            end_date => $data{end_date},
            type_id => $data{type_id},
            primary_for_locale => $data{primary_for_locale}
        })->id
    );
}

sub reject
{
    my $self = shift;
    $self->_alias_model->delete($self->alias_id);
}

sub initialize
{
    my ($self, %opts) = @_;
    my $entity = delete $opts{entity} or die 'Missing entity object';
    $opts{entity} = {
        id => $entity->id,
        name => $entity->name
    };
    $self->data(\%opts);
}

# alias_id is handled separately, as it should not be copied if the edit is cloned
override 'to_hash' => sub
{
    my $self = shift;
    my $hash = super(@_);
    $hash->{alias_id} = $self->alias_id;
    return $hash;
};

before 'restore' => sub
{
    my ($self, $hash) = @_;
    my $alias_id = delete $hash->{alias_id} or return;
    $self->alias_id($alias_id);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

