/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2013 MetaBrainz Foundation

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*/

MB.tests.CoverArt = (MB.tests.CoverArt) ? MB.tests.CoverArt : {};

MB.tests.CoverArt.base64_to_blob = function (data, mime) {
    var byteString = window.atob (data);

    var ia = new Uint8Array (byteString.length);
    for (var i = 0; i < byteString.length; i++) {
        ia[i] = byteString.charCodeAt(i);
    }

    return new Blob([ia], { type: mime });
}

MB.tests.CoverArt.iframe = function() {
    QUnit.module('cover art, iframe upload');
    QUnit.test('mime type', function() {

        var newdoc = $('<iframe>').appendTo ('body').contents ()[0];
        var input = newdoc.createElement ('input');
        newdoc.body.appendChild (input);
        input.id = 'file';

        input.value = 'filename.with.dots.jpg';
        equal (MB.CoverArt.get_image_mime_type (), 'image/jpeg', input.value);

        input.value = 'ALL CAPS AND SOME SPACES.PNG';
        equal (MB.CoverArt.get_image_mime_type (), 'image/png', input.value);

        input.value = 'is this animated?.gif';
        equal (MB.CoverArt.get_image_mime_type (), 'image/gif', input.value);

        input.value = 'linux-3.10-rc7.tar.xz';
        equal (MB.CoverArt.get_image_mime_type (), null, input.value);

        $('iframe').remove ();
    });
};

MB.tests.CoverArt.multifile = function() {
    QUnit.module('cover art, multifile/ajax upload');

    MB.cover_art_types_json = [
        { id: 'image/jpeg', l_name: 'jpg' },
        { id: 'image/png', l_name: 'png' }
    ];

    var test_files = {
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
        'not an image.txt': 'bm90IGFuIGltYWdlCg=='
    };

    QUnit.asyncTest('mime type', function() {
        if (typeof Blob !== 'function')
        {
            console.log ('# Blob constructor not available, skip test:',
                         QUnit.config.current.testName);
            expect (0);
            start ();
            return;
        }

        var mime_type_test = function (filename, expected, expected_state) {
            var input = MB.tests.CoverArt.base64_to_blob (test_files[filename]);
            var promise = MB.CoverArt.validate_file (input);

            promise.done (function (mime_type) {
                equal (mime_type, expected, filename);
            });

            promise.fail (function (err) {
                equal (err, expected, filename);
            });

            promise.always (function () {
                equal (promise.state (), expected_state, ' ... ' + expected_state);
            });

        };

        /* each mime_type_test() call runs two tests, so expect 8. */
        expect (8);
        mime_type_test ('1x1.jpg', 'image/jpeg', 'resolved');
        mime_type_test ('1x1.png', 'image/png', 'resolved');
        mime_type_test ('1x1.gif', 'image/gif', 'resolved');
        mime_type_test ('not an image.txt', 'unrecognized image format', 'rejected');

        start ();
    });

    QUnit.test('cover art types', function() {

        var types = MB.CoverArt.cover_art_types ();
        equal (types ().length, 2, 'two types in observableArray');
        equal (types ()[0].id, 'image/jpeg', 'first type is image/jpeg');
        equal (types ()[0].checked (), false, 'jpg not checked');
        equal (types ()[1].checked (), false, 'png not checked');
    });

    var create_fake_file = function (name) {
        var fakefile = MB.tests.CoverArt.base64_to_blob (test_files[name]);

        fakefile.name = name;
        return fakefile;
    };

    QUnit.test('upload queue', function() {
        if (typeof Blob !== 'function')
        {
            console.log ('# Blob constructor not available, skip test:',
                         QUnit.config.current.testName);
            expect (0);
            return;
        }

        var upvm = new MB.CoverArt.UploadProcessViewModel ();
        ko.applyBindings (upvm);

        equal (upvm.files_to_upload ().length, 0, 'zero files in upload queue');

        var gif_file = upvm.addFile (create_fake_file ('1x1.gif'));
        var jpg_file = upvm.addFile (create_fake_file ('1x1.jpg'));
        var png_file = upvm.addFile (create_fake_file ('1x1.png'));
        var txt_file = upvm.addFile (create_fake_file ('not an image.txt'));

        equal (upvm.files_to_upload ().length, 4, 'four files in upload queue');

        upvm.moveFile (txt_file, 1);
        equal (upvm.files_to_upload ()[3].name, txt_file.name, "moving last file to the end doesn't move it")
        upvm.moveFile (txt_file, -1);
        equal (upvm.files_to_upload ()[2].name, txt_file.name, 'last file moved to third position')
        equal (upvm.files_to_upload ()[3].name, png_file.name, 'file in third position is now at the end')

        upvm.moveFile (gif_file, -1);
        equal (upvm.files_to_upload ()[0].name, gif_file.name, "moving first file to the start doesn't move it")
        upvm.moveFile (gif_file, 1);
        equal (upvm.files_to_upload ()[1].name, gif_file.name, 'first file moved to second position')
        equal (upvm.files_to_upload ()[0].name, jpg_file.name, 'file in second position is now at the start')
    });

};


MB.tests.CoverArt.Run = function() {
    MB.tests.CoverArt.iframe ();
    MB.tests.CoverArt.multifile ();
};
