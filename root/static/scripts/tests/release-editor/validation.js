/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import '../../release-editor/init.js';

import * as validation from '../../edit/validation.js';
import fields from '../../release-editor/fields.js';
import releaseEditor from '../../release-editor/viewModel.js';

function validationTest(name, callback) {
  test(name, function (t) {
    const loadMedia = fields.Release.prototype.loadMedia;
    fields.Release.prototype.loadMedia = () => undefined;

    callback(t);

    validation.errorFields([]);
    fields.Release.prototype.loadMedia = loadMedia;
  });
}

validationTest((
  'non-loaded mediums validate, even though they have no tracks (MBS-7222)'
), function (t) {
  t.plan(10);

  releaseEditor.action = 'edit';

  releaseEditor.releaseLoaded({
    mediums: [
      {id: 123, position: 1, tracks: []},
    ],
  });

  const release = releaseEditor.rootField.release();
  const medium = release.mediums()[0];

  t.ok(!medium.loaded(), 'medium is not loaded');
  t.ok(!medium.needsTracks(), "medium doesn't require tracks");
  t.ok(!medium.needsTrackArtists(), "medium doesn't lack track artists");
  t.ok(!medium.needsTrackTitles(), "medium doesn't lack track titles");
  t.ok(!medium.needsRecordings(), "medium doesn't require recordings");
  t.ok(!release.needsMediums(), "release doesn't need mediums");
  t.ok(!release.needsTracks(), "release doesn't need tracks");
  t.ok(!release.needsTrackArtists(), "release doesn't lack track artists");
  t.ok(!release.needsTrackTitles(), "release doesn't lack track titles");
  t.ok(!release.needsRecordings(), "release doesn't need recordings");
});

validationTest((
  'duplicate release countries are rejected, including null ones (MBS-7624)'
), function (t) {
  t.plan(5);

  releaseEditor.action = 'edit';

  releaseEditor.releaseLoaded({
    events: [
      {countryID: 123, date: {year: 1999}},
      {countryID: 123, date: {year: 2000}},
      {countryID: null, date: {year: 1999}},
      {countryID: null, date: {year: 2000}},
    ],
  });

  var release = releaseEditor.rootField.release();
  var events = release.events();

  t.ok(events[0].isDuplicate());
  t.ok(events[1].isDuplicate());
  t.ok(events[2].isDuplicate());
  t.ok(events[3].isDuplicate());
  t.ok(validation.errorsExist());
});

validationTest((
  'duplicate label/catalog number pairs are rejected (MBS-8137)'
), function (t) {
  t.plan(14);

  releaseEditor.action = 'edit';

  var label1 = {name: 'Foo', id: 123};
  var label2 = {name: 'Bar', id: 456};
  var label3 = {name: 'Foo', id: 789};

  releaseEditor.releaseLoaded({
    labels: [
      {label: label1, catalogNumber: 'ABC-123'},
      {label: label1, catalogNumber: 'ABC-123'},
      {label: label1, catalogNumber: 'ABC-456'},
      {label: label3, catalogNumber: 'ABC-123'},
      {label: {name: 'A'}, catalogNumber: 'ABC-456'},
      {label: {name: 'A'}, catalogNumber: 'ABC-456'},
      {label: {name: 'B'}, catalogNumber: 'ABC-456'},
      {label: null, catalogNumber: 'ABC-456'},
      {label: null, catalogNumber: 'ABC-456'},
      {label: label2, catalogNumber: null},
      {label: label2, catalogNumber: null},
      {label: null, catalogNumber: null},
      {label: null, catalogNumber: null},
    ],
  });

  var labels = releaseEditor.rootField.release().labels();

  t.ok(labels[0].isDuplicate(), 'Same label and catno is a dupe');
  t.ok(labels[1].isDuplicate(), 'Same label and catno is a dupe');
  t.ok(
    !labels[2].isDuplicate(),
    'Same label and different catno is not a dupe',
  );
  t.ok(
    !labels[3].isDuplicate(),
    'Different label with same label name and same catno is not a dupe',
  );
  t.ok(labels[4].isDuplicate(), 'Same label name and catno is a dupe');
  t.ok(labels[5].isDuplicate(), 'Same label name and catno is a dupe');
  t.ok(
    !labels[6].isDuplicate(),
    'Different label name and same catno is not a dupe',
  );
  t.ok(labels[7].isDuplicate(), 'No label and same catno is a dupe');
  t.ok(labels[8].isDuplicate(), 'No label and same catno is a dupe');
  t.ok(labels[9].isDuplicate(), 'Same label and no catno is a dupe');
  t.ok(labels[10].isDuplicate(), 'Same label and no catno is a dupe');

  t.ok(
    !labels[11].isDuplicate(),
    'No label and no catno does not trigger error',
  );
  t.ok(
    !labels[12].isDuplicate(),
    'No label and no catno does not trigger error',
  );

  t.ok(validation.errorsExist());
});
