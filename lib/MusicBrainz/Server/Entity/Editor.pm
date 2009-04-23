package MusicBrainz::Server::Entity::Editor;
use Moose;

use MusicBrainz::Server::Types;
use Readonly;

Readonly my $AUTO_EDITOR_FLAG         => 1;
Readonly my $BOT_FLAG                 => 2;
Readonly my $UNTRUSTED_FLAG           => 4;
Readonly my $RELATIONSHIP_EDITOR_FLAG => 8;
Readonly my $DONT_NAG_FLAG            => 16;
Readonly my $WIKI_TRANSCLUSION_FLAG   => 32;
Readonly my $MBID_SUBMITTER_FLAG      => 64;
Readonly my $ACCOUNT_ADMIN_FLAG       => 128;

extends 'MusicBrainz::Server::Entity::Entity';

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
    return (shift->privileges & $AUTO_EDITOR_FLAG) > 0;
}

sub is_bot
{
    return (shift->privileges & $BOT_FLAG) > 0;
}

sub is_untrusted
{
    return (shift->privileges & $UNTRUSTED_FLAG) > 0;
}

sub is_nag_free
{
    return (shift->privileges & $DONT_NAG_FLAG) > 0;
}

sub is_relationship_editor
{
    return (shift->privileges & $RELATIONSHIP_EDITOR_FLAG) > 0;
}

sub is_wiki_transcluder
{
    return (shift->privileges & $WIKI_TRANSCLUSION_FLAG) > 0;
}

sub is_mbid_submitter
{
    return (shift->privileges & $MBID_SUBMITTER_FLAG) > 0;
}

sub is_account_admin
{
    return (shift->privileges & $ACCOUNT_ADMIN_FLAG) > 0;
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

has [qw( accepted_edits rejected_edits failed_edits auto_edits )] => (
    is  => 'rw',
    isa => 'Int',
);

has [qw( registration_date last_login_date email_confirmation_date )] => (
    isa => 'DateTime',
    is  => 'rw',
);

sub is_newbie
{
    my $self = shift;
    my $date = (DateTime->now - DateTime::Duration->new(weeks => 2));
    return $self->registration_date > $date;
}

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

