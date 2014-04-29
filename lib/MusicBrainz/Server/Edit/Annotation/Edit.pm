package MusicBrainz::Server::Edit::Annotation::Edit;
use Carp;
use MooseX::Role::Parameterized;
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Data::Utils qw( model_to_type );
use MusicBrainz::Server::Edit::Types qw( Nullable NullableOnPreview );

parameter model => ( isa => 'Str', required => 1 );
parameter edit_type => ( isa => 'Int', required => 1 );
parameter edit_name => ( isa => 'Str', required => 1 );

role {
    my $params = shift;

    my $model = $params->model;
    my $entity_type = model_to_type($model);
    my $entity_id = "${entity_type}_id";

    with "MusicBrainz::Server::Edit::$model";
    with 'MusicBrainz::Server::Edit::Role::Preview';

    has data => (
        is => 'rw',
        clearer => 'clear_data',
        predicate => 'has_data',
        isa => Dict[
            editor_id => Int,
            text      => Nullable[Str],
            changelog => Nullable[Str],
            entity    => NullableOnPreview[Dict[
                id   => Int,
                name => Str
            ]],
        ],
    );

    has annotation_id => (
        isa => 'Int',
        is => 'rw',
    );

    has $entity_type => (
        isa => $model,
        is => 'rw',
    );

    method $entity_id => sub { shift->data->{entity}{id} };

    method edit_kind => sub { 'add' };
    method edit_name => sub { $params->edit_name };
    method edit_type => sub { $params->edit_type };

    method _build_related_entities => sub { return { $entity_type => [ shift->$entity_id ] } };
    method models => sub { [ $model ] };

    method _annotation_model => sub { shift->c->model($model)->annotation };

    method build_display_data => sub {
        my ($self, $loaded) = @_;

        my $data = {
            changelog     => $self->data->{changelog},
            annotation_id => $self->annotation_id,
            text          => $self->data->{text},
        };

        unless ($self->preview) {
            $data->{$entity_type} = $loaded->{$model}->{$self->$entity_id} //
                $self->c->model($model)->_entity_class->new(name => $self->data->{entity}{name}),
        }

        return $data;
    };

    method edit_conditions => sub {
        my $conditions = {
            duration      => 0,
            votes         => 0,
            expire_action => $EXPIRE_ACCEPT,
            auto_edit     => 1,
        };
        return {
            $QUALITY_LOW    => $conditions,
            $QUALITY_NORMAL => $conditions,
            $QUALITY_HIGH   => $conditions,
        };
    };

    method insert => sub {
        my $self = shift;
        my $model = $self->_annotation_model;
        my $id = $model->edit({
            entity_id => $self->data->{entity}{id},
            text      => $self->data->{text},
            changelog => $self->data->{changelog},
            editor_id => $self->data->{editor_id}
        });
        $self->annotation_id($id);
    };

    method initialize => sub {
        my ($self, %opts) = @_;

        my $entity = delete $opts{entity};

        if ($entity) {
            $opts{entity} = {
                id => $entity->id,
                name => $entity->name
            };
        }
        else
        {
            die 'Missing entity argument' unless $self->preview;
        }

        $self->data({
            %opts,
            editor_id => $self->editor_id,
        });
    };

    override to_hash => sub
    {
        my $self = shift;
        my $hash = super(@_);
        $hash->{annotation_id} = $self->annotation_id;
        return $hash;
    };

    before restore => sub {
        my ($self, $hash) = @_;
        $self->annotation_id(delete $hash->{annotation_id});
    };

    method foreign_keys => sub {
        my $self = shift;

        return {} if $self->preview;

        return {
            $model => [ $self->$entity_id ],
        };
    };
};

1;
