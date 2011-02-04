package MusicBrainz::Server::Data::Echoprint;
use Moose;

use MusicBrainz::Server::Data::Utils qw( placeholders );
use List::MoreUtils qw( part zip );

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'echoprint JOIN clientversion ON echoprint.version = clientversion.id';
}

sub _columns
{
    return 'echoprint.id, echoprint.echoprint, clientversion.version';
}

sub _column_mapping
{
    return {
        id             => 'id',
        echoprint      => 'echoprint',
        client_version => 'version',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Echoprint';
}

sub _id_column
{
    return 'echoprint.id';
}

sub get_by_echoprint
{
    my ($self, $echoprint) = @_;
    my @result = values %{$self->_get_by_keys("echoprint.echoprint", $echoprint)};
    return $result[0];
}

sub get_by_echoprints
{
    my ($self, @echoprints) = @_;
    return $self->_get_by_keys("echoprint.echoprint", @echoprints);
}

sub delete_unused_echoprints
{
    my ($self, @echoprint_ids) = @_;
    my $sql = Sql->new($self->c->dbh);
    # Remove unreferenced Echoprints
    if (@echoprint_ids) {
        $sql->do('
            DELETE FROM echoprint WHERE
                id IN ('.placeholders(@echoprint_ids).') AND
                id NOT IN (
                    SELECT echoprint FROM recording_echoprint
                    WHERE echoprint IN ('.placeholders(@echoprint_ids).')
                    GROUP BY echoprint HAVING count(*) > 0)
            ', @echoprint_ids, @echoprint_ids);
    }
}

sub find_or_insert
{
    my ($self, $client, @echoprints) = @_;
    my $query    = 'SELECT echoprint,id FROM echoprint WHERE echoprint IN (' . placeholders(@echoprints) . ')';
    my $rows     = $self->sql->select_list_of_hashes($query, @echoprints);
    my %echoprint_map = map {
        $_->{echoprint} => $_->{id}
    } @$rows;

    my @insert;
    for my $echoprint (@echoprints) {
        next if exists $echoprint_map{$echoprint};
        push @insert, $echoprint;
    }

    if (@insert) {
        my $client_id = $self->sql->select_single_value('SELECT id FROM clientversion WHERE version = ?', $client)
            || $self->sql->insert_row('clientversion', { version => $client }, 'id');

        my @clients = ($client_id) x @insert;
        $rows = $self->sql->select_list_of_hashes(
            'INSERT INTO echoprint (version, echoprint) VALUES ' . join(', ', ("(?, ?)") x @insert) .
                ' RETURNING echoprint,id',
            zip(@clients, @insert));

        $echoprint_map{ $_->{echoprint} } = $_->{id}
            for @$rows;
    }

    return %echoprint_map;
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
