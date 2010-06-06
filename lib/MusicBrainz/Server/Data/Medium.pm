package MusicBrainz::Server::Data::Medium;
use Moose;
use Method::Signatures::Simple;

use MusicBrainz::Server::Entity::Medium;
use MusicBrainz::Server::Entity::Tracklist;
use MusicBrainz::Server::Data::Utils qw(
    query_to_list
    query_to_list_limited
);
use MusicBrainz::Schema qw( schema );

use aliased 'Fey::Literal::Function';

extends 'MusicBrainz::Server::Data::FeyEntity';
with 'MusicBrainz::Server::Data::Role::Editable';
with 'MusicBrainz::Server::Data::Role::Subobject';

method _build_table  { schema->table('medium') }
method _entity_class { 'MusicBrainz::Server::Entity::Medium' }

around _select => sub
{
    my $orig = shift;
    my ($self) = @_;
    return $self->$orig
        ->select(schema->table('tracklist')->column('trackcount'))
        ->from($self->table, schema->table('tracklist'))
};

method _column_mapping
{
    return {
        id            => 'id',
        tracklist_id  => 'tracklist',
        tracklist     => sub {
            my ($row, $prefix) = @_;
            my $id = $row->{$prefix . 'tracklist'};
            my $track_count = $row->{$prefix . 'trackcount'};
            return unless $id && $track_count;
            return MusicBrainz::Server::Entity::Tracklist->new(
                id          => $id,
                track_count => $track_count,
            );
        },
        release_id    => 'release',
        position      => 'position',
        name          => 'name',
        format_id     => 'format',
        edits_pending => 'editpending',
    };
}

method load_for_releases (@releases)
{
    my %id_to_release = map { $_->id => $_ } @releases;
    my @ids = keys %id_to_release;
    return unless @ids; # nothing to do

    my $query = $self->_select
        ->where($self->table->column('release'), 'IN', @ids)
        ->order_by($self->table->column('release'),
                   $self->table->column('position'));

    my @mediums = query_to_list($self->c->dbh, sub { $self->_new_from_row(@_) },
                                $query->sql($self->c->dbh), $query->bind_params);
    foreach my $medium (@mediums) {
        $id_to_release{$medium->release_id}->add_medium($medium);
    }
}

method find_by_tracklist ($tracklist_id, $limit, $offset)
{
    my $release = $self->c->model('Release');

    my $query = Fey::SQL->new_select
        ->select(
            map { $_->alias('m_' . $_->name) }
                $self->table->columns
        )->from($self->table)
        ->select(
            map { $_->alias('r_' . $_->name) }
                $release->table->columns
        )->from($release->table, $self->table)
        ->select(
            $release->name_columns->{name}->alias('r_name')
        )->from($release->table, $release->_name_table)
        ->where($self->table->column('tracklist'), '=', $tracklist_id)
        ->order_by(
            (map { $release->table->column($_) } qw( date_year date_month date_day )),
            Function->new('musicbrainz_collate', $release->name_columns->{name})
        )
        ->limit($limit, $offset);

    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub {
            my $row = shift;
            my $medium = $self->_new_from_row($row, 'm_');
            my $release = MusicBrainz::Server::Data::Release->_new_from_row($row, 'r_');
            $medium->release($release);
            return $medium;
        },
        $query->sql($self->c->dbh), $query->bind_params);
}

method _hash_to_row ($medium_hash)
{
    my %row;
    my $mapping = $self->_column_mapping;
    for my $col (qw( name format_id position tracklist_id release_id ))
    {
        next unless exists $medium_hash->{$col};
        my $mapped = $mapping->{$col} || $col;
        $row{$mapped} = $medium_hash->{$col};
    }
    return \%row;
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
