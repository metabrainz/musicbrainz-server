package MusicBrainz::Server::Data::Editor;
use Moose;

use MusicBrainz::Server::Entity::Editor;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
);

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'editor';
}

sub _columns
{
    return 'id, name, password, privs, email, website, bio,
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
    my @result = values %{$self->_get_by_keys('name', $name)};
    return $result[0];
}

sub find_by_email
{
    my ($self, $email) = @_;
    return values %{$self->_get_by_keys('email', $email)};
}

sub insert
{
    my ($self, $data) = @_;

    my $sql = Sql->new($self->c->dbh);
    return Sql::RunInTransaction(sub {
        return $self->_entity_class->new(
            id => $sql->InsertRow('editor', $data, 'id'),
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
    Sql::RunInTransaction(sub {
        $sql->Do('UPDATE editor SET email=?, emailconfirmdate=NOW()
                  WHERE id=?', $email, $editor->id);
    }, $sql);
}

sub update_password
{
    my ($self, $editor, $password) = @_;

    my $sql = Sql->new($self->c->dbh);
    Sql::RunInTransaction(sub {
        $sql->Do('UPDATE editor SET password=? WHERE id=?',
                 $password, $editor->id);
    }, $sql);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'editor', @objs);
}

sub _preference_name_mapping
{
    return {
        datetimeformat => 'datetime_format',
    };
}

sub load_preferences
{
    my ($self, $editor) = @_;
    my $query = "SELECT name, value FROM editor_preference WHERE editor = ?";
    my $sql = Sql->new($self->c->dbh);
    my $prefs = $sql->SelectListOfHashes($query, $editor->id);
    my %mapping = %{ $self->_preference_name_mapping };
    for my $pref (@$prefs) {
        my ($key, $value) = ($pref->{name}, $pref->{value});
        $key = $mapping{$key} || $key;
        next unless $editor->preferences->can($key);
        $editor->preferences->$key($value);
    }
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

