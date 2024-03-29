/*
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';

import MB from '../../MB.js';

MB.Control.EditSummary = function (container) {
  var self = {};

  const $container = $(container);
  const $toggleEditNote = $container.find('.edit-note-toggle');
  const $editNote = $container.find('.add-edit-note');
  const $editNoteField = $editNote.find('textarea');

  self.addNote = function () {
    $toggleEditNote
      .text(lp('Remove note', 'interactive'))
      .unbind('click').click(self.deleteNote);
    $editNote.show();
    $editNoteField.focus();
  };

  self.deleteNote = function () {
    $toggleEditNote
      .text(lp('Add note', 'interactive'))
      .unbind('click').click(self.addNote);
    $editNote.hide();
    $editNoteField.val('');
  };

  self.initialize = function () {
    $toggleEditNote.click(self.addNote);
  };

  self.initialize();
  return self;
};
