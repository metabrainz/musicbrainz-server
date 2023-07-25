package MusicBrainz::Server::Controller::EditNote;
use Moose;
use MooseX::MethodAttributes;
use namespace::autoclean;

use DateTime;
use List::AllUtils qw( first_index );
use MusicBrainz::Server::Constants qw( $CONTACT_URL $EDITOR_MODBOT );
use MusicBrainz::Server::ControllerUtils::JSON qw( serialize_pager );
use MusicBrainz::Server::Data::Utils qw( load_everything_for_edits );
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use MusicBrainz::Server::Validation qw( is_database_row_id );
use MusicBrainz::Server::Translation qw( l );
use utf8;

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
    my $edit_note = $c->model('EditNote')->get_by_id($edit_note_id)
        or $c->detach(
            '/error_404',
            [ "Found no edit note with ID “$edit_note_id”." ],
        );

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
    my $is_note_too_old = $edit_note->post_time->clone->add(days => 1) < $now;

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

sub edit_note_change : PathPart('change') Chained('load') Args(1) RequireAuth(account_admin)
{
    my ($self, $c, $change_id) = @_;

    if (!is_database_row_id($change_id)) {
        $c->stash(
            message => 'The note change ID must be a positive integer'
        );
        $c->detach('/error_400')
    }

    my $note_change = $c->model('EditNoteChange')->get_by_id($change_id)
        or $c->detach(
            '/error_404',
            [ "Found no note change with ID “$change_id”." ],
        );

    my $edit_note = $c->stash->{edit_note};
    my $edit_id = $edit_note->{edit_id};
    my $edit_note_id = $edit_note->{id};
    my $note_url = "/edit/$edit_id#note-$edit_id-$edit_note_id";

    if ($note_change->edit_note_id != $edit_note_id) {
        $c->stash(
            message =>
                "The note change with ID “$change_id” is not associated with this note.",
        );
        $c->detach('/error_400')
    }

    $c->model('Editor')->load($note_change);

    my %props = (
        change => $note_change->TO_JSON,
        noteUrl => $note_url,
    );

    $c->stash(
        component_path => 'edit_note/EditNoteChange',
        component_props => \%props,
        current_view => 'Node',
    );
}

sub edit_note_history : PathPart('changes') Chained('load') RequireAuth(account_admin)
{
    my ($self, $c) = @_;

    my $edit_note = $c->stash->{edit_note};
    my $edit_id = $edit_note->{edit_id};
    my $edit_note_id = $edit_note->{id};
    my $note_url = "/edit/$edit_id#note-$edit_id-$edit_note_id";

    my $note_changes = $self->_load_paged(
        $c, sub {
            $c->model('EditNoteChange')->get_history($edit_note->id);
        }
    );

    $c->model('Editor')->load(@$note_changes);
    my %props = (
        changes => to_json_array($note_changes),
        noteUrl => $note_url,
        pager => serialize_pager($c->stash->{pager}),
    );

    $c->stash(
        component_path => 'edit_note/EditNoteHistory',
        component_props => \%props,
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
