package MusicBrainz::Server::Data::CDStub;

use Moose;
use namespace::autoclean;

use DBDefs;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );
use MusicBrainz::Server::Entity::Barcode;
use Readonly;

extends 'MusicBrainz::Server::Data::Entity';

Readonly my $LIMIT_TOP_CDSTUBS => 1000;

sub _table
{
    return 'release_raw JOIN cdtoc_raw ON cdtoc_raw.release = release_raw.id';
}

sub _columns
{
    return join(', ', qw(
        release_raw.id
        title
        artist
        added
        last_modified
        lookup_count
        modify_count
        source
        barcode
        comment
        discid
        track_count
        leadout_offset
        track_offset
    ));
}

sub _column_mapping
{
    return {
        id => 'id',
        title => 'title',
        artist => 'artist',
        date_added=> 'added',
        last_modified => 'last_modified',
        lookup_count => 'lookup_count',
        modify_count => 'modify_count',
        source => 'source',
        barcode => sub { MusicBrainz::Server::Entity::Barcode->new_from_row(shift, shift) },
        comment => 'comment',
        discid => 'discid',
        track_count => 'track_count',
        leadout_offset => 'leadout_offset',
        track_offset => 'track_offset',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::CDStub';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'cdstub', @objs);
}

sub load_top_cdstubs
{
    my ($self, $limit, $offset) = @_;
    my $query = 'SELECT ' . $self->_columns . '
                 FROM ' . $self->_table . '
                 ORDER BY lookup_count desc, modify_count DESC';
    $self->query_to_list_limited($query, [], $LIMIT_TOP_CDSTUBS, $offset);
}

sub increment_lookup_count
{
    my ($self, $cdstub_id) = @_;
    return if DBDefs->DB_READ_ONLY;

    $self->sql->auto_commit(1);
    $self->sql->do('UPDATE release_raw SET lookup_count = lookup_count + 1 WHERE id = ?', $cdstub_id);
}

sub get_by_discid {
    my ($self, $discid) = @_;

    my @cdstubs = $self->_get_by_keys('discid', $discid);
    return $cdstubs[0];
}

sub delete
{
    my ($self, $discid) = @_;
    my $release_id = $self->sql->select_single_value(
        'DELETE FROM cdtoc_raw WHERE discid = ? RETURNING release',
        $discid);
    $self->sql->do(
        'DELETE FROM track_raw WHERE release = ?',
        $release_id);
    $self->sql->do(
        'DELETE FROM release_raw WHERE id = ?',
        $release_id);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
