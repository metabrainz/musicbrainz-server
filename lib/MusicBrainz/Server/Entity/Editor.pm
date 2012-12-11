package MusicBrainz::Server::Entity::Editor;
use Moose;
use namespace::autoclean;

use DateTime;
use MusicBrainz::Server::Entity::Preferences;
use MusicBrainz::Server::Constants qw( :privileges $EDITOR_MODBOT);
use MusicBrainz::Server::Types DateTime => { -as => 'DateTimeType' };

extends 'MusicBrainz::Server::Entity';

has 'name' => (
    is  => 'rw',
    isa => 'Str',
);

has 'password' => (
    is  => 'rw',
    isa => 'Str',
);

has 'privileges' => (
    isa => 'Int',
    is  => 'rw',
    default => 0,
);

sub is_auto_editor
{
    my $mask = $AUTO_EDITOR_FLAG;
    return (shift->privileges & $mask) > 0;
}

sub is_bot
{
    my $mask = $BOT_FLAG;
    return (shift->privileges & $mask) > 0;
}

sub is_untrusted
{
    my $mask = $UNTRUSTED_FLAG;
    return (shift->privileges & $mask) > 0;
}

sub is_nag_free
{
    my $mask = $DONT_NAG_FLAG;
    return (shift->privileges & $mask) > 0;
}

sub is_relationship_editor
{
    my $mask = $RELATIONSHIP_EDITOR_FLAG;
    return (shift->privileges & $mask) > 0;
}

sub is_wiki_transcluder
{
    my $mask = $WIKI_TRANSCLUSION_FLAG;
    return (shift->privileges & $mask) > 0;
}

sub is_mbid_submitter
{
    my $mask = $MBID_SUBMITTER_FLAG;
    return (shift->privileges & $mask) > 0;
}

sub is_account_admin
{
    my $mask = $ACCOUNT_ADMIN_FLAG;
    return (shift->privileges & $mask) > 0;
}

has 'email' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_email_address',
);

sub has_confirmed_email_address
{
    my $self = shift;
    return $self->has_email_address
        && defined $self->email_confirmation_date;
}

has [qw( biography website )] => (
    is  => 'rw',
    isa => 'Str',
);

has [qw( accepted_edits rejected_edits failed_edits accepted_auto_edits )] => (
    is  => 'rw',
    isa => 'Int',
);

use DateTime;
has [qw( registration_date )] => (
    isa    => DateTimeType,
    is     => 'rw',
    coerce => 1,
    lazy   => 1,
    # This is the date of the first commit, and will be moved to the database
    # in the next schema change
    default => sub { DateTime->new( year => 2000, month => 9, day => 7 ) }
);

has [qw( last_login_date email_confirmation_date )] => (
    isa    => DateTimeType,
    is     => 'rw',
    coerce => 1,
);

sub is_charter
{
    my $self = shift;
    return ($self->registration_date == DateTime->new(year => 2000, month => 9, day => 7));
}

sub is_newbie
{
    my $self = shift;
    return DateTime::Duration->compare(
        DateTime->now - $self->registration_date,
        DateTime::Duration->new( weeks => 2 )
      ) == -1;
}

sub is_admin
{
    my $self = shift;
    return $self->is_relationship_editor || $self->is_wiki_transcluder;
}

has 'preferences' => (
    is => 'rw',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::Preferences->new }
);

sub is_limited
{
    my $self = shift;
    return
        !($self->id == $EDITOR_MODBOT) &&
        ( !$self->email_confirmation_date ||
          $self->is_newbie ||
          $self->accepted_edits < 10
        );
}

has birth_date => (
   is => 'rw',
   isa => DateTimeType,
   coerce => 1
);

has gender_id => (
    is => 'rw',
    isa => 'Int',
);

has gender => (
    is => 'rw',
);

has country_id => (
    is => 'rw',
    isa => 'Int',
);

has country => (
    is => 'rw',
);

sub age {
    my $self = shift;
    return unless $self->birth_date;
    return (DateTime->now - $self->birth_date)->in_units('years');
}

has languages => (
    isa => 'ArrayRef',
    is => 'rw',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        add_language => 'push',
    }
);

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

MusicBrainz::Server::Entity::Editor - represents editors in MusicBrainz

=head1 DESCRIPTION

Editors are the users of MusicBrainz, and as such this entity is mostly
a user profile object - providing access to per-editor information such as
name, etc.

=head1 ATTRIBUTES

=head2 name

User's login name

=head2 password

User's password

=head2 privileges

A bitmask of privileges for this editor. These flags can be checked with
helper methods (see L<METHODS>).

=head2 email

The editor's email address

There are 2 routines to provide some extra information about this data:

=over 4

=item has_confirmed_email_address

Check if the editor has an email address, and that they have confirmed it.

=item has_email_address

Confirm the editor has specified an email address.

=back

=head2 biography

A short custom block of text an editor can use to describe themselves

=head2 website

A custom URL editors can use to link to their homepage

=head2 accepted_edits, rejected_edits, failed_edits, auto_edits

These all provide a count of the number of respective edits.

=head2 registration_date, last_login_date, email_confirmation_date

The date the user registered, last logged in and last confirmed their
email address, respectively.

=head1 METHODS

=head2 is_newbie

Determine if this "editor" is a newbie - someone who is new to MusicBrainz.

=head2 is_auto_editor

The editor is an auto-editor

=head2 is_bot

The editor is a bot, not a human being

=head2 is_untrusted

The editor is flagged untrusted

=head2 is_nag_free

The editor should not be nagged to donate

=head2 is_mbid_submitter

The editor may specify custom MBIDs for core entities

=head2 is_relationship_editor

The editor is able to edit relationship types

=head2 is_wiki_transcluder

The editor is able to select wiki pages for transclusion

=head2 is_account_admin

The editor is able to administer the accounts of other editors

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

