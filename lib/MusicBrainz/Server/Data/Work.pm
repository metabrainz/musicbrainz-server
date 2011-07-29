package MusicBrainz::Server::Data::Work;

use Moose;
use MusicBrainz::Server::Entity::Work;
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    generate_gid
    hash_to_row
    load_subobjects
    merge_table_attributes
    placeholders
    query_to_list
    query_to_list_limited
);

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => 'work_name' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'work' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'work' };
with 'MusicBrainz::Server::Data::Role::BrowseVA';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'work' };
with 'MusicBrainz::Server::Data::Role::Merge';

sub _table
{
    my $self = shift;
    return 'work ' . (shift() || '') . ' JOIN work_name name ON work.name=name.id';
}

sub _table_join_name {
    my ($self, $join_on) = @_;
    return $self->_table("ON work.name = $join_on");
}

sub _columns
{
    return 'work.id, work.gid, work.type AS type_id, name.name,
            work.iswc, work.comment, work.edits_pending, work.last_updated';
}

sub _id_column
{
    return 'work.id';
}

sub _gid_redirect_table
{
    return 'work_gid_redirect';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Work';
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset) = @_;

    my $query =
        'SELECT link_type, ' . $self->_columns .'
           FROM (
                    -- Select works that are related to recordings for this artist
                    SELECT entity1 AS work, NULL as link_type
                      FROM l_recording_work
                      JOIN recording ON recording.id = entity0
                      JOIN artist_credit_name acn
                              ON acn.artist_credit = recording.artist_credit
                     WHERE acn.artist = ?
              UNION
                    -- Select works that this artist is related to
                    SELECT entity1 AS work, lt.name AS link_type
                      FROM l_artist_work ar
                      JOIN link ON ar.link = link.id
                      JOIN link_type lt ON lt.id = link.link_type
                     WHERE entity0 = ?
                ) s, ' . $self->_table .'
          WHERE work.id = s.work
       ORDER BY link_type NULLS FIRST, musicbrainz_collate(name.name)
         OFFSET ?';

    my (%grouped_works, %work_cache);

    # We actually use this for the side effect in the closure
    my (undef, $hits) = query_to_list_limited(
        $self->c->sql, $offset, $limit, sub {
            my $row = shift;

            my $work = $work_cache{ $row->{id} } || do {
                $work_cache{$row->{id}} = $self->_new_from_row($row);
            };

            my $group = $row->{link_type} || '';
            $grouped_works{$group} ||= [];
            push @{ $grouped_works{$group} }, $work;
        },
        $query, $artist_id, $artist_id, $offset || 0);

    return ([ map +{
        link_type => $_,
        works => $grouped_works{$_}
    }, sort keys %grouped_works ], $hits);
}

sub find_by_iswc
{
    my ($self, $iswc) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE iswc = ?
                 ORDER BY musicbrainz_collate(name.name)";

    return query_to_list(
        $self->c->sql, sub { $self->_new_from_row(@_) },
        $query, $iswc);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'work', @objs);
}

sub insert
{
    my ($self, @works) = @_;
    my %names = $self->find_or_insert_names(map { $_->{name} } @works);
    my $class = $self->_entity_class;
    my @created;
    for my $work (@works)
    {
        my $row = $self->_hash_to_row($work, \%names);
        $row->{gid} = $work->{gid} || generate_gid();
        push @created, $class->new(
            id => $self->sql->insert_row('work', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @works > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $work_id, $update) = @_;
    my %names = $self->find_or_insert_names($update->{name});
    my $row = $self->_hash_to_row($update, \%names);
    $self->sql->update_row('work', $row, { id => $work_id });
}

sub delete
{
    my ($self, $work_id) = @_;
    $self->c->model('Relationship')->delete_entities('work', $work_id);
    $self->annotation->delete($work_id);
    $self->alias->delete_entities($work_id);
    $self->tags->delete($work_id);
    $self->rating->delete($work_id);
    $self->remove_gid_redirects($work_id);
    $self->sql->do('DELETE FROM work WHERE id = ?', $work_id);
    return;
}

sub _merge_impl
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('work', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('work', $new_id, @old_ids);

    merge_table_attributes(
        $self->sql => (
            table => 'work',
            columns => [ qw( type iswc comment ) ],
            old_ids => \@old_ids,
            new_id => $new_id
        )
    );

    $self->_delete_and_redirect_gids('work', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $work, $names) = @_;
    my $row = hash_to_row($work, {
        type => 'type_id',
        map { $_ => $_ } qw( iswc comment )
    });

    $row->{name} = $names->{$work->{name}}
        if (exists $work->{name});

    return $row;
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "work_meta", sub {
        my ($obj, $row) = @_;
        $obj->rating($row->{rating}) if defined $row->{rating};
        $obj->rating_count($row->{rating_count}) if defined $row->{rating_count};
        $obj->last_updated($row->{last_updated}) if defined $row->{last_updated};
    }, @_);
}


=method find_recording_artists

This method will return a map with lists of artist names for recordings
the given works are linked to. The artist names are sorted by the number
of recordings in descending order (i.e. the top artists will be first in
the list).

=cut

sub find_artists
{
    my ($self, $works, $limit) = @_;

    my @ids = map { $_->id } @$works;
    return () unless @ids;

    my %map;
    $self->_find_composers(\@ids, \%map);
    $self->_find_recording_artists(\@ids, \%map);

    for my $work_id (keys %map)
    {
        my @artists = @{$map{$work_id}};
        $map{$work_id} = {
            hits => scalar @artists,
            results => scalar @artists > $limit ? [ @artists[ 0 .. ($limit-1) ] ] : \@artists,
        }
    }

    return %map;
}

sub _find_composers
{
    my ($self, $ids, $map) = @_;

    my $query = "
        SELECT law.entity1 AS work, an.name
        FROM l_artist_work law
        JOIN link l ON law.link=l.id
        JOIN link_type lt ON l.link_type=lt.id
        JOIN artist a ON law.entity0=a.id
        JOIN artist_name an ON a.name=an.id
        WHERE law.entity1 IN (" . placeholders(@$ids) . ")
          AND lt.gid IN ('d59d99ea-23d4-4a80-b066-edca32ee158f', -- composer
                         '3e48faba-ec01-47fd-8e89-30e81161661c', -- lyricist
                         'a255bca1-b157-4518-9108-7b147dc3fc68') -- writer
        GROUP BY law.entity1, an.name
        ORDER BY musicbrainz_collate(an.name)
    ";

    $self->sql->select($query, @$ids);

    while (my $row = $self->sql->next_row_hash_ref) {
        my $work_id = delete $row->{work};
        $map->{$work_id} ||= [];
        push @{ $map->{$work_id} }, $row->{name};
    }
}

sub _find_recording_artists
{
    my ($self, $ids, $map) = @_;

    my $query = "
        SELECT lrw.entity1 AS work, an.name
        FROM l_recording_work lrw
        JOIN recording r ON lrw.entity0 = r.id
        JOIN artist_credit_name acn ON r.artist_credit = acn.artist_credit
        JOIN artist_name an ON anc.name = an.id
        WHERE lrw.entity1 IN (" . placeholders(@$ids) . ")
        GROUP BY lrw.entity1, an.name
        ORDER BY count(*) DESC
    ";

    $self->sql->select($query, @$ids);

    while (my $row = $self->sql->next_row_hash_ref) {
        my $work_id = delete $row->{work};
        $map->{$work_id} ||= [];
        push @{ $map->{$work_id} }, $row->{name};
    }
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
