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

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Name' => { name_table => 'label_name' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache' => { prefix => 'label' };
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'label' };
with 'MusicBrainz::Server::Data::Role::Rating' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Tag' => { type => 'label' };
with 'MusicBrainz::Server::Data::Role::Subscription' => {
    table => 'editor_subscribe_label',
    column => 'label'
};
with 'MusicBrainz::Server::Data::Role::Browse';
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'label' };

sub _table
{
    return 'label ' .
           'JOIN label_name name ON label.name=name.id ' .
           'JOIN label_name sort_name ON label.sort_name=sort_name.id';
}

sub _columns
{
    return 'label.id, gid, name.name, sort_name.name AS sort_name, ' .
           'type, country, edits_pending, label_code, label.ipi_code, ' .
           'begin_date_year, begin_date_month, begin_date_day, ' .
           'end_date_year, end_date_month, end_date_day, comment, label.last_updated';
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
        sort_name => 'sort_name',
        type_id => 'type',
        country_id => 'country',
        label_code => 'label_code',
        begin_date => sub { partial_date_from_row(shift, shift() . 'begin_date_') },
        end_date => sub { partial_date_from_row(shift, shift() . 'end_date_') },
        edits_pending => 'edits_pending',
        comment => 'comment',
        ipi_code => 'ipi_code',
        last_updated => 'last_updated',
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

sub find_by_release
{
    my ($self, $release_id, $limit, $offset) = @_;

    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                     JOIN release_label ON release_label.label = label.id
                 WHERE release_label.release = ?
                 ORDER BY musicbrainz_collate(name.name)
                 OFFSET ?";

    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $release_id, $offset || 0);
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
        begin_date_year => $label->{begin_date}->{year},
        begin_date_month => $label->{begin_date}->{month},
        begin_date_day => $label->{begin_date}->{day},
        end_date_year => $label->{end_date}->{year},
        end_date_month => $label->{end_date}->{month},
        end_date_day => $label->{end_date}->{day},
        comment => $label->{comment},
        country => $label->{country_id},
        type => $label->{type_id},
        label_code => $label->{label_code},
        ipi_code => $label->{ipi_code},
    );

    if ($label->{name}) {
        $row{name} = $names->{$label->{name}};
    }

    if ($label->{sort_name}) {
        $row{sort_name} = $names->{$label->{sort_name}};
    }

    return { defined_hash(%row) };
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "label_meta", sub {
        my ($obj, $row) = @_;
        $obj->rating($row->{rating}) if defined $row->{rating};
        $obj->rating_count($row->{rating_count}) if defined $row->{rating_count};
    }, @_);
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
