package MusicBrainz::Server::Data::Work;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    query_to_list_limited
);
use MusicBrainz::Schema qw( schema raw_schema );

extends 'MusicBrainz::Server::Data::FeyEntity';

with
    'MusicBrainz::Server::Data::Role::Name',
    'MusicBrainz::Server::Data::Role::Alias' => {
        alias_table        => schema->table('work_alias')
    },
    'MusicBrainz::Server::Data::Role::Subobject',
    'MusicBrainz::Server::Data::Role::Gid' => {
        redirect_table     => schema->table('work_gid_redirect') },
    'MusicBrainz::Server::Data::Role::LoadMeta' => {
        metadata_table     => schema->table('work_meta') },
    'MusicBrainz::Server::Data::Role::Annotation' => {
        annotation_table   => schema->table('work_annotation') },
    'MusicBrainz::Server::Data::Role::Rating' => {
        rating_table       => raw_schema->table('work_rating_raw')
    },
    'MusicBrainz::Server::Data::Role::BrowseVA',
    'MusicBrainz::Server::Data::Role::Tag' => {
        tag_table          => schema->table('work_tag'),
        raw_tag_table      => raw_schema->table('work_tag_raw')
    },
    'MusicBrainz::Server::Data::Role::LinksToEdit';

method _build_table  { schema->table('work') }
method _entity_class { 'MusicBrainz::Server::Entity::Work' }

sub _column_mapping
{
    return {
        id               => 'id',
        gid              => 'gid',
        type_id          => 'type',
        name             => 'name',
        iswc             => 'iswc',
        artist_credit_id => 'artist_credit',
        comment          => 'comment',
        edits_pending    => 'editpending',
    };
}

method find_by_artist ($artist_id, $limit, $offset)
{
    my $acn = schema->table('artist_credit_name');

    # XXX Fey should be able to cope with this
    my $work_acn = Fey::FK->new(
        source_columns => [ $self->table->column('artist_credit') ],
        target_columns => [ $acn->column('artist_credit') ]);

    my $query = $self->_select
        ->from($self->table, $acn, $work_acn)
        ->where($acn->column('artist'), '=', $artist_id)
        ->order_by(Function->new('musicbrainz_collate', $self->name_columns->{name}))
        ->limit(undef, $offset || 0);

    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query->sql($self->c->dbh), $query->bind_params);
}

method _hash_to_row ($work)
{
    return hash_to_row($work, {
        artist_credit => 'artist_credit',
        iswc          => 'iswc',
        type          => 'type_id',
        comment       => 'comment',
        name          => 'name',
    });
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
