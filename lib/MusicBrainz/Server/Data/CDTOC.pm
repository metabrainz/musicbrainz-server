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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
