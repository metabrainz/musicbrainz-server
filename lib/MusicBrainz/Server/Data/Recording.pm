package MusicBrainz::Server::Data::Recording;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw( hash_to_row );
use MusicBrainz::Schema qw( schema raw_schema );

extends 'MusicBrainz::Server::Data::FeyEntity';

with
    'MusicBrainz::Server::Data::Role::Name',
    'MusicBrainz::Server::Data::Role::Gid' => {
        redirect_table     => schema->table('recording_gid_redirect') },
    'MusicBrainz::Server::Data::Role::LoadMeta' => {
        metadata_table     => schema->table('recording_meta') },
    'MusicBrainz::Server::Data::Role::Annotation' => {
        annotation_table   => schema->table('recording_annotation') },
    'MusicBrainz::Server::Data::Role::Editable',
    'MusicBrainz::Server::Data::Role::Rating' => {
        rating_table       => raw_schema->table('recording_rating_raw')
    },
    'MusicBrainz::Server::Data::Role::Subobject',
    'MusicBrainz::Server::Data::Role::Tag' => {
        tag_table          => schema->table('recording_tag'),
        raw_tag_table      => raw_schema->table('recording_tag_raw')
    },
    'MusicBrainz::Server::Data::Role::LinksToEdit',
    'MusicBrainz::Server::Data::Role::HasArtistCredit';

method _build_table  { schema->table('recording') }
method _entity_class { 'MusicBrainz::Server::Entity::Recording' }

sub _column_mapping
{
    return {
        id               => 'id',
        gid              => 'gid',
        name             => 'name',
        artist_credit_id => 'artist_credit',
        length           => 'length',
        comment          => 'comment',
        edits_pending    => 'editpending',
    };
}

method can_delete ($recording_id)
{
    my $track_table = $self->c->model('Track')->table;
    my $query = Fey::SQL->new_select
        ->select(1)->from($track_table)
        ->where($track_table->column('recording'), '=', $recording_id)
        ->limit(1);

    return !defined $self->sql->select_single_value(
        $query->sql($self->sql->dbh), $query->bind_params);
}

# We don't change the actual merge method, as Role::Gid provides that
before merge => sub
{
    my ($self, $new_id, @old_ids) = @_;

    # Move tracks to the new recording
    my $track_table = $self->c->model('Track')->table;
    my $query = Fey::SQL->new_update
        ->update($track_table)->set($track_table->column('recording'), $new_id)
        ->where($track_table->column('recording'), 'IN', @old_ids);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
};

method _hash_to_row ($recording)
{
    return hash_to_row($recording, {
        artist_credit => 'artist_credit',
        length        => 'length',
        comment       => 'comment',
        name          => 'name'
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
