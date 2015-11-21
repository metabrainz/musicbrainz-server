package MusicBrainz::Server::Data::CDTOC;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
);
use MusicBrainz::Server::Log qw( log_error );

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'cdtoc';
}

sub _columns
{
    return 'id, discid, freedb_id, track_count, leadout_offset, track_offset';
}

sub _column_mapping
{
    return {
        id => 'id',
        discid => 'discid',
        freedb_id => 'freedb_id',
        track_count => 'track_count',
        leadout_offset => 'leadout_offset',
        track_offset => 'track_offset',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::CDTOC';
}

sub get_by_discid
{
    my ($self, $discid) = @_;
    my @result = $self->_get_by_keys("discid", $discid);
    return $result[0];
}

sub find_by_freedbid
{
    my ($self, $freedbid) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE freedb_id = ?";
    $self->query_to_list($query, [$freedbid]);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'cdtoc', @objs);
}

sub find_or_insert
{
    my ($self, $toc) = @_;

    my $cdtoc = MusicBrainz::Server::Entity::CDTOC->new_from_toc($toc);
    if (!$cdtoc) {
        log_error { "Attempt to insert invalid CDTOC; aborting "};
        return;
    }

    my $id =
        $self->sql->select_single_value(
            'SELECT id FROM cdtoc
              WHERE discid = ?
              AND   track_count = ?
              AND   leadout_offset = ?
              AND   track_offset = ?',
            $cdtoc->discid, $cdtoc->track_count, $cdtoc->leadout_offset,
            $cdtoc->track_offset)
      ||
        $self->sql->insert_row('cdtoc', {
            discid => $cdtoc->discid,
            freedb_id => $cdtoc->freedb_id,
            track_count => $cdtoc->track_count,
            leadout_offset => $cdtoc->leadout_offset,
            track_offset => $cdtoc->track_offset
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
