package MusicBrainz::Server::Data::Genre;

use Moose;
use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    load_subobjects
);
use MusicBrainz::Server::Entity::Genre;

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'genre' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'genre' };

sub _type { 'genre' }

sub _columns {
    return 'genre.id, genre.gid, genre.name,
            genre.comment, genre.edits_pending, genre.last_updated';
}

sub _column_mapping {
    return {
        id => 'id',
        gid => 'gid',
        name => 'name',
        comment => 'comment',
        edits_pending => 'edits_pending',
        last_updated => 'last_updated',
    };
}

sub _id_column {
    return 'genre.id';
}

sub load {
    my ($self, @objs) = @_;
    load_subobjects($self, 'genre', @objs);
}

sub update {
    my ($self, $genre_id, $update) = @_;
    return unless %{ $update // {} };
    my $row = $self->_hash_to_row($update);
    $self->sql->update_row('genre', $row, { id => $genre_id });
}

sub can_delete { 1 }

sub delete {
    my ($self, $genre_id) = @_;

    $self->delete_returning_gids($genre_id);
    return;
}

sub _hash_to_row {
    my ($self, $genre) = @_;
    my $row = hash_to_row($genre, {
        map { $_ => $_ } qw( comment name )
    });

    return $row;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2019 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
