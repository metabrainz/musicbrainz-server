package MusicBrainz::Server::Edit::Generic::Edit;
use Moose;
use MooseX::ABC;

use Clone qw( clone );
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( model_to_type trim );
use MusicBrainz::Server::Validation qw( normalise_strings );
use Try::Tiny;

use aliased 'MusicBrainz::Server::Entity::PartialDate';

extends 'MusicBrainz::Server::Edit::WithDifferences';
requires 'change_fields', '_edit_model', '_conflicting_entity_path';

sub edit_kind { 'edit' }

sub entity_id { shift->data->{entity}{id} }

sub alter_edit_pending
{
    my $self = shift;
    my $model = $self->c->model( $self->_edit_model);
    if ($model->does('MusicBrainz::Server::Data::Role::Editable')) {
        return {
            $self->_edit_model => [ $self->entity_id ]
        }
    } else {
        return { }
    }
}

sub _build_related_entities
{
    my $self = shift;
    my $model = $self->c->model( $self->_edit_model);
    if ($model->does('MusicBrainz::Server::Data::Role::LinksToEdit')) {
        return {
            $model->edit_link_table => [ $self->entity_id ]
        }
    } else {
        return { }
    }
}

sub initialize {
    my ($self, %opts) = @_;

    my $entity = delete $opts{to_edit};
    die "You must specify the object to edit" unless defined $entity;

    my $entity_properties = $ENTITIES{model_to_type($self->_edit_model)};

    if ($entity_properties->{disambiguation} && exists $opts{comment}) {
        $opts{comment} = trim($opts{comment});
    }

    $self->data({
        entity => {
            id => $entity->id,
            ($entity->can('gid') ? (gid => $entity->gid) : ()),
            name => $entity->name
        },
        $self->_change_data($entity, %opts)
    });
};

override 'accept' => sub
{
    my $self = shift;

    if (!$self->c->model($self->_edit_model)->get_by_id($self->entity_id)) {
        MusicBrainz::Server::Edit::Exceptions::FailedDependency->throw(
            'This entity no longer exists'
        )
    }

    my $data = $self->_edit_hash(clone($self->data->{new}));
    try {
        $self->c->model( $self->_edit_model )->update($self->entity_id, $data);
    }
    catch {
        if (blessed($_) && $_->isa('MusicBrainz::Server::Exceptions::DuplicateViolation')) {
            my $conflict = $_->conflict;
            MusicBrainz::Server::Edit::Exceptions::GeneralError->throw(
                sprintf(
                    'The changes in this edit cause it to conflict with another entity. ' .
                    'You may need to merge this entity with "%s" ' .
                    '(//%s%s)',
                    $conflict->name,
                    DBDefs->WEB_SERVER,
                    $self->_conflicting_entity_path($conflict->gid)
                )
            );
        } else {
            die $_;
        }
    };
};

override allow_auto_edit => sub {
    my ($self) = @_;
    my $props = $ENTITIES{ model_to_type($self->_edit_model) };

    # Changing name, sortname or disambiguation is an auto-edit if the
    # change only affects small things like case etc.
    my @text_fields = ('name');
    push @text_fields, 'sort_name' if $props->{sort_name};
    push @text_fields, 'comment' if $props->{disambiguation};
    for my $field (@text_fields) {
        my ($old, $new) = normalise_strings(
            $self->data->{old}{$field}, $self->data->{new}{$field});
        return 0 if $old ne $new && $old ne '';
    }

    # Adding a date is automatic if there was no date yet.
    if ($props->{date_period}) {
        for my $field (qw( begin_date end_date )) {
            return 0 if exists $self->data->{old}{$field} &&
                !PartialDate->new_from_row($self->data->{old}{$field})->is_empty;
        }
        return 0 if exists $self->data->{old}{ended} &&
            $self->data->{old}{ended};
    }

    if ($props->{type}) {
        return 0 if exists $self->data->{old}{type_id} &&
            ($self->data->{old}{type_id} // 0) != 0;
    }

    if ($props->{artist_credits}) {
        return 0 if exists $self->data->{new}{artist_credit};
    }

    return 1;
};

sub _conflicting_entity_path { die 'Undefined' };

sub _edit_hash
{
    my ($self, $data) = @_;
    return $data;
}

sub _is_disambiguation_needed {
    my ($self, %opts) = @_;

    # If the artist name hasn't meaningfully changed, don't force requiring a comment.
    my $entity = $self->current_instance;
    return 0 if normalise_strings($entity->name) eq normalise_strings($opts{name});

    my $table = $self->c->model($self->_edit_model)->_table;
    return $self->c->sql->select_single_value(
        "SELECT 1 FROM $table
         WHERE id != ? AND lower(musicbrainz_unaccent(name)) = lower(musicbrainz_unaccent(?))
         LIMIT 1",
        $entity->id, $opts{name}
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
