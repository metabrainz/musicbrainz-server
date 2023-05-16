package MusicBrainz::Server::Controller::EditNote;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;

use List::AllUtils qw( first_index );
use MusicBrainz::Server::Constants qw( $CONTACT_URL $EDITOR_MODBOT );
use MusicBrainz::Server::Data::Utils qw( load_everything_for_edits );
use MusicBrainz::Server::Validation qw( is_database_row_id );
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Controller';
with 'MusicBrainz::Server::Controller::Role::Load' => {
    model => 'EditNote',
    entity_name => 'edit_note',
};

sub base : Chained('/') PathPart('edit-note') CaptureArgs(0) { }

sub _load
{
    my ($self, $c, $edit_note_id) = @_;
    return unless is_database_row_id($edit_note_id);
    my $edit_note = $c->model('EditNote')->get_by_id($edit_note_id);
    $c->model('Editor')->load($edit_note);
    $c->model('EditNoteChange')->load_latest($edit_note);
    return $edit_note;
}

sub detach_if_cannot_change {
    my ($self, $c, $edit_note, $edit) = @_;

    my $is_own_note = $c->user && $c->user->id == $edit_note->{editor_id};
    my $is_admin = $c->user && $c->user->is_account_admin;

    unless ($is_own_note || $is_admin) {
        $c->stash(
            component_path  => 'user/UserMessage',
            component_props => {
                title    => l('Can’t change edit note'),
                message  => l('You can’t change other users’ edit notes.'),
            },
            current_view    => 'Node',
        );
        $c->detach;
    }

    if ($is_own_note && $c->user->is_adding_notes_disabled) {
        $c->stash(
            component_path  => 'user/UserMessage',
            component_props => {
                title    => l('Can’t change edit note'),
                message  => l(
                    'You’re currently not allowed to leave or change edit notes because an admin has revoked your privileges. If you haven’t already been contacted about why, please {uri|send us a message}.',
                    { uri => { href => 'https://metabrainz.org/contact', target => '_blank' } },
                ),
            },
            current_view    => 'Node',
        );
        $c->detach;
    }

    my $is_note_deleted = $edit_note->{latest_change} &&
                          $edit_note->{latest_change}->{status} eq 'deleted';

    if ($is_note_deleted && !$is_admin) {
        $c->stash(
            component_path  => 'user/UserMessage',
            component_props => {
                title    => l('Can’t change edit note'),
                message  => l('This note has already been removed.'),
            },
            current_view    => 'Node',
        );
        $c->detach;
    }

    my $all_edit_notes = $edit->{edit_notes};
    my $note_index = first_index {
        $_->id == $edit_note->id,
    } @$all_edit_notes;
    my $has_reply = 0;
    for (my $i = $note_index + 1; $i < @$all_edit_notes; $i++) {
        my $reply_editor = $all_edit_notes->[$i]->editor_id;
        if (($reply_editor != $edit_note->editor_id) &&
            ($reply_editor != $EDITOR_MODBOT)) {
            $has_reply = 1;
            last;
        }
    }

    if ($has_reply && !$is_admin) {
        $c->stash(
            component_path  => 'user/UserMessage',
            component_props => {
                title    => l('Can’t change edit note'),
                message  => l(
                    'You can’t change this note, since somebody else has already replied to it. If there’s an important reason why it should be changed (for example, it contains private data), please {contact_url|contact us}.',
                    {contact_url => $CONTACT_URL},
                ),
            },
            current_view    => 'Node',
        );
        $c->detach;
    }

    my $now = DateTime->now( time_zone => $edit_note->post_time->time_zone );
    my $note_age = $now - $edit_note->post_time;
    my $is_note_too_old = $note_age->{days} > 0;

    if ($is_note_too_old && !$is_admin) {
      $c->stash(
            component_path  => 'user/UserMessage',
            component_props => {
                title    => l('Can’t change edit note'),
                message  => l(
                    'You can’t change this note, since it was entered too long ago. If there’s an important reason why it should be changed (for example, it contains private data), please {contact_url|contact us}.',
                    {contact_url => $CONTACT_URL},
                ),
            },
            current_view    => 'Node',
      );
      $c->detach;
    }
}

sub delete : PathPart('delete') Chained('load') {
    my ($self, $c) = @_;

    my $form = $c->form( form => 'EditNoteDelete' );
    my $edit_note = $c->stash->{edit_note};
    my $edit_id = $edit_note->{edit_id};
    my $edit = $c->model('Edit')->get_by_id($edit_id);
    load_everything_for_edits($c, [ $edit ]);

    $self->detach_if_cannot_change($c, $edit_note, $edit);

    if ($c->form_posted_and_valid($form)) {
        if (!$form->field('cancel')->input) {
            $c->model('MB')->with_transaction(sub {
                $c->model('EditNote')->delete_content(
                    $edit_note->id,
                    $c->user->id,
                    $form->field('reason')->value,
                );
            });
        }
        $c->response->redirect(
            $c->uri_for_action('/edit/show', [ $edit_id ])
        );
        $c->detach;
    } else {
        $c->stash(
            component_path => 'edit/DeleteNote',
            component_props => {
                edit => $edit->TO_JSON,
                editNote => $edit_note->TO_JSON,
                form => $form->TO_JSON,
            },
            current_view => 'Node',
        );
    }
}

sub modify : PathPart('modify') Chained('load') {
    my ($self, $c) = @_;

    my $edit_note = $c->stash->{edit_note};
    my $form = $c->form( form => 'EditNoteModify',
                         init_object => { text => $edit_note->text });
    my $edit_id = $edit_note->{edit_id};
    my $edit = $c->model('Edit')->get_by_id($edit_id);
    load_everything_for_edits($c, [ $edit ]);

    $self->detach_if_cannot_change($c, $edit_note, $edit);

    if ($c->form_posted_and_valid($form)) {
        if ($form->field('cancel')->input) {
            $c->response->redirect(
                $c->uri_for_action('/edit/show', [ $edit_id ])
            );
            $c->detach;
        } else {
            my $new_note = $form->field('text')->value;
            if ($new_note eq $edit_note->text) {
                $form->field('text')->add_error(
                    l('You haven’t made any changes!')
                );
            } else {
                $c->model('MB')->with_transaction(sub {
                    $c->model('EditNote')->modify_content(
                        $edit_note->id,
                        $c->user->id,
                        $new_note,
                        $form->field('reason')->value,
                    );
                });
                $c->response->redirect(
                    $c->uri_for_action('/edit/show', [ $edit_id ])
                );
                $c->detach;
            }
        }
    }
    $c->stash(
        component_path => 'edit/ModifyNote',
        component_props => {
            edit => $edit->TO_JSON,
            editNote => $edit_note->TO_JSON,
            form => $form->TO_JSON,
        },
        current_view => 'Node',
    );
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
