package MusicBrainz::Server::Entity::Editor;
use Moose;
use namespace::autoclean;

use Authen::Passphrase;
use DateTime;
use Encode;
use MusicBrainz::Server::Constants qw( $PASSPHRASE_BCRYPT_COST );
use MusicBrainz::Server::Data::Utils qw(
    boolean_to_json
    datetime_to_iso8601
    non_empty
);
use MusicBrainz::Server::Entity::Preferences;
use MusicBrainz::Server::Entity::Types qw( Area ); ## no critic 'ProhibitUnusedImport'
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
use MusicBrainz::Server::Constants qw( :privileges $EDITOR_MODBOT);
use MusicBrainz::Server::Filters qw( format_wikitext );
use MusicBrainz::Server::Types DateTime => { -as => 'DateTimeType' };

my $LATEST_SECURITY_VULNERABILITY = DateTime->new( year => 2013, month => 3, day => 28 );

extends 'MusicBrainz::Server::Entity';

sub entity_type { 'editor' }

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

sub is_location_editor
{
    my $mask = $LOCATION_EDITOR_FLAG;
    return (shift->privileges & $mask) > 0;
}

sub is_banner_editor
{
    my $mask = $BANNER_EDITOR_FLAG;
    return (shift->privileges & $mask) > 0;
}

sub is_editing_disabled {
    (shift->privileges & $EDITING_DISABLED_FLAG) > 0;
}

sub is_editing_enabled {
    (shift->privileges & $EDITING_DISABLED_FLAG) == 0;
}

sub may_vote {
    my $self = shift;

    return $self->has_confirmed_email_address &&
           !$self->is_limited &&
           !$self->is_bot &&
           $self->is_editing_enabled;
}

sub is_adding_notes_disabled {
    (shift->privileges & $ADDING_NOTES_DISABLED_FLAG) > 0;
}

sub is_spammer {
    (shift->privileges & $SPAMMER_FLAG) > 0;
}

sub public_privileges {
    shift->privileges & $PUBLIC_PRIVILEGE_FLAGS;
}

has 'email' => (
    is        => 'rw',
    isa       => 'Str',
);

sub has_email_address
{
    my $self = shift;
    return non_empty($self->email);
}

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

has 'has_ten_accepted_edits' => (
    is  => 'rw',
    isa => 'Bool',
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

has 'preferences' => (
    is => 'rw',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::Preferences->new }
);

sub is_limited
{
    # Please keep the logic in sync with Report::LimitedEditors and EditSearch::Predicate::Role::User
    my $self = shift;
    return
        !($self->id == $EDITOR_MODBOT) &&
        !$self->deleted &&
        ( !$self->email_confirmation_date ||
          $self->is_newbie ||
          !$self->has_ten_accepted_edits
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

has area_id => (
    is => 'rw',
    isa => 'Int',
);

has area => (
    is => 'rw',
    isa => 'Area'
);

sub age {
    my $self = shift;
    return unless $self->birth_date;
    return (DateTime->now - $self->birth_date)->in_units('years');
}

sub can_nominate {
    my ($self, $candidate) = @_;
    return unless $candidate;
    return $self->is_auto_editor && !$candidate->is_auto_editor && !$candidate->deleted;
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

sub requires_password_reset {
    my $self = shift;
    return $self->last_login_date < $LATEST_SECURITY_VULNERABILITY
};

has ha1 => (
    isa => 'Str',
    is => 'rw',
);

sub requires_password_rehash {
    my $self = shift;
    my $hash = Authen::Passphrase->from_rfc2307($self->password);
    return blessed($hash)
        && $hash->isa('Authen::Passphrase::BlowfishCrypt')
        && $hash->cost < $PASSPHRASE_BCRYPT_COST;
}

sub match_password {
    my ($self, $password) = @_;
    Authen::Passphrase->from_rfc2307($self->password)->match(
        encode('utf-8', $password));
}

has deleted => (
    isa => 'Bool',
    is => 'rw',
);

sub identity_string {
    my ($self) = @_;
    return join(', ', $self->name, $self->id);
}

sub new_privileged {
    shift->new(
        id => 0,
        privileges => $AUTO_EDITOR_FLAG | $LOCATION_EDITOR_FLAG,
    );
}

# TODO: Add support for returning avatars from Discourse.
# (This should perhaps become an attribute instead of a method,
# and be loaded from somewhere.)
sub avatar {
    my $self = shift;

    return '';
}

sub _unsanitized_json {
    my ($self) = @_;

    my $age = $self->age;
    my $json = {
        %{$self->TO_JSON},
        age                         => $age ? ($age + 0) : undef,
        area                        => to_json_object($self->area),
        biography                   => format_wikitext($self->biography),
        birth_date                  => undef,
        email                       => undef,
        email_confirmation_date     => datetime_to_iso8601($self->email_confirmation_date),
        gender                      => to_json_object($self->gender),
        has_confirmed_email_address => boolean_to_json($self->has_confirmed_email_address),
        has_email_address           => boolean_to_json($self->has_email_address),
        is_charter                  => boolean_to_json($self->is_charter),
        is_limited                  => boolean_to_json($self->is_limited),
        languages                   => to_json_array($self->languages),
        last_login_date             => datetime_to_iso8601($self->last_login_date),
        preferences                 => $self->preferences->TO_JSON,
        privileges                  => 0 + $self->privileges,
        registration_date           => datetime_to_iso8601($self->registration_date),
        website                     => $self->website,
    };

    for my $restricted_key (qw( birth_date email )) {
        die "Use \$c->unsanitized_editor_json to access $restricted_key"
            if defined $json->{$restricted_key};
    }

    return $json;
}

sub TO_JSON {
    my ($self) = @_;

    return {
        avatar => $self->avatar,
        deleted => boolean_to_json($self->deleted),
        entityType => 'editor',
        id => $self->id,
        is_limited => boolean_to_json($self->is_limited),
        name => $self->name,
        privileges => 0 + $self->public_privileges,
    };
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

=head2 has_ten_accepted_edits

A flag showing if this user has at least ten accepted non-auto-edits.

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

=head2 is_banner_editor

The editor is able to change the banner message

=head2 new_privileged

Returns a dummy instance with high editing privileges.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

