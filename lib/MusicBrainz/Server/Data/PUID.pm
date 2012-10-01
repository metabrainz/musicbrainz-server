package MusicBrainz::Server::Data::PUID;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( placeholders );
use List::MoreUtils qw( part zip );

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'puid JOIN clientversion ON puid.version = clientversion.id';
}

sub _columns
{
    return 'puid.id, puid.puid, clientversion.version';
}

sub _column_mapping
{
    return {
        id             => 'id',
        puid           => 'puid',
        client_version => 'version',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::PUID';
}

sub _id_column
{
    return 'puid.id';
}

sub get_by_puid
{
    my ($self, $puid) = @_;
    my @result = values %{$self->_get_by_keys("puid.puid", $puid)};
    return $result[0];
}

sub get_by_puids
{
    my ($self, @puids) = @_;
    return $self->_get_by_keys("puid.puid", @puids);
}

sub delete_unused_puids
{
    my ($self, @puid_ids) = @_;
    # Remove unreferenced PUIDs
    if (@puid_ids) {
        $self->sql->do('
            DELETE FROM puid WHERE
                id IN ('.placeholders(@puid_ids).') AND
                id NOT IN (
                    SELECT puid FROM recording_puid
                    WHERE puid IN ('.placeholders(@puid_ids).')
                    GROUP BY puid HAVING count(*) > 0)
            ', @puid_ids, @puid_ids);
    }
}

sub find_or_insert
{
    my ($self, $client, @puids) = @_;
    my $query    = 'SELECT puid,id FROM puid WHERE puid IN (' . placeholders(@puids) . ')';
    my $rows     = $self->sql->select_list_of_hashes($query, @puids);
    my %puid_map = map {
        $_->{puid} => $_->{id}
    } @$rows;

    my @insert;
    for my $puid (@puids) {
        next if exists $puid_map{$puid};
        push @insert, $puid;
    }

    if (@insert) {
        my $client_id = $self->sql->select_single_value('SELECT id FROM clientversion WHERE version = ?', $client)
            || $self->sql->insert_row('clientversion', { version => $client }, 'id');

        my @clients = ($client_id) x @insert;
        $rows = $self->sql->select_list_of_hashes(
            'INSERT INTO puid (version, puid) VALUES ' . join(', ', ("(?, ?)") x @insert) .
                ' RETURNING puid,id',
            zip(@clients, @insert));

        $puid_map{ $_->{puid} } = $_->{id}
            for @$rows;
    }

    return %puid_map;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
