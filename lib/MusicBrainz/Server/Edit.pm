package MusicBrainz::Server::Edit;
use Moose;

use DateTime;
use MooseX::AttributeHelpers;
use MusicBrainz::Server::Edit::Exceptions;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Types qw( $STATUS_OPEN );

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

has [qw( created_time expires_time close_time )] => (
    isa => 'DateTime',
    is => 'rw',
    coerce => 1
);

has 'status' => (
    isa => 'EditStatus',
    is => 'rw',
    default => $STATUS_OPEN,
);

has 'data' => (
    isa => 'HashRef',
    is => 'rw',
);

has 'auto_edit' => (
    isa => 'Bool',
    is => 'rw',
    default => sub { shift->edit_auto_edit }
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

sub is_open
{
    return shift->status == $STATUS_OPEN;
}

sub edit_type { die 'Not implemented' }
sub edit_name { '' }
sub edit_auto_edit { return }
sub edit_voting_period { DateTime::Duration->new(days => 7) }

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

our %_types;

sub register_type
{
    my $class = shift;
    my $type = $class->edit_type;
    warn "Type $type already registered" if exists $_types{$type};
    $_types{$type} = $class;
}

sub class_from_type
{
    my ($class, $type) = @_;
    return $_types{$type};
}

sub _mapping { }
sub _change_hash
{
    my ($self, $instance, @keys) = @_;
    my %mapping = $self->_mapping;
    my %old = map {
        my $mapped = exists $mapping{$_} ? $mapping{$_} : $_;
        $_ => ref $mapped eq 'CODE' ? $mapped->($instance) : $instance->$mapped;
    } @keys;
    return \%old;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
