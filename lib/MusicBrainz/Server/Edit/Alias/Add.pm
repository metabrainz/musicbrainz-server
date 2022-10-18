package MusicBrainz::Server::Edit::Alias::Add;
use MooseX::Role::Parameterized;
use namespace::autoclean;
use MooseX::Types::Moose qw( Bool Int Str );
use MooseX::Types::Structured qw( Dict Optional );
use MusicBrainz::Server::Data::Utils qw( model_to_type boolean_to_json );
use MusicBrainz::Server::Edit::Types qw( Nullable PartialDateHash );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use aliased 'MusicBrainz::Server::Entity::PartialDate';

parameter model => ( isa => 'Str', required => 1 );
parameter edit_type => ( isa => 'Int', required => 1 );
parameter edit_name => ( isa => 'Str', required => 1 );

role {
    my $params = shift;

    my $model = $params->model;
    my $entity_type = model_to_type($model);
    my $entity_id = "${entity_type}_id";

    with 'MusicBrainz::Server::Edit::Alias';
    with "MusicBrainz::Server::Edit::$model";
    with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';
    with 'MusicBrainz::Server::Edit::Role::DatePeriod';

    has data => (
        is => 'rw',
        clearer => 'clear_data',
        predicate => 'has_data',
        isa => Dict[
            name => Str,
            sort_name => Optional[Str],
            entity => Dict[
                id => Int,
                name => Str
            ],
            locale => Nullable[Str],
            begin_date => Nullable[PartialDateHash],
            end_date => Nullable[PartialDateHash],
            type_id => Nullable[Int],
            primary_for_locale => Nullable[Bool],
            ended => Optional[Bool]
        ]
    );

    has alias => (
        is => 'rw'
    );

    has alias_id => (
        isa => 'Int',
        is => 'rw',
    );

    method $entity_id => sub {
        return shift->data->{entity}{id};
    };

    method _alias_model => sub { shift->c->model($model)->alias };

    method edit_kind => sub { 'add' };
    method edit_name => sub { $params->edit_name };
    method edit_type => sub { $params->edit_type };

    method foreign_keys => sub {
        return { $model => { shift->$entity_id => [] } };
    };

    method insert => sub {
        my $self = shift;
        my %data = %{ $self->data };
        my $alias_model = $self->_alias_model;

        $self->alias_id(
            $alias_model->insert({
                # FIXME
                # We have to remap this, as alias wants to see 'artist_id'
                # for example, not 'entity_id'
                $alias_model->type . '_id' => $data{entity}{id},
                name => $data{name},
                locale => $data{locale},
                sort_name => $data{sort_name},
                begin_date => $data{begin_date},
                end_date => $data{end_date},
                type_id => $data{type_id},
                primary_for_locale => $data{primary_for_locale},
                ended => $data{ended}
            })->id
        );
    };

    method reject => sub {
        my $self = shift;
        $self->_alias_model->delete($self->alias_id);
    };

    method initialize => sub {
        my ($self, %opts) = @_;
        my $entity = delete $opts{entity} or die 'Missing entity object';
        $opts{entity} = {
            id => $entity->id,
            name => $entity->name
        };

        $self->enforce_dependencies(\%opts);

        $self->data(\%opts);
    };

    # alias_id is handled separately, as it should not be copied if the edit is cloned
    override to_hash => sub {
        my $self = shift;
        my $hash = super(@_);
        $hash->{alias_id} = $self->alias_id;
        return $hash;
    };

    before restore => sub {
        my ($self, $hash) = @_;
        my $alias_id = delete $hash->{alias_id} or return;
        $self->alias_id($alias_id);
    };

    method _build_related_entities => sub {
        return { $entity_type => [ shift->$entity_id ] };
    };

    method adjust_edit_pending => sub {
        my ($self, $adjust) = @_;

        $self->c->model($model)->adjust_edit_pending($adjust, $self->$entity_id);
        $self->c->model($model)->alias->adjust_edit_pending($adjust, $self->alias_id);
    };

    method build_display_data => sub {
        my ($self, $loaded) = @_;

        my $entity_id = $self->$entity_id;
        my $entity = to_json_object(
            $loaded->{$model}{$entity_id} //
            $self->c->model($model)->_entity_class->new(
                id => $entity_id,
                name => $self->data->{entity}{name},
            )
        );

        return {
            alias               => $self->data->{name},
            locale              => $self->data->{locale},
            sort_name           => $self->data->{sort_name},
            type                => to_json_object($self->_alias_model->parent->alias_type->get_by_id($self->data->{type_id})),
            begin_date          => to_json_object(PartialDate->new($self->data->{begin_date})),
            end_date            => to_json_object(PartialDate->new($self->data->{end_date})),
            primary_for_locale  => boolean_to_json($self->data->{primary_for_locale}),
            ended               => boolean_to_json($self->data->{ended}),
            entity_type         => $entity_type,
            $entity_type        => $entity,
        };
    };
};

sub edit_template { 'AddRemoveAlias' };

1;
