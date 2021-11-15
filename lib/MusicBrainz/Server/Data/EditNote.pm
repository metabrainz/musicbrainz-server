package MusicBrainz::Server::Data::EditNote;
use Moose;
use namespace::autoclean;

use List::AllUtils qw( uniq );
use MusicBrainz::Server::Entity::EditNote;
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Data::Utils qw(
    placeholders
);
use MusicBrainz::Server::Constants qw( :vote $LIMIT_FOR_EDIT_LISTING );

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'edit_note';
}

sub _columns
{
    return 'id, editor, edit, text, post_time';
}

sub _column_mapping
{
    return {
        id => 'id',
        editor_id => 'editor',
        edit_id => 'edit',
        text => 'text',
        post_time => 'post_time',
    }
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::EditNote';
}

sub load_for_edits
{
    my ($self, @edits) = @_;
    my %id_to_edit = map { $_->id => $_ } @edits;
    my @ids = keys %id_to_edit or return;
    my $query = 'SELECT ' . $self->_columns .
                ' FROM ' . $self->_table .
                ' WHERE edit IN (' . placeholders(@ids) . ')' .
                ' ORDER BY post_time NULLS FIRST, id';
    $self->query_to_list($query, \@ids, sub {
        my ($model, $r) = @_;
        my $note = $model->_new_from_row($r);
        my $edit = $id_to_edit{ $r->{edit} };
        $note->edit($edit);
        $edit->add_edit_note($note);
        $note;
    });
}

sub insert
{
    my ($self, $edit_id, $note_hash) = @_;
    my $mapping = $self->_column_mapping;
    my %r = map {
        my $key = $mapping->{$_} || $_;
        $key => $note_hash->{$_};
    } keys %$note_hash;
    $r{edit} = $edit_id;
    $self->sql->auto_commit;
    $self->sql->insert_row('edit_note', \%r);
}

sub add_note
{
    my ($self, $edit_id, $note_hash) = @_;
    $self->insert($edit_id, $note_hash);

    my $email_data = MusicBrainz::Server::Email->new( c => $self->c );
    my $edit = $self->c->model('Edit')->get_by_id($edit_id) or die "Edit $edit_id does not exist!";
    $self->c->model('EditNote')->load_for_edits($edit);
    $self->c->model('Vote')->load_for_edits($edit);
    my $editors = $self->c->model('Editor')->get_by_ids($edit->editor_id,
        $note_hash->{editor_id},
        (map { $_->editor_id } @{ $edit->votes }),
        (map { $_->editor_id } @{ $edit->edit_notes }));
    $self->c->model('Editor')->load_preferences(values %$editors);

    # Inform the edit's author that a note was left, unless this is their own edit.
    if ($note_hash->{editor_id} != $edit->editor_id) {
        my $edit_author = $editors->{$edit->editor_id}->name;
        my $notes_updated_key = "edit_notes_received_last_updated:$edit_author";
        $self->c->store->set($notes_updated_key, time);
        # Expire the notification in 30 days.
        $self->c->store->expire($notes_updated_key, 60 * 60 * 24 * 30);
    }

    my @to_email = grep { $_ != $note_hash->{editor_id} }
        map { $_->id } grep { $_->preferences->email_on_notes }
        map { $editors->{$_->editor_id} }
            @{ $edit->edit_notes },
            (grep { my $editor = $_->editor_id;
                    !(grep { $editor == $_ } (53705, 326637, 295208)) || $_->vote != $VOTE_ABSTAIN
                  } @{ $edit->votes }),
            $edit;

    my $from = $editors->{ $note_hash->{editor_id} };
    for my $editor_id (uniq @to_email) {
        my $editor = $editors->{ $editor_id };
        $email_data->send_edit_note(
            from_editor => $from,
            editor => $editor,
            note_text => $note_hash->{text},
            edit_id => $edit_id,
            own_edit => $edit->editor_id == $editor->id);
    }
}

sub find_by_recipient {
    my ($self, $recipient_id, $limit, $offset) = @_;

    my $query = <<~"SQL";
        SELECT ${\($self->_columns)}
        FROM edit_note_recipient
        JOIN ${\($self->_table)} ON ${\($self->_table)}.id = edit_note_recipient.edit_note
        WHERE recipient = \$1
        ORDER BY post_time DESC NULLS LAST, edit DESC
        LIMIT $LIMIT_FOR_EDIT_LISTING
        SQL
    $self->query_to_list_limited(
        $query, [$recipient_id], $limit, $offset, undef,
        dollar_placeholders => 1,
    );
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
