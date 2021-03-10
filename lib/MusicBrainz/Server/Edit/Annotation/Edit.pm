package MusicBrainz::Server::Edit::Annotation::Edit;
use strict;
use Carp;
use MooseX::Role::Parameterized;
use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( model_to_type );
use MusicBrainz::Server::Edit::Types qw( Nullable NullableOnPreview );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_object );
use MusicBrainz::Server::Filters qw( format_wikitext );
use JSON::XS;

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
    with 'MusicBrainz::Server::Edit::Role::AlwaysAutoEdit';

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
        isa => 'Maybe[Int]',
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
            text          => $self->data->{text},
            html          => format_wikitext($self->data->{text}),
            entity_type   => $entity_type,
        };

        unless ($self->preview) {
            my $entity_properties = $ENTITIES{$entity_type};
            my $entity = $loaded->{$model}{ $self->$entity_id };
            $self->c->model('ArtistCredit')->load($entity) if $entity_properties->{artist_credits};
            $data->{$entity_type} = to_json_object(
                $entity //
                $self->c->model($model)->_entity_class->new(name => $self->data->{entity}{name})
            );
        }

        return $data;
    };

    method accept => sub {
        my $self = shift;
        my $annotation_model = $self->_annotation_model;
        my $latest_annotation = $annotation_model->get_latest($self->data->{entity}{id});

        if ($latest_annotation && $latest_annotation->creation_date > $self->created_time) {
            MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
                'The annotation has changed since this edit was entered.'
            );
        }

        if (!$self->c->model($model)->get_by_id($self->data->{entity}{id})) {
            MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
                'The relevant entity has been removed since this edit was created.'
            );
        }

        my $id = $annotation_model->edit({
            entity_id => $self->data->{entity}{id},
            text      => $self->data->{text},
            changelog => $self->data->{changelog},
            editor_id => $self->data->{editor_id}
        });

        # We add the annotation id to the raw edit data for reference
        $self->annotation_id($id);
        my $json = JSON::XS->new;
        $self->c->sql->update_row('edit_data', { data => $json->encode($self->to_hash) }, { edit => $self->id });
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

sub edit_template_react { 'AddAnnotation' };

1;
