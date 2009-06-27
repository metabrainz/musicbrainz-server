package MusicBrainz::Server::Data::Editor;
use Moose;

use MusicBrainz::Server::Entity::Editor;

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
        auto_edits              => 'autoeditsaccepted',
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

