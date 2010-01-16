package MusicBrainz::Server::Data::Editor;
use Moose;

use MusicBrainz::Server::Entity::Preferences;
use MusicBrainz::Server::Entity::Editor;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    query_to_list_limited
);
use MusicBrainz::Server::Types qw( $STATUS_FAILEDVOTE $STATUS_APPLIED );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_editor',
    column => 'subscribededitor'
};

sub _table
{
    return 'editor';
}

sub _columns
{
    return 'editor.id, name, password, privs, email, website, bio,
            membersince, emailconfirmdate, lastlogindate, editsaccepted,
            editsrejected, autoeditsaccepted, editsfailed';
}

sub _column_mapping
{
    return {
        id                      => 'id',
        name                    => 'name',
        email                   => 'email',
        password                => 'password',
        privileges              => 'privs',
        website                 => 'website',
        biography               => 'bio',
        accepted_edits          => 'editsaccepted',
        rejected_edits          => 'editsrejected',
        failed_edits            => 'editsfailed',
        accepted_auto_edits     => 'autoeditsaccepted',
        email_confirmation_date => 'emailconfirmdate',
        registration_date       => 'membersince',
        last_login_date         => 'lastlogindate',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Editor';
}

sub get_by_name
{
    my ($self, $name) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE lower(name) = ? LIMIT 1';
    my $row = $sql->select_single_row_hash($query, lc $name);
    return $self->_new_from_row($row);
}

sub find_by_email
{
    my ($self, $email) = @_;
    return values %{$self->_get_by_keys('email', $email)};
}

sub find_by_subscribed_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_editor s ON editor.id = s.subscribededitor
                 WHERE s.editor = ?
                 ORDER BY editor.name, editor.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $editor_id, $offset || 0);
}

sub insert
{
    my ($self, $data) = @_;

    my $sql = Sql->new($self->c->dbh);
    return Sql::run_in_transaction(sub {
        return $self->_entity_class->new(
            id => $sql->insert_row('editor', $data, 'id'),
            name => $data->{name},
            password => $data->{password},
            accepted_edits => 0,
            rejected_edits => 0,
            failed_edits => 0,
            accepted_auto_edits => 0,
        );
    }, $sql);
}

sub update_email
{
    my ($self, $editor, $email) = @_;

    my $sql = Sql->new($self->c->dbh);
    Sql::run_in_transaction(sub {
        if ($email) {
            my $email_confirmation_date = $sql->select_single_value(
                'UPDATE editor SET email=?, emailconfirmdate=NOW()
                WHERE id=? RETURNING emailconfirmdate', $email, $editor->id);
            $editor->email($email);
            $editor->email_confirmation_date($email_confirmation_date);
        }
        else {
            $sql->do('UPDATE editor SET email=NULL, emailconfirmdate=NULL
                      WHERE id=?', $editor->id);
            delete $editor->{email};
            delete $editor->{email_confirmation_date};
        }
    }, $sql);
}

sub update_password
{
    my ($self, $editor, $password) = @_;

    my $sql = Sql->new($self->c->dbh);
    Sql::run_in_transaction(sub {
        $sql->do('UPDATE editor SET password=? WHERE id=?',
                 $password, $editor->id);
    }, $sql);
}

sub update_profile
{
    my ($self, $editor, $website, $bio) = @_;

    my $sql = Sql->new($self->c->dbh);
    Sql::run_in_transaction(sub {
        $sql->do('UPDATE editor SET website=?, bio=? WHERE id=?',
                 $website || undef, $bio || undef, $editor->id);
    }, $sql);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'editor', @objs);
}

sub load_preferences
{
    my ($self, $editor) = @_;
    my $query = "SELECT name, value FROM editor_preference WHERE editor = ?";
    my $sql = Sql->new($self->c->dbh);
    my $prefs = $sql->select_list_of_hashes($query, $editor->id);
    $editor->preferences(MusicBrainz::Server::Entity::Preferences->new());
    for my $pref (@$prefs) {
        my ($key, $value) = ($pref->{name}, $pref->{value});
        next unless $editor->preferences->can($key);
        $editor->preferences->$key($value);
    }
}

sub save_preferences
{
    my ($self, $editor, $values) = @_;

    my $sql = Sql->new($self->c->dbh);
    Sql::run_in_transaction(sub {

        $sql->do('DELETE FROM editor_preference WHERE editor = ?', $editor->id);
        my $preferences_meta = $editor->preferences->meta;
        foreach my $name (keys %$values) {
            my $default = $preferences_meta->get_attribute($name)->default;
            unless ($default eq $values->{$name}) {
                $sql->insert_row('editor_preference', {
                    editor => $editor->id,
                    name   => $name,
                    value  => $values->{$name},
                });
            }
        }
        $editor->preferences(MusicBrainz::Server::Entity::Preferences->new(%$values));

    }, $sql);
}

sub credit
{
    my ($self, $editor_id, $status, $as_autoedit) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $column;
    $column = "editsrejected" if $status == $STATUS_FAILEDVOTE;
    $column = "editsaccepted" if $status == $STATUS_APPLIED && !$as_autoedit;
    $column = "autoeditsaccepted" if $status == $STATUS_APPLIED && $as_autoedit;
    $column ||= "editsfailed";
    my $query = "UPDATE editor SET $column = $column + 1 WHERE id = ?";
    $sql->do($query, $editor_id);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

MusicBrainz::Server::Data::Editor - database level loading support for
Editors

=head1 DESCRIPTION

Provides support for fetching editors from the database

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

