package MusicBrainz::Server::Edit::Alias::Add;
use Moose;
use MooseX::ABC;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );

extends 'MusicBrainz::Server::Edit';

sub _alias_model { die 'Not implemented' }

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
        type_id => Nullable[Int]
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
        sort_name => $self->data->{sort_name}
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

