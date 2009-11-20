package MusicBrainz::Server::Edit;
use Moose;

use Carp qw( croak );
use DateTime;
use MooseX::AttributeHelpers;
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Constants qw( :expire_action :quality );
use MusicBrainz::Server::Types qw( :edit_status :vote $AUTO_EDITOR_FLAG );

has 'c' => (
    isa => 'Object',
    is => 'rw'
);

has [qw( yes_votes no_votes )] => (
    isa => 'Int',
    is => 'rw',
);

has [qw( id editor_id language_id )] => (
    isa => 'Int',
    is => 'rw',
);

has 'editor' => (
    isa => 'Editor',
    is => 'rw'
);

has 'language' => (
    isa => 'Language',
    is => 'rw'
);

has 'quality' => (
    isa => 'Quality',
    is => 'rw'
);

has [qw( created_time expires_time close_time )] => (
    isa => 'DateTime',
    is => 'rw',
    coerce => 1
);

sub is_expired
{
    my ($self) = @_;

    my $now = DateTime->now( time_zone => $self->expires_time->time_zone );
    return $self->expires_time < $now;
}

has 'status' => (
    isa => 'EditStatus',
    is => 'rw',
    default => $STATUS_OPEN,
);

sub status_name
{
    my $self = shift;
    my %names = (
        $STATUS_OPEN => 'Open',
        $STATUS_APPLIED => 'Applied',
        $STATUS_FAILEDVOTE => 'Failed vote',
        $STATUS_FAILEDDEP => 'Failed dependency',
        $STATUS_ERROR => 'Error',
        $STATUS_FAILEDPREREQ => 'Failed prerequisite',
        $STATUS_NOVOTES => 'No votes',
        $STATUS_TOBEDELETED => 'Due to be deleted',
        $STATUS_DELETED => 'Deleted',
    );
    return $names{ $self->status };
}

has 'data' => (
    isa => 'HashRef',
    is => 'rw',
);

has 'auto_edit' => (
    isa => 'Bool',
    is => 'rw',
    default => 0,
);

has 'edit_notes' => (
    isa => 'ArrayRef',
    is => 'rw',
    default => sub { [] },
    metaclass => 'Collection::Array',
    provides => {
        push => 'add_edit_note',
    }
);

has 'votes' => (
    isa => 'ArrayRef',
    is => 'rw',
    default => sub { [] },
    metaclass => 'Collection::Array',
    provides => {
        push => 'add_vote',
    },
    curries => {
        grep => {
            votes_for_editor => sub {
                my ($self, $body, $editor_id) = @_;
                $body->($self, sub { $_->editor_id == $editor_id });
            },
        }
    }
);

sub latest_vote_for_editor
{
    my ($self, $editor_id) = @_;
    my @votes = $self->votes_for_editor($editor_id) or return;
    return $votes[-1];
}

sub is_open
{
    return shift->status == $STATUS_OPEN;
}

sub editor_may_vote
{
    my ($self, $editor) = @_;
    return defined $editor && $editor->id != $self->editor_id &&
                   $editor->email_confirmation_date &&
                   $editor->accepted_edits > 10;
}

sub edit_type { die 'Not implemented' }
sub edit_name { '' }

# Subclasses should reimplement this, if they want different edit conditions.
#
# Fields:
#  * duration - how many days before the edit expires
#  * votes - number of votes to consider the edit as unanimously accepted/rejected
#  * expire_action - what do do with expired edits without votes
#  * auto_edit - whether the edit can be automatically accepted for an autoeditor

sub edit_conditions
{
    return {
        $QUALITY_LOW => {
            duration      => 4,
            votes         => 1,
            expire_action => $EXPIRE_ACCEPT,
            auto_edit     => 1,
        },
        $QUALITY_NORMAL => {
            duration      => 14,
            votes         => 3,
            expire_action => $EXPIRE_ACCEPT,
            auto_edit     => 1,
        },
        $QUALITY_HIGH => {
            duration      => 14,
            votes         => 4,
            expire_action => $EXPIRE_REJECT,
            auto_edit     => 0,
        },
    };
}

sub determine_quality
{
    return $QUALITY_NORMAL;
}

sub can_approve
{
    my ($self, $privs) = @_;

    my $conditions = $self->edit_conditions->{$self->quality};
    return
         $self->is_open
      && $conditions->{auto_edit}
      && ($privs & $AUTO_EDITOR_FLAG);
}

=head2 related_entities

A list of all entities that this edit relates to. For each entity, a row in the edit_*
tables of the raw database will be created.

Returns a hash reference with the model name as the key, and an array ref of row ids as
the value

=cut

sub related_entities { return {} }

=head2 alter_edit_pending

A list of all entities which should have the 'editpending' column incremented/decremented
as the edit's status changes.

Returns a hash reference with the model name as the key, and an array ref of row ids as
the value.

=cut

sub alter_edit_pending { return {} }

sub adjust_edit_pending
{
    my ($self, $adjust) = @_;

    my $to_inc = $self->alter_edit_pending;
    while( my ($model_name, $ids) = each %$to_inc) {
        my $model = $self->c->model($model_name);
        $model->does('MusicBrainz::Server::Data::Editable')
            or croak "Model must do MusicBrainz::Server::Data::Editable";
        $model->adjust_edit_pending($adjust, @$ids);
    }
}

=head2 models

A list of all models that should attempt to load additional data for this edit.

Returns an array ref of model names

=cut

sub models { return [] }

sub accept { }
sub reject { }
sub insert { }

sub to_hash { shift->data }
sub restore { shift->data(shift) }
sub _xml_arguments { }

sub initialize
{
    my ($self, %opts) = @_;
    $self->data(\%opts);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
