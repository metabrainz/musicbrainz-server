/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import test from 'tape';

import MB from '../common/MB';
import CoverArt from '../edit/MB/CoverArt';

MB.cover_art_types_json = [
  {id: 'image/jpeg', l_name: 'jpg'},
  {id: 'image/png', l_name: 'png'},
];

function base64ToBlob(data, mime) {
  const byteString = window.atob(data);

  const ia = new Uint8Array(byteString.length);
  for (let i = 0; i < byteString.length; i++) {
    ia[i] = byteString.charCodeAt(i);
  }

  return new window.Blob([ia], {type: mime});
}

const testFiles = {
  '1x1.jpg': '/9j/4AAQSkZJRgABAQIAJgAmAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQE' +
      'BAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/' +
      '2wBDAQMDAwQDBAgEBAgQCwkLEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQ' +
      'EBAQEBAQEBAQEBAQEBAQEBAQEBAQEBD/wAARCAABAAEDASIAAhEBAxEB/8QA' +
      'FQABAQAAAAAAAAAAAAAAAAAAAAn/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QA' +
      'FAEBAAAAAAAAAAAAAAAAAAAAAP/EABQRAQAAAAAAAAAAAAAAAAAAAAD/2gAM' +
      'AwEAAhEDEQA/AKpgA//Z',
  '1x1.png': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQAAAAA3bvkkAAAABGdBTUEAALGP' +
      'C/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUw' +
      'AADqYAAAOpgAABdwnLpRPAAAAAJiS0dEAAHdihOkAAAACXBIWXMAAA7EAAAO' +
      'xAGVKw4bAAAACklEQVQI12NoAAAAggCB3UNq9AAAACV0RVh0ZGF0ZTpjcmVh' +
      'dGUAMjAxMy0wNi0yOFQxNjoyMTo1OSswMjowMITHmXwAAAAldEVYdGRhdGU6' +
      'bW9kaWZ5ADIwMTMtMDYtMjhUMTY6MjE6NDkrMDI6MDA5MCFeAAAAAElFTkSu' +
      'QmCC',
  '1x1.gif': 'R0lGODlhAQABAPAAAP///wAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==',
  'not an image.txt': 'bm90IGFuIGltYWdlCg==',
};

function mimeTypeTest(t, filename, expected, expectedState) {
  const input = base64ToBlob(testFiles[filename]);
  const promise = CoverArt.validate_file(input);

  promise.done(function (mimeType) {
    t.equal(mimeType, expected, filename);
  });

  promise.fail(function (err) {
    t.equal(err, expected, filename);
  });

  promise.always(function () {
    t.equal(promise.state(), expectedState, ' ... ' + expectedState);
  });

  return promise;
}

function createFakeFile(name) {
  const fakefile = base64ToBlob(testFiles[name]);
  fakefile.name = name;
  return fakefile;
}

test('multifile/ajax upload mime type', function (t) {
  if (typeof window.Blob !== 'function') {
    console.log('# Blob constructor not available, skipping test: multifile/ajax upload mime type');
    t.end();
    return;
  }

  /* each mimeTypeTest() call runs two tests, so expect 8. */
  t.plan(8);

  mimeTypeTest(t, '1x1.jpg', 'image/jpeg', 'resolved');
  mimeTypeTest(t, '1x1.png', 'image/png', 'resolved');
  mimeTypeTest(t, '1x1.gif', 'image/gif', 'resolved');
  mimeTypeTest(
    t,
    'not an image.txt',
    'unrecognized image format',
    'rejected',
  );
});

test('cover art types', function (t) {
  t.plan(4);

  const types = CoverArt.cover_art_types();
  t.equal(types().length, 2, 'two types in observableArray');
  t.equal(types()[0].id, 'image/jpeg', 'first type is image/jpeg');
  t.equal(types()[0].checked(), false, 'jpg not checked');
  t.equal(types()[1].checked(), false, 'png not checked');
});

test('upload queue', function (t) {
  if (typeof window.Blob !== 'function') {
    console.log('# Blob constructor not available, skipping test: multifile/ajax upload mime type');
    t.end();
    return;
  }

  t.plan(8);

  const upvm = new CoverArt.UploadProcessViewModel();
  ko.applyBindings(upvm);

  t.equal(upvm.files_to_upload().length, 0, 'zero files in upload queue');

  const gifFile = upvm.addFile(createFakeFile('1x1.gif'));
  const jpgFile = upvm.addFile(createFakeFile('1x1.jpg'));
  const pngFile = upvm.addFile(createFakeFile('1x1.png'));
  const txtFile = upvm.addFile(createFakeFile('not an image.txt'));

  t.equal(upvm.files_to_upload().length, 4, 'four files in upload queue');

  upvm.moveFile(txtFile, 1);
  t.equal(
    upvm.files_to_upload()[3].name,
    txtFile.name,
    "moving last file to the end doesn't move it",
  );
  upvm.moveFile(txtFile, -1);
  t.equal(
    upvm.files_to_upload()[2].name,
    txtFile.name,
    'last file moved to third position',
  );
  t.equal(
    upvm.files_to_upload()[3].name,
    pngFile.name,
    'file in third position is now at the end',
  );

  upvm.moveFile(gifFile, -1);
  t.equal(
    upvm.files_to_upload()[0].name,
    gifFile.name,
    "moving first file to the start doesn't move it",
  );
  upvm.moveFile(gifFile, 1);
  t.equal(
    upvm.files_to_upload()[1].name,
    gifFile.name,
    'first file moved to second position',
  );
  t.equal(
    upvm.files_to_upload()[0].name,
    jpgFile.name,
    'file in second position is now at the start',
  );
});
