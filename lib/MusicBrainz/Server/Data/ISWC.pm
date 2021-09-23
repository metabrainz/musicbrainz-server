package MusicBrainz::Server::Data::ISWC;
use Moose;
use namespace::autoclean;

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw(
    object_to_ids
    placeholders
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'iswc' };

sub _table
{
    return 'iswc';
}

sub _columns
{
    return 'id, iswc, work, source, edits_pending';
}

sub _column_mapping
{
    return {
        id            => 'id',
        iswc          => 'iswc',
        work_id       => 'work',
        source_id     => 'source',
        edits_pending => 'edits_pending',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::ISWC';
}

sub _find {
    my ($self, $field, @ids) = @_;

    my $query = 'SELECT ' . $self->_columns .'
                   FROM ' . $self->_table . "
                  WHERE $field = any(?)
                  ORDER BY iswc, id";

    $self->query_to_list($query, [\@ids]);
}

=method find_by_work

    find_by_work(@work_ids : Array[Integer])

Find L<MusicBrainz::Server::Entity::ISWC> objects that are linked to specific
works. The works are searched as a disjunction, so you will get all ISWCS linked
to any of the inputs.

Returns an array of ISWC objects.

=cut

sub find_by_works
{
    my ($self, @work_ids) = @_;

    return $self->_find('work', @work_ids);
}

=method load_for_works

    load_for_works(@works : Array[Work])

Load ISWCs for an array of works, and nest the ISWC objects inside each
respective work.

=cut

sub load_for_works
{
    my ($self, @works) = @_;
    my %id_to_works = object_to_ids(uniq grep defined, @works);
    my @ids = keys %id_to_works;
    return unless @ids; # nothing to do
    my @iswcs = $self->find_by_works(@ids);

    foreach my $iswc (@iswcs) {
        foreach my $work (@{ $id_to_works{$iswc->work_id} }) {
            $work->add_iswc($iswc);
            $iswc->work($work);
        }
    }
}

=method find_by_iswc

    find_by_iswc($iswc : Text)

Find ISWCs that have a specific ISWC. This can return a list of ISWCs that are
linked to different works.

=cut

sub find_by_iswc
{
    my ($self, $iswc) = @_;

    return $self->_find('iswc', $iswc);
}

=method delete

    delete(@iswc_ids : Array[Int])

Delete a list of ISWCs from the database, by ISWC row ID.

=cut

sub delete
{
    my ($self, @iswc_ids) = @_;
    $self->sql->do('DELETE FROM iswc
                    WHERE id IN ('.placeholders(@iswc_ids).')', @iswc_ids);
}

=method merge_works

    merge_works($new_work_id : Integer, @old_work_ids : Array[Integer])

Merge the ISWCs of an array of works into a single work.

=cut

sub merge_works
{
    my ($self, $new_id, @old_ids) = @_;
    my @ids = ($new_id, @old_ids);

    # Keep distinct ISWCs
    $self->sql->do(
        'DELETE FROM iswc
          WHERE work = any(?)
            AND (iswc, work) NOT IN (
                    SELECT DISTINCT ON (iswc) iswc, work
                      FROM iswc
                     WHERE work = any(?)
                )',
        \@ids, \@ids);

    # Move everything to the new recording
    $self->sql->do('UPDATE iswc SET work = ? WHERE work = any(?)', $new_id, \@old_ids);
}

=method delete_works

    delete_works(@work_ids : Array[Int])

Delete all ISWCs for a list of given works. The list of works is disjunctive, so
all ISWCs for each work will be deleted (rather than ISWCs that are only used by
all works).

=cut

sub delete_works
{
    my ($self, @work_ids) = @_;
    $self->sql->do('DELETE FROM iswc WHERE work = any(?)', \@work_ids);
}

=method insert

    insert(@iswcs : Array[IswcHash])

Insert an array of ISWCs. No checks are done to ensure that the ISWC does not
already exist for a given work, so this could throw an exception.

An IswcHash has key:

    iswc : Text
    work_id : Int

=cut

sub insert
{
    my ($self, @iswcs) = @_;

    $self->sql->do('INSERT INTO iswc (work, iswc) VALUES ' .
                 (join q(,), (('(?, ?)') x @iswcs)),
             map { $_->{work_id}, $_->{iswc} } @iswcs);
}

=method filter_additions

    fiter_additions(@iswcs : Array[IswcEditHash])

Filter a list of insertions down to unique and new additions, ready for
inserting via an AddISWCs edit. C<IswcEditHash> is the data passed in to the
edit.

=cut

sub filter_additions
{
    my ($self, @additions) = @_;
    return unless @additions;

    my $query =
        'SELECT DISTINCT ON (iswc, work) array_index
           FROM (VALUES ' . join(', ', ('(?::int, ?::text, ?::int)') x @additions) . ')
                  addition (array_index, iswc, work)
          WHERE NOT EXISTS (
                    SELECT TRUE FROM iswc
                     WHERE iswc.iswc = addition.iswc
                       AND iswc.work = addition.work
                    )
                AND work IN (SELECT id FROM work)';

    my @filtered = @{
        $self->sql->select_single_column_array(
            $query,
            do {
                my $i = 0;
                map {
                    $i++, $_->{iswc}, $_->{work}{id}
                } @additions
            }
        )
    };
    return map { $additions[$_] } @filtered;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
