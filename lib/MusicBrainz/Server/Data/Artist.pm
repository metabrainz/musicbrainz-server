package MusicBrainz::Server::Data::Artist;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    hash_to_row
    add_partial_date_to_row
    partial_date_from_row
    placeholders
    query_to_list_limited
);
use MusicBrainz::Schema qw( schema raw_schema );

extends 'MusicBrainz::Server::Data::FeyEntity';

with
    'MusicBrainz::Server::Data::Role::Name',
    'MusicBrainz::Server::Data::Role::Gid' => {
        redirect_table     => schema->table('artist_gid_redirect') },
    'MusicBrainz::Server::Data::Role::LoadMeta' => {
        metadata_table     => schema->table('artist_meta') },
    'MusicBrainz::Server::Data::Role::Subscription' => {
        subscription_table => schema->table('editor_subscribe_artist'), },
    'MusicBrainz::Server::Data::Role::Alias' => {
        alias_table        => schema->table('artist_alias') },
    'MusicBrainz::Server::Data::Role::Annotation' => {
        annotation_table   => schema->table('artist_annotation') },
    'MusicBrainz::Server::Data::Role::CoreEntityCache' => {
        prefix             => 'artist' },
    'MusicBrainz::Server::Data::Role::Editable',
    'MusicBrainz::Server::Data::Role::Rating' => {
        rating_table       => raw_schema->table('artist_rating_raw')
    },
    'MusicBrainz::Server::Data::Role::Browse',
    'MusicBrainz::Server::Data::Role::Subobject',
    'MusicBrainz::Server::Data::Role::Tag' => {
        tag_table          => schema->table('artist_tag'),
        raw_tag_table      => raw_schema->table('artist_tag_raw')
    },
    'MusicBrainz::Server::Data::Role::LinksToEdit',
    'MusicBrainz::Server::Data::Role::Relationship';

method _build_table  { schema->table('artist') }
method _entity_class { 'MusicBrainz::Server::Entity::Artist' }

method _column_mapping
{
    return {
        id            => 'id',
        gid           => 'gid',
        name          => 'name',
        sort_name     => 'sortname',
        type_id       => 'type',
        country_id    => 'country',
        gender_id     => 'gender',
        begin_date    => sub { partial_date_from_row(shift, shift() . 'begindate_') },
        end_date      => sub { partial_date_from_row(shift, shift() . 'enddate_') },
        edits_pending => 'editpending',
        comment       => 'comment',
    };
}

method can_delete ($artist_id) {
    my $ac = schema->table('artist_credit');
    my $ac_name = schema->table('artist_credit_name');

    my $query = Fey::SQL->new_select
        ->select($ac->column('refcount'))
        ->from($ac, $ac_name)
        ->where($ac->column('refcount'), '>', 0)
        ->where($ac_name->column('artist'), '=', $artist_id);

    my $active_credits = $self->sql->select_single_column_array(
        $query->sql($self->sql->dbh), $query->bind_params);
    return @$active_credits == 0;
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->subscription->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('ArtistCredit')->merge_artists($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('artist', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('artist', $new_id, @old_ids);

    $self->_delete_and_redirect_gids('artist', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $values, $names) = @_;

    my $row = hash_to_row($values, {
        country  => 'country_id',
        type     => 'type_id',
        gender   => 'gender_id',
        comment  => 'comment',
        name     => 'name',
        sortname => 'sort_name',
    });

    if (exists $values->{begin_date}) {
        add_partial_date_to_row($row, $values->{begin_date}, 'begindate');
    }

    if (exists $values->{end_date}) {
        add_partial_date_to_row($row, $values->{end_date}, 'enddate');
    }

    return $row;
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
