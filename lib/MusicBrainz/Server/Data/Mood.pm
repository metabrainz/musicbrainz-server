package MusicBrainz::Server::Data::Mood;

use Moose;
use MusicBrainz::Server::Data::Utils qw(
    hash_to_row
    load_subobjects
);
use MusicBrainz::Server::Entity::Mood;

extends 'MusicBrainz::Server::Data::CoreEntity';
with 'MusicBrainz::Server::Data::Role::Annotation' => { type => 'mood' };
with 'MusicBrainz::Server::Data::Role::Alias' => { type => 'mood' };
with 'MusicBrainz::Server::Data::Role::CoreEntityCache';
with 'MusicBrainz::Server::Data::Role::Editable' => { table => 'mood' };
with 'MusicBrainz::Server::Data::Role::LinksToEdit' => { table => 'mood' };
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::DeleteAndLog' => { type => 'mood' };

sub _type { 'mood' }

sub _columns {
    return 'mood.id, mood.gid, mood.name,
            mood.comment, mood.edits_pending, mood.last_updated';
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
    return 'mood.id';
}

sub load {
    my ($self, @objs) = @_;
    load_subobjects($self, 'mood', @objs);
}

sub update {
    my ($self, $mood_id, $update) = @_;
    return unless %{ $update // {} };
    my $row = $self->_hash_to_row($update);
    $self->sql->update_row('mood', $row, { id => $mood_id });
}

sub can_delete { 1 }

sub delete {
    my ($self, $mood_id) = @_;

    $self->c->model('Relationship')->delete_entities('mood', $mood_id);
    $self->annotation->delete($mood_id);
    $self->alias->delete_entities($mood_id);
    $self->delete_returning_gids($mood_id);
    return;
}

sub _hash_to_row {
    my ($self, $mood) = @_;
    my $row = hash_to_row($mood, {
        map { $_ => $_ } qw( comment name )
    });

    return $row;
}

sub get_all_limited {
    my ($self, $limit, $offset) = @_;

    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' ORDER BY name COLLATE musicbrainz';

    $self->query_to_list_limited($query, [], $limit, $offset);
}

sub get_all_names {
    my ($self) = @_;

    $self->sql->select_single_column_array(<<~'SQL');
        SELECT name FROM mood
        ORDER BY name COLLATE musicbrainz ASC
        SQL
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
