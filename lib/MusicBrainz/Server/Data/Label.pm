package MusicBrainz::Server::Data::Label;

use Moose;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::ReleaseLabel;
use MusicBrainz::Server::Entity::Label;
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    generate_gid
    partial_date_from_row
    placeholders
    load_subobjects
    query_to_list_limited
    query_to_list
    check_in_use
);
use MusicBrainz::Schema qw( schema );

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
        metadata_table     => schema->table('label_meta') };

with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'label' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'label' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Browse';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'label' };

sub _build_table { schema->table('label') }

sub _table
{
    return 'label ' .
           'JOIN label_name name ON label.name=name.id ' .
           'JOIN label_name sortname ON label.sortname=sortname.id';
}

sub _columns
{
    return 'label.id, gid, name.name, sortname.name AS sortname, ' .
           'type, country, editpending, labelcode, ' .
           'begindate_year, begindate_month, begindate_day, ' .
           'enddate_year, enddate_month, enddate_day, comment';
}

sub _id_column
{
    return 'label.id';
}

sub _gid_redirect_table
{
    return 'label_gid_redirect';
}

sub _column_mapping
{
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        sort_name => 'sortname',
        type_id => 'type',
        country_id => 'country',
        label_code => 'labelcode',
        begin_date => sub { partial_date_from_row(shift, shift() . 'begindate_') },
        end_date => sub { partial_date_from_row(shift, shift() . 'enddate_') },
        edits_pending => 'editpending',
        comment => 'comment',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Label';
}

sub find_by_subscribed_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_label s ON label.id = s.label
                 WHERE s.editor = ?
                 ORDER BY musicbrainz_collate(name.name), label.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $editor_id, $offset || 0);
}

sub find_by_artist
{
    my ($self, $artist_id) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                 WHERE label.id IN (
                         SELECT rl.label
                         FROM release_label rl
                         JOIN release ON rl.release = release.id
                         JOIN artist_credit_name acn ON acn.artist_credit = release.artist_credit
                         WHERE acn.artist = ?
                 )
                 ORDER BY label.id";

    return query_to_list(
        $self->c->dbh, sub { $self->_new_from_row(@_) },
        $query, $artist_id);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'label', @objs);
}

sub insert
{
    my ($self, @labels) = @_;
    my $sql = Sql->new($self->c->dbh);
    my %names = $self->find_or_insert_names(map { $_->{name}, $_->{sort_name } } @labels);
    my $class = $self->_entity_class;
    my @created;
    for my $label (@labels)
    {
        my $row = $self->_hash_to_row($label, \%names);
        $row->{gid} = $label->{gid} || generate_gid();
        push @created, $class->new(
            id => $sql->insert_row('label', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @labels > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $label_id, $update) = @_;
    my $sql = Sql->new($self->c->dbh);
    my %names = $self->find_or_insert_names($update->{name}, $update->{sort_name});
    my $row = $self->_hash_to_row($update, \%names);
    $sql->update_row('label', $row, { id => $label_id });
    return 1;
}

sub in_use
{
    my ($self, $label_id) = @_;
    my $sql = Sql->new($self->c->dbh);

    return check_in_use($sql,
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

sub can_delete
{
    my ($self, $label_id) = @_;
    my $sql = Sql->new($self->c->dbh);
    my $refcount = $sql->select_single_column_array('SELECT 1 FROM release_label WHERE label = ?', $label_id);
    return @$refcount == 0;
}

sub delete
{
    my ($self, @label_ids) = @_;
    @label_ids = grep { $self->can_delete($_) } @label_ids;

    $self->c->model('Relationship')->delete_entities('label', @label_ids);
    $self->annotation->delete(@label_ids);
    $self->alias->delete_entities(@label_ids);
    $self->tags->delete(@label_ids);
    $self->rating->delete(@label_ids);
    $self->subscription->delete(@label_ids);
    $self->remove_gid_redirects(@label_ids);
    my $sql = Sql->new($self->c->dbh);
    $sql->do('DELETE FROM label WHERE id IN (' . placeholders(@label_ids) . ')', @label_ids);
    return 1;
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;

    $self->alias->merge($new_id, @old_ids);
    $self->tags->merge($new_id, @old_ids);
    $self->rating->merge($new_id, @old_ids);
    $self->subscription->merge($new_id, @old_ids);
    $self->annotation->merge($new_id, @old_ids);
    $self->c->model('ReleaseLabel')->merge_labels($new_id, @old_ids);
    $self->c->model('Edit')->merge_entities('label', $new_id, @old_ids);
    $self->c->model('Relationship')->merge_entities('label', $new_id, @old_ids);

    $self->_delete_and_redirect_gids('label', $new_id, @old_ids);
    return 1;
}

sub _hash_to_row
{
    my ($self, $label, $names) = @_;
    my %row = (
        begindate_year => $label->{begin_date}->{year},
        begindate_month => $label->{begin_date}->{month},
        begindate_day => $label->{begin_date}->{day},
        enddate_year => $label->{end_date}->{year},
        enddate_month => $label->{end_date}->{month},
        enddate_day => $label->{end_date}->{day},
        comment => $label->{comment},
        country => $label->{country_id},
        type => $label->{type_id},
        labelcode => $label->{label_code},
    );

    if ($label->{name}) {
        $row{name} = $names->{$label->{name}};
    }

    if ($label->{sort_name}) {
        $row{sortname} = $names->{$label->{sort_name}};
    }

    return { defined_hash(%row) };
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
