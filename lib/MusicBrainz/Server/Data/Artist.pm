package MusicBrainz::Server::Data::Artist;
use Moose;

use Carp;
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Entity::Artist;
use MusicBrainz::Server::Data::ArtistCredit;
use MusicBrainz::Server::Data::Edit;
use MusicBrainz::Server::Data::Utils qw(
    defined_hash
    hash_to_row
    add_partial_date_to_row
    generate_gid
    partial_date_from_row
    placeholders
    load_subobjects
    query_to_list_limited
);

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::AnnotationRole' => { type => 'artist' };
with 'MusicBrainz::Server::Data::AliasRole' => { type => 'artist' };
with 'MusicBrainz::Server::Data::NameRole' => { name_table => 'artist_name' };
with 'MusicBrainz::Server::Data::CoreEntityCache' => { prefix => 'artist' };
with 'MusicBrainz::Server::Data::Editable' => { table => 'artist' };
with 'MusicBrainz::Server::Data::RatingRole' => { type => 'artist' };
with 'MusicBrainz::Server::Data::TagRole' => { type => 'artist' };
with 'MusicBrainz::Server::Data::SubscriptionRole' => {
    table => 'editor_subscribe_artist',
    column => 'artist'
};
with 'MusicBrainz::Server::Data::BrowseRole';

sub _table
{
    return 'artist ' .
           'JOIN artist_name name ON artist.name=name.id ' .
           'JOIN artist_name sortname ON artist.sortname=sortname.id';
}

sub _columns
{
    return 'artist.id, gid, name.name, sortname.name AS sortname, ' .
           'type, country, gender, editpending, ' .
           'begindate_year, begindate_month, begindate_day, ' .
           'enddate_year, enddate_month, enddate_day, comment';
}

sub _id_column
{
    return 'artist.id';
}

sub _gid_redirect_table
{
    return 'artist_gid_redirect';
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
        gender_id => 'gender',
        begin_date => sub { partial_date_from_row(shift, shift() . 'begindate_') },
        end_date => sub { partial_date_from_row(shift, shift() . 'enddate_') },
        edits_pending => 'editpending',
        comment => 'comment',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::Artist';
}

sub find_by_subscribed_editor
{
    my ($self, $editor_id, $limit, $offset) = @_;
    my $query = "SELECT " . $self->_columns . "
                 FROM " . $self->_table . "
                    JOIN editor_subscribe_artist s ON artist.id = s.artist
                 WHERE s.editor = ?
                 ORDER BY name.name, artist.id
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row(@_) },
        $query, $editor_id, $offset || 0);
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'artist', @objs);
}

sub insert
{
    my ($self, @artists) = @_;
    my $sql = Sql->new($self->c->mb->dbh);
    my %names = $self->find_or_insert_names(map { $_->{name}, $_->{sort_name} } @artists);
    my $class = $self->_entity_class;
    my @created;
    for my $artist (@artists)
    {
        my $row = $self->_hash_to_row($artist, \%names);
        $row->{gid} = $artist->{gid} || generate_gid();

        push @created, $class->new(
            id => $sql->insert_row('artist', $row, 'id'),
            gid => $row->{gid}
        );
    }
    return @artists > 1 ? @created : $created[0];
}

sub update
{
    my ($self, $artist_id, $update) = @_;
    croak '$artist_id must be present and > 0' unless $artist_id > 0;
    my $sql = Sql->new($self->c->mb->dbh);
    my %names = $self->find_or_insert_names($update->{name}, $update->{sort_name});
    my $row = $self->_hash_to_row($update, \%names);
    $sql->update_row('artist', $row, { id => $artist_id });
}

sub delete
{
    my ($self, @artist_ids) = @_;
    my $can_delete = 1;
    # XXX Checks to see if artist is in use (core entities that depend on this artist)
    return unless $can_delete;

    $self->c->model('Relationship')->delete_entities('artist', @artist_ids);
    $self->annotation->delete(@artist_ids);
    $self->alias->delete(@artist_ids);
    $self->tags->delete(@artist_ids);
    $self->rating->delete(@artist_ids);
    $self->subscription->delete(@artist_ids);
    $self->remove_gid_redirects(@artist_ids);
    my $query = 'DELETE FROM artist WHERE id IN (' . placeholders(@artist_ids) . ')';
    my $sql = Sql->new($self->c->mb->dbh);
    $sql->do($query, @artist_ids);
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
        country => 'country_id',
        type    => 'type_id',
        gender  => 'gender_id',
        comment => 'comment',
    });

    if (exists $values->{begin_date}) {
        add_partial_date_to_row($row, $values->{begin_date}, 'begindate');
    }

    if (exists $values->{end_date}) {
        add_partial_date_to_row($row, $values->{end_date}, 'enddate');
    }

    if (exists $values->{name}) {
        $row->{name} = $names->{ $values->{name} };
    }

    if (exists $values->{sort_name}) {
        $row->{sortname} = $names->{ $values->{sort_name} };
    }

    return $row;
}

sub load_meta
{
    my $self = shift;
    MusicBrainz::Server::Data::Utils::load_meta($self->c, "artist_meta", sub {
        my ($obj, $row) = @_;
        $obj->rating($row->{rating}) if defined $row->{rating};
        $obj->rating_count($row->{ratingcount}) if defined $row->{ratingcount};
        $obj->last_update_date($row->{lastupdate}) if defined $row->{lastupdate};
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
