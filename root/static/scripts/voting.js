/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import './common/MB/Control/EditList.js';

$('.edit-list').each(function () {
  const $container = $(this);
  const $toggleEditNote = $container.find('.edit-note-toggle');
  const $editNote = $container.find('.add-edit-note');
  const $editNoteField = $editNote.find('textarea');

  function addNote() {
    $toggleEditNote
      .text(lp('Remove note', 'interactive'))
      .unbind('click').click(deleteNote);
    $editNote.show();
    $editNoteField.focus();
  }

  function deleteNote() {
    $toggleEditNote
      .text(lp('Add note', 'interactive'))
      .unbind('click').click(addNote);
    $editNote.hide();
    $editNoteField.val('');
  }

  $toggleEditNote.click(addNote);
});
