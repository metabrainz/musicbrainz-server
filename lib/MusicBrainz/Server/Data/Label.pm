package MusicBrainz::Server::Data::Label;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw(
    add_partial_date_to_row
    check_in_use
    hash_to_row
    partial_date_from_row
    query_to_list
);
use MusicBrainz::Schema qw( schema raw_schema );

extends 'MusicBrainz::Server::Data::FeyEntity';

with
    'MusicBrainz::Server::Data::Role::Annotation' => {
        annotation_table   => schema->table('label_annotation') },
    'MusicBrainz::Server::Data::Role::Name',
    'MusicBrainz::Server::Data::Role::Alias' => {
        alias_table        => schema->table('label_alias') },
    'MusicBrainz::Server::Data::Role::Subscription' => {
        subscription_table => schema->table('editor_subscribe_label'), },
    'MusicBrainz::Server::Data::Role::Gid' => {
        redirect_table     => schema->table('label_gid_redirect') },
    'MusicBrainz::Server::Data::Role::LoadMeta' => {
        metadata_table     => schema->table('label_meta') },
    'MusicBrainz::Server::Data::Role::CoreEntityCache' => {
        prefix             => 'label' },
    'MusicBrainz::Server::Data::Role::Editable',
    'MusicBrainz::Server::Data::Role::Rating' => {
        rating_table       => raw_schema->table('label_rating_raw')
    },
    'MusicBrainz::Server::Data::Role::Browse',
    'MusicBrainz::Server::Data::Role::Subobject',
       'MusicBrainz::Server::Data::Role::Tag' => {
        tag_table          => schema->table('label_tag'),
        raw_tag_table      => raw_schema->table('label_tag_raw')
    },
    'MusicBrainz::Server::Data::Role::LinksToEdit';

method _build_table  { schema->table('label') }
method _entity_class { 'MusicBrainz::Server::Entity::Label' }

sub _column_mapping
{
    return {
        id            => 'id',
        gid           => 'gid',
        name          => 'name',
        sort_name     => 'sortname',
        type_id       => 'type',
        country_id    => 'country',
        label_code    => 'labelcode',
        begin_date    => sub { partial_date_from_row(shift, shift() . 'begindate_') },
        end_date      => sub { partial_date_from_row(shift, shift() . 'enddate_') },
        edits_pending => 'editpending',
        comment       => 'comment',
    };
}

method find_by_artist ($artist_id)
{
    my $rl      = $self->c->model('ReleaseLabel')->table;
    my $release = $self->c->model('Release')->table;
    my $acn     = schema->table('artist_credit_name');
    my $acn_release = Fey::FK->new(
        source_columns => [ $release->column('artist_credit') ],
        target_columns => [ $acn->column('artist_credit') ]
    );

    my $rl_subq = Fey::SQL->new_select
        ->select($rl->column('label'))
        ->from($rl, $release)
        ->from($release, $acn, $acn_release)
        ->where($acn->column('artist'), '=', $artist_id);

    my $query = $self->_select
        ->where($self->table->column('id'), 'IN', $rl_subq)
        ->order_by($self->table->column('id'));

    return query_to_list(
        $self->c->dbh, sub { $self->_new_from_row(@_) },
        $query, $artist_id);
}

method in_use ($label_id)
{
    return check_in_use($self->sql,
        'release_label         WHERE label = ?'   => [ $label_id ],
        'l_artist_label        WHERE entity1 = ?' => [ $label_id ],
        'l_label_recording     WHERE entity0 = ?' => [ $label_id ],
        'l_label_release       WHERE entity0 = ?' => [ $label_id ],
        'l_label_release_group WHERE entity0 = ?' => [ $label_id ],
        'l_label_url           WHERE entity0 = ?' => [ $label_id ],
        'l_label_work          WHERE entity0 = ?' => [ $label_id ],
        'l_label_label         WHERE entity0 = ? OR entity1 = ?'=> [ $label_id, $label_id ],
    );
}

method can_delete ($label_id)
{
    my $rl_table = $self->c->model('ReleaseLabel')->table;
    my $query = Fey::SQL->new_select
        ->select(1)->from($rl_table)
        ->where($rl_table->column('label'), '=', $label_id)
        ->limit(1);

    return !defined $self->sql->select_single_value(
        $query->sql($self->sql->dbh), $query->bind_params);
}

method _hash_to_row ($label)
{
    my $row = hash_to_row($label, {
        comment   => 'comment',
        country   => 'country_id',
        type      => 'type_id',
        labelcode => 'label_code',
        name      => 'name',
        sortname  => 'sort_name',
    });

    if (exists $label->{begin_date}) {
        add_partial_date_to_row($row, $label->{begin_date}, 'begindate');
    }

    if (exists $label->{end_date}) {
        add_partial_date_to_row($row, $label->{end_date}, 'enddate');
    }

    return $row;
}

__PACKAGE__->meta->make_immutable;

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
