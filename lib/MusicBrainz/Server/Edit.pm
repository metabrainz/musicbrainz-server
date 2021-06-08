package MusicBrainz::Server::Edit;
use Moose;

use Carp qw( croak );
use DateTime;
use MusicBrainz::Server::Data::Utils qw( boolean_to_json datetime_to_iso8601 );
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Edit::Utils qw( edit_status_name );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Constants qw(
    :edit_status
    :expire_action
    :vote
    $AUTO_EDITOR_FLAG
    $EDITING_DISABLED_FLAG
    $OPEN_EDIT_DURATION
    $REQUIRED_VOTES
);
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Types
    DateTime => { -as => 'DateTimeType' }, 'EditStatus', 'Quality';

sub edit_type { die 'Unimplemented' }
sub edit_name { die 'Unimplemented' }
sub edit_kind { die 'Unimplemented' }
sub l_edit_name { l(shift->edit_name) }

sub edit_template {
    lc(shift->edit_name) =~ s/\s+/_/gr
}

sub edit_template_react { '' }

has 'c' => (
    isa => 'Object',
    is => 'rw'
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

has [qw( created_time expires_time close_time )] => (
    isa => DateTimeType,
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
    isa => EditStatus,
    is => 'rw',
    default => $STATUS_OPEN,
);

sub status_name
{
    my $self = shift;
    return edit_status_name($self->status);
}

sub l_status_name
{
    my $self = shift;
    return l(edit_status_name($self->status));
}

has 'data' => (
    isa       => 'HashRef',
    is        => 'rw',
    clearer   => 'clear_data',
    predicate => 'has_data',
);

has 'display_data' => (
    isa => 'HashRef',
    is => 'rw',
    predicate => 'is_loaded'
);

has 'raw_data' => (
    isa => 'Str',
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
    traits => [ 'Array' ],
    handles => {
        add_edit_note => 'push',
        all_edit_notes => 'elements'
    }
);

has 'votes' => (
    isa => 'ArrayRef',
    is => 'rw',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        add_vote => 'push',
        all_votes => 'elements',
        _grep_votes => 'grep'
    }
);

sub yes_votes {
    scalar shift->_grep_votes(sub { $_->vote == $VOTE_YES && !$_->superseded });
}

sub no_votes {
    scalar shift->_grep_votes(sub { $_->vote == $VOTE_NO && !$_->superseded });
}

sub votes_for_editor
{
    my ($self, $editor_id) = @_;
    $self->_grep_votes(sub { $_->editor_id == $editor_id });
}

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

sub editor_may_vote {
    my ($self, $editor) = @_;

    return (
        $self->is_open &&
        defined $editor &&
        $editor->id != $self->editor_id &&
        !$editor->is_limited &&
        !$editor->is_bot &&
        !$editor->is_editing_disabled
    );
}

sub editor_may_add_note
{
    my ($self, $editor) = @_;

    return defined $editor && $editor->email_confirmation_date &&
        ($editor->id == $self->editor_id || !$editor->is_limited) &&
        !$editor->is_adding_notes_disabled;
}

sub editor_may_edit {
    shift->editor->is_editing_enabled;
}

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
        duration      => $OPEN_EDIT_DURATION->in_units('days'),
        votes         => $REQUIRED_VOTES,
        expire_action => $EXPIRE_ACCEPT,
        auto_edit     => 1
    };
}

sub allow_auto_edit
{
    return 0;
}

sub modbot_auto_edit { 0 }

sub conditions
{
    my $self = shift;
    return $self->edit_conditions;
}

sub editor_may_approve {
    my ($self, $editor) = @_;

    my $conditions = $self->edit_conditions;
    return
         $self->is_open
      && $conditions->{auto_edit}
      && ($editor->privileges & $AUTO_EDITOR_FLAG)
      && !($editor->privileges & $EDITING_DISABLED_FLAG);
}

sub editor_may_cancel {
    my ($self, $editor) = @_;

    return
         $self->is_open
      && $self->editor_id == $editor->id;
}

sub was_approved
{
    my $self = shift;

    return 0 if $self->is_open;

    return scalar $self->_grep_votes(sub { $_->vote == $VOTE_APPROVE })
}

sub approval_requires_comment {
    my ($self, $editor) = @_;

    return $self->_grep_votes(sub {
        $_->vote == $VOTE_NO &&
            !$_->superseded &&
                $_->editor_id != $editor->id
    }) > 0;
}

=head2 related_entities

A list of all entities that this edit relates to. For each entity, a row in the edit_*
tables of the raw database will be created.

Returns a hash reference with the model name as the key, and an array ref of row ids as
the value

=cut

has related_entities => (
    is => 'rw',
    builder => '_build_related_entities',
    lazy => 1
);
sub _build_related_entities { return {} }

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
    while ( my ($model_name, $ids) = each %$to_inc) {
        my $model = $self->c->model($model_name);
        $model->does('MusicBrainz::Server::Data::Role::Editable')
            or croak "Model must do MusicBrainz::Server::Data::Role::Editable";
        $model->adjust_edit_pending($adjust, @$ids);
    }
}

sub foreign_keys { { } }
sub build_display_data
{
    my ($self, $loaded) = @_;
    return { };
}

sub accept { }
sub reject { }
sub insert { }
sub post_insert { }

sub to_hash { shift->data }
sub restore { shift->data(shift) }
sub _xml_arguments { }

sub initialize
{
    my ($self, %opts) = @_;
    $self->data(\%opts);
}

sub TO_JSON {
    my ($self) = @_;

    my $can_preview = $self->does('MusicBrainz::Server::Edit::Role::Preview');
    my $conditions = $self->edit_conditions;
    return {
        close_time => datetime_to_iso8601($self->close_time),
        conditions => {
            duration => $conditions->{duration} + 0,
            votes => $conditions->{votes} + 0,
            expire_action => $conditions->{expire_action} + 0,
            auto_edit => boolean_to_json($conditions->{auto_edit}),
        },
        created_time => datetime_to_iso8601($self->created_time),
        display_data => $self->display_data,
        data => $self->data,
        edit_kind => $self->edit_kind,
        edit_notes => to_json_array($self->edit_notes),
        edit_type => $self->edit_type + 0,
        editor_id => $self->editor_id + 0,
        expires_time => datetime_to_iso8601($self->expires_time),
        historic_type => $self->can('historic_type') ? $self->historic_type + 0 : undef,
        id => $self->id ? $self->id + 0 : undef,
        is_loaded => boolean_to_json($self->is_loaded),
        is_open => boolean_to_json($self->is_open),
        $can_preview ? (preview => boolean_to_json($self->preview)) : (),
        status => $self->status + 0,
        votes => to_json_array($self->votes),
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
