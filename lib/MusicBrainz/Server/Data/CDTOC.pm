package MusicBrainz::Server::Data::CDTOC;

use Moose;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    query_to_list
);
use TryCatch;

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'cdtoc';
}

sub _columns
{
    return 'id, discid, freedbid, trackcount, leadoutoffset, trackoffset';
}

sub _column_mapping
{
    return {
        id => 'id',
        discid => 'discid',
        freedbid => 'freedbid',
        track_count => 'trackcount',
        leadout_offset => 'leadoutoffset',
        track_offset => 'trackoffset',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::CDTOC';
}

sub get_by_discid
{
    my ($self, $discid) = @_;
    my @result = values %{$self->_get_by_keys("discid", $discid)};
    return $result[0];
}

sub find_by_freedbid
{
    my ($self, $freedbid) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE freedbid = ?";
    return query_to_list(
        $self->c->dbh, sub { $self->_new_from_row(@_) },
        $query, $freedbid);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'cdtoc', @objs);
}

sub find_or_insert
{
    my ($self, $toc) = @_;

    my $cdtoc = MusicBrainz::Server::Entity::CDTOC->new_from_toc($toc) or return;

    my $id =
        $self->sql->select_single_value(
            'SELECT id FROM cdtoc 
              WHERE discid = ?
              AND   trackcount = ?
              AND   leadoutoffset = ?
              AND   trackoffset = ?',
            $cdtoc->discid, $cdtoc->track_count, $cdtoc->leadout_offset,
            $cdtoc->track_offset)
      ||
        $self->sql->insert_row('cdtoc', {
            discid => $cdtoc->discid,
            freedbid => $cdtoc->freedbid,
            trackcount => $cdtoc->track_count,
            leadoutoffset => $cdtoc->leadout_offset,
            trackoffset => $cdtoc->track_offset
        }, 'id');

    return $id;
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
