package MusicBrainz::Server::Data::ReleaseLabel;
use Moose;
use Method::Signatures::Simple;

use MusicBrainz::Server::Entity::ReleaseLabel;
use MusicBrainz::Server::Data::Release;
use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    query_to_list
    query_to_list_limited
);
use MusicBrainz::Schema qw( schema );

use aliased 'Fey::Literal::Function';

extends 'MusicBrainz::Server::Data::FeyEntity';

method _build_table  { schema->table('release_label') }
method _entity_class { 'MusicBrainz::Server::Entity::ReleaseLabel' }

method _column_mapping
{
    return {
        id             => 'id',
        release_id     => 'release',
        label_id       => 'label',
        catalog_number => 'catno',
    };
}

method load (@releases)
{
    my %id_to_release = map { $_->id => $_ } @releases;
    my @ids = keys %id_to_release;
    return unless @ids; # nothing to do

    my $query = $self->_select
        ->where($self->table->column('release'), 'IN', @ids)
        ->order_by($self->table->column('release'),
                   $self->table->column('catno'));

    my @labels = query_to_list($self->c->dbh, sub { $self->_new_from_row(@_) },
                               $query->sql($self->c->dbh), $query->bind_params);

    foreach my $label (@labels) {
        $id_to_release{$label->release_id}->add_label($label);
    }
}

method find_by_label ($label_id, $limit, $offset)
{
    my $release = $self->c->model('Release');
    my $query = $release->_select
        ->select(grep { $_->name ne 'id' } $self->table->columns)
        ->from($self->table, $release->table)
        ->where($self->table->column('label'), '=', $label_id)
        ->order_by(
            (map { $release->table->column($_) } qw( date_year date_month date_day )),
            $self->table->column('catno'),
            Function->new('musicbrainz_collate', $release->name_columns->{name}))
        ->limit(undef, $offset || 0);

    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub {
            my $rl = $self->_new_from_row(@_);
            $rl->release(MusicBrainz::Server::Data::Release->_new_from_row(@_));
            return $rl;
        },
        $query->sql($self->c->dbh), $query->bind_params);
}

method merge_labels ($new_id, @old_ids)
{
    my $query = Fey::SQL->new_update
        ->update($self->table)
        ->set($self->table->column('label'), $new_id)
        ->where($self->table->column('label'), 'IN', @old_ids);

    $self->sql->do($query->sql($self->c->dbh), $query->bind_params);
}

method merge_releases ($new_id, @old_ids)
{
    my $query = Fey::SQL->new_update
        ->update($self->table)
        ->set($self->table->column('release'), $new_id)
        ->where($self->table->column('release'), 'IN', @old_ids);

    $self->sql->do($query->sql($self->c->dbh), $query->bind_params);
}

method _hash_to_row ($hash)
{
    return hash_to_row($hash, {
        catno => 'catalog_number',
        label => 'label_id',
    });
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::ReleaseLabel

=head1 METHODS

=head2 loads (@releases)

Loads and sets labels for the specified releases. The data can be then
accessed using $release->labels.

=head2 find_by_label ($release_group_id, $limit, [$offset])

Finds releases by the specified label, and returns an array containing
a reference to the array of ReleaseLabel instances and the total number
of found releases. The returned ReleaseLabel objects will also have releases
loaded. The $limit parameter is used to limit the number of returned releass.

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
