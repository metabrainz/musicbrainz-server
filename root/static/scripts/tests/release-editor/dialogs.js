/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import $ from 'jquery';
import test from 'tape';

import '../../../lib/jquery-ui';

import {
  addMediumDialog,
  mediumSearchTab,
  trackParserDialog,
} from '../../release-editor/dialogs';
import edits from '../../release-editor/edits';
import fields from '../../release-editor/fields';
import trackParser from '../../release-editor/trackParser';
import releaseEditor from '../../release-editor/viewModel';

import * as common from './common';

import '../../release-editor/init';

$.ui.dialog.prototype.options.appendTo = '#fixture';

function dialogTest(name, callback) {
  test(name, function (t) {
    var release = common.setupReleaseAdd();

    trackParser.options = {
      hasTrackNumbers: true,
      hasVinylNumbers: false,
      hasTrackArtists: false,
      useTrackNumbers: true,
      useTrackArtists: true,
      useTrackNames: true,
      useTrackLengths: true,
    };

    var $fixture = $('<div>')
      .attr('id', 'fixture')
      .appendTo('body')
      .append(
        $('<div>').attr('id', 'add-medium-dialog').hide(),
        $('<div>').attr('id', 'track-parser-dialog').hide(),
      );

    releaseEditor.activeTabID('#information');

    callback(t, release);

    $fixture.remove();
  });
}

dialogTest((
  'adding an empty medium via the add-medium dialog is allowed (MBS-7221)'
), function (t, release) {
  t.plan(3);

  var mediums = release.mediums;

  t.ok(!mediums()[0].hasTracks(), 'first medium is empty');

  trackParserDialog.open(mediums()[0]);
  trackParserDialog.toBeParsed('1. ~fooo~ (1:23)\n');
  trackParserDialog.parse();

  t.ok(
    mediums()[0].hasTracks(),
    'first medium has tracks after using track parser',
  );

  addMediumDialog.open();
  addMediumDialog.currentTab(trackParserDialog);
  addMediumDialog.trackParser.toBeParsed('\n\t\n');
  addMediumDialog.addMedium();

  t.ok(!mediums()[1].hasTracks(), 'new empty medium was added');
});

dialogTest((
  'switching to the tracklist tab opens the add-medium dialog if there’s only one empty medium'
), function (t, release) {
  t.plan(3);

  releaseEditor.activeTabID('#tracklist');
  releaseEditor.autoOpenTheAddMediumDialog(release);

  var uiDialog = $(addMediumDialog.element).data('ui-dialog');

  t.ok(
    uiDialog.isOpen(),
    'add-medium dialog is open after switching to the tracklist tab',
  );

  releaseEditor.activeTabID('#information');
  releaseEditor.autoOpenTheAddMediumDialog(release);

  t.ok(
    !uiDialog.isOpen(),
    'add-medium dialog is closed after switching back to the information tab',
  );

  release.mediums()[0].tracks.push(
    new fields.Track({name: '~fooo~', position: 1, length: 12345}),
  );

  releaseEditor.activeTabID('#information');
  releaseEditor.autoOpenTheAddMediumDialog(release);

  t.ok(
    !uiDialog.isOpen(),
    'add-medium dialog remains closed after switching to the tracklist tab with a non-empty medium',
  );
});

dialogTest((
  'clearing the tracks of an existing medium via the track parser doesn’t cause the add-medium dialog to open'
), function (t, release) {
  t.plan(3);

  var medium = release.mediums()[0];

  medium.tracks.push(
    new fields.Track({name: '~fooo~', position: 1, length: 12345}),
  );

  t.ok(medium.hasTracks(), 'medium has tracks');

  releaseEditor.activeTabID('#tracklist');
  trackParserDialog.open(medium);
  trackParserDialog.toBeParsed('');
  trackParserDialog.parse();
  releaseEditor.autoOpenTheAddMediumDialog(release);

  t.ok(!medium.hasTracks(), 'medium does not have tracks');

  var uiDialog = $(addMediumDialog.element).data('ui-dialog');
  t.ok(!uiDialog, 'add-medium dialog is not open');
});

dialogTest((
  'adding a new medium does not cause reorder edits (MBS-7412)'
), function (t, release) {
  t.plan(1);

  releaseEditor.rootField.release(release);

  const testMediumCopy = {...common.testMedium, position: 1};
  delete testMediumCopy.id;

  release.mediums([new fields.Medium(testMediumCopy, release)]);
  addMediumDialog.open();
  addMediumDialog.currentTab(mediumSearchTab);
  mediumSearchTab.result({position: 1, tracks: [{name: 'foo'}]});
  addMediumDialog.addMedium();
  common.createMediums(release);

  t.equal(
    edits.mediumReorder(release).length,
    0,
    'mediums are not reordered',
  );
});
