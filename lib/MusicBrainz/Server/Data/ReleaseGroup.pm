package MusicBrainz::Server::Data::ReleaseGroup;

use Moose;
use MusicBrainz::Server::Entity::ReleaseGroup;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    generate_gid
    load_subobjects
    partial_date_from_row
    placeholders
    query_to_list_limited
);

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::AnnotationRole' => { type => 'release_group' };
with 'MusicBrainz::Server::Data::Editable' => { table => 'release_group' };
with 'MusicBrainz::Server::Data::RatingRole' => { type => 'release_group' };

sub _table
{
    return 'release_group rg JOIN release_name name ON rg.name=name.id';
}

sub _columns
{
    return 'rg.id, gid, type AS type_id, name.name,
            rg.artist_credit AS artist_credit_id,
            comment, editpending AS edits_pending';
}

sub _id_column
{
    return 'rg.id';
}

sub _gid_redirect_table
{
    return 'release_group_gid_redirect';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::ReleaseGroup';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'release_group', @objs);
}

sub find_by_artist
{
    my ($self, $artist_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . ",
                    rgm.firstreleasedate_year,
                    rgm.firstreleasedate_month,
                    rgm.firstreleasedate_day,
                    rgm.releasecount
                 FROM " . $self->_table . "
                    JOIN release_group_meta rgm
                        ON rgm.id = rg.id
                    JOIN artist_credit_name acn
                        ON acn.artist_credit = rg.artist_credit
                 WHERE acn.artist = ?
                 ORDER BY
                    rg.type,
                    rgm.firstreleasedate_year,
                    rgm.firstreleasedate_month,
                    rgm.firstreleasedate_day,
                    name.name
                 OFFSET ?";
    return query_to_list_limited(
        $self->c, $offset, $limit, sub {
            my $row = $_[0];
            my $rg = $self->_new_from_row($row);
            $rg->first_release_date(partial_date_from_row($row, 'firstreleasedate_'));
            $rg->release_count($row->{releasecount} || 0);
            return $rg;
        },
        $query, $artist_id, $offset || 0);
}

sub insert
{
    my ($self, @groups) = @_;
    my $sql = Sql->new($self->c->mb->dbh);
    my @created;
    my $release_data = MusicBrainz::Server::Data::Release->new(c => $self->c);
    my %names = $release_data->find_or_insert_names(map { $_->{name} } @groups);
    my $class = $self->_entity_class;
    for my $group (@groups)
    {
        my $row = $self->_hash_to_row($group, \%names);
        $row->{gid} = $group->{gid} || generate_gid();
        push @created, $class->new(
            id => $sql->InsertRow('release_group', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @groups > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $group_id, $update) = @_;
    my $sql = Sql->new($self->c->mb->dbh);
    my $release_data = MusicBrainz::Server::Data::Release->new(c => $self->c);
    my %names = $release_data->find_or_insert_names($update->{name});
    my $row = $self->_hash_to_row($update, \%names);
    $sql->Update('release_group', $row, { id => $group_id });
}

sub delete
{
    my ($self, @group_ids) = @_;
    $self->annotation->delete(@group_ids);
    $self->remove_gid_redirects(@group_ids);
    my $sql = Sql->new($self->c->mb->dbh);
    $sql->Do('DELETE FROM release_group WHERE id IN (' . placeholders(@group_ids) . ')', @group_ids);
    return;
}

sub merge
{
    my ($self, $old_id, $new_id) = @_;
    my $sql = Sql->new($self->c->dbh);
    $self->annotation->merge($old_id => $new_id);
    $self->update_gid_redirects($old_id => $new_id);
    $self->c->model('Relationship')->merge('release_group', $new_id, $old_id);
    $sql->Do('UPDATE release SET release_group = ? WHERE release_group = ?', $new_id, $old_id);
    my $old_gid = $sql->SelectSingleValue('DELETE FROM release_group WHERE id = ? RETURNING gid', $old_id);
    $self->add_gid_redirects($old_gid => $new_id);
}

sub _hash_to_row
{
    my ($self, $group, $names) = @_;
    my %row = (
        artist_credit => $group->{artist_credit},
        comment => $group->{comment},
        type => $group->{type_id},
    );

    if ($group->{name})
    {
        $row{name} = $names->{$group->{name}};
    }

    return { defined_hash(%row) };
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "release_group_meta", sub {
        my ($obj, $row) = @_;
        $obj->rating(int($row->{rating} * 20 + 0.5)) if defined $row->{rating};
        $obj->rating_count($row->{ratingcount}) if defined $row->{ratingcount};
        $obj->release_count($row->{releasecount});
        $obj->last_update_date($row->{lastupdate}) if defined $row->{lastupdate};
    }, @_);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::ReleaseGroup

=head1 METHODS

=head2 load (@releases)

Loads and sets release groups for the specified releases.

=head2 find_by_artist ($artist_id, $limit, [$offset])

Finds release groups by the specified artist, and returns an array containing
a reference to the array of release groups and the total number of found
release groups. The $limit parameter is used to limit the number of returned
release groups.

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
