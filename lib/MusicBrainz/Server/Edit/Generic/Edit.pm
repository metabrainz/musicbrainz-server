package MusicBrainz::Server::Edit::Generic::Edit;
use Moose;
use MooseX::ABC;

use Clone qw( clone );
use MooseX::Types::Moose qw( Int );
use MooseX::Types::Structured qw( Dict );

use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Constants qw( %ENTITIES );
use MusicBrainz::Server::Data::Utils qw( model_to_type );
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

sub initialize
{
    my ($self, %opts) = @_;
    my $entity = delete $opts{to_edit};
    die "You must specify the object to edit" unless defined $entity;

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
    my ($old_name, $new_name) = normalise_strings(
        $self->data->{old}{name}, $self->data->{new}{name});
    return 0 if $old_name ne $new_name;

    if ($props->{sort_name}) {
        my ($old_sort_name, $new_sort_name) = normalise_strings(
            $self->data->{old}{sort_name}, $self->data->{new}{sort_name});
        return 0 if $old_sort_name ne $new_sort_name;
    }

    if ($props->{disambiguation}) {
        my ($old_comment, $new_comment) = normalise_strings(
            $self->data->{old}{comment}, $self->data->{new}{comment});
        return 0 if $old_comment ne $new_comment;
    }

    # Adding a date is automatic if there was no date yet.
    if ($props->{date_period}) {
        return 0 if exists $self->data->{old}{begin_date}
            and !PartialDate->new_from_row($self->data->{old}{begin_date})->is_empty;
        return 0 if exists $self->data->{old}{end_date}
            and !PartialDate->new_from_row($self->data->{old}{end_date})->is_empty;
        return 0 if exists $self->data->{old}{ended}
            and $self->data->{old}{ended} != $self->data->{new}{ended};
    }

    if ($props->{type}) {
        return 0 if exists $self->data->{old}{type_id}
            and ($self->data->{old}{type_id} // 0) != 0;
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

__PACKAGE__->meta->make_immutable;
no Moose;

1;
