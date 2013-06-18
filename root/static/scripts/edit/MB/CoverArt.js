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


MB.CoverArt = {};

MB.CoverArt.lastCheck;

MB.CoverArt.get_image_mime_type = function () {
    var filename = $('iframe').contents ().find ('#file').val ();
    var mime_type = null;

    if (filename.match(/\.j(peg|pg|pe|fif|if)$/i))
    {
        mime_type = "image/jpeg";
    }
    else if (filename.match(/\.png$/i))
    {
        mime_type = "image/png";
    }
    else if (filename.match(/\.gif$/i))
    {
        mime_type = "image/gif";
    }

    return mime_type;
};

MB.CoverArt.image_error = function ($img, image) {
    if ($img.attr ("src") !== image.image)
    {
        $img.attr ("src", image.image)
    }
    else
    {
        /* image doesn't exist at all, perhaps it was removed
           between requesting the index and loading the image.
           FIXME: start over if this happens?  obviously the
           data in the index is incorrect. */
        $img.attr ("src", "/static/images/image404-125.png")
    }
};

MB.CoverArt.image_position = function () {
    var $pos = $('#id-add-cover-art\\.position');
    var $editimage = $('div.editimage');

    $('div.editimage button.left').bind ('click.mb', function (event) {
        var $prev = $editimage.prev ();
        if ($prev.length)
        {
            $editimage.insertBefore ($prev);
            $pos.val (parseInt ($pos.val (), 10) - 1);
        }

        event.preventDefault ();
        return false;
    });

    $('div.editimage button.right').bind ('click.mb', function (event) {
        var $next = $editimage.next ();
        if ($next.length)
        {
            $editimage.insertAfter ($next);
            $pos.val (parseInt ($pos.val (), 10) + 1);
        }

        event.preventDefault ();
        return false;
    });
};

MB.CoverArt.reorder_position = function () {
    var swap_values = function ($a, $b) {
        var otherval = $a.val ();
        $a.val ($b.val ());
        $b.val (otherval);
    };

    $('div.editimage button.left').bind ('click.mb', function (event) {
        var $editimage = $(this).closest ('div.editimage');
        var $prev = $editimage.prev ();
        if ($prev.length)
        {
            $editimage.insertBefore ($prev);
            swap_values ($prev.find ('input.position'), $editimage.find ('input.position'));
        }

        event.preventDefault ();
        return false;
    });

    $('div.editimage button.right').bind ('click.mb', function (event) {
        var $editimage = $(this).closest ('div.editimage');
        var $next = $editimage.next ();
        if ($next.length)
        {
            $editimage.insertAfter ($next);
            swap_values ($next.find ('input.position'), $editimage.find ('input.position'));
        }

        event.preventDefault ();
        return false;
    });

    /* moving <script> elements around with insertBefore() and
     * insertAfter() will rerun them.  The script bits for these
     * images should NOT be ran again, so remove those nodes. */
    $('div.editimage script').remove ();
};

MB.CoverArt.add_files = function (event) {
    $.each ($('input.add-files')[0].files, function (idx, file) {
        console.log ("add files", file.type, file.name, filesize (file.size), file);
/*
        var $filebox;
        if (file.type === "image/jpeg")
        {
            $filebox = $('.file-box.template').clone ().removeClass ('template');
        }
        else
        {
            $filebox = $('.file-box-error.template').clone ().removeClass ('template');
        }
        $filebox.insertBefore ($('#add-files-end'))
            .show ()
            .find ('.filename').text (file.name).end ()
            .find ('.filesize').text ('(' + filesize (file.size) + ')').end ()
            .find ('.file-down').click (MB.CoverArt.file_down).end ()
            .find ('.file-up').click (MB.CoverArt.file_up).end ()
            .data ('file', file);
*/
    });

    /* Only display the the cover art type help once. */
//    $('.cover-art-types-help').hide ().eq (1).show ();
};

console.log ("initializing MB.CoverArt");


MB.CoverArt.CoverArtType = function (name, id) {
    var self = this;
    self.name = name;
    self.id = id;
    self.checked = ko.observable(false);
}

MB.CoverArt.CoverArtTypes = function () {
    var self = this;
    var ret = ko.observableArray ();

    _(MB.cover_art_types_json).each (function (item) {
        ret.push (new MB.CoverArt.CoverArtType(item.l_name, item.id));
    });

    return ret;
};


/*
   For each image the upload process is:

   1. validating   Validate the file the user has selected.
   2. waiting      Wait for the user to make their selections and submit the edit.
   3. signing      Request postfields from /ws/js/cover-art-upload/:mbid.
   4. uploading    Upload image to postfields.action.
   5. submitting   POST edit to /release/:mbid/add-cover-art.
   6. done         All actions completed successfully.

   each of these (except waiting) has an accompanying error state.
*/

MB.CoverArt.upload_status_enum = {
    'validating':     'validating',
    'validate_error': 'validate_error',
    'waiting':        'waiting',
    'signing':        'signing',
    'sign_error':     'sign_error',
    'uploading':      'uploading',
    'upload_error':   'upload_error',
    'submitting':     'submitting',
    'submit_error':   'submit_error',
    'done':           'done',
};

/* NOTE: javascript objects do not allow integer keys, these are
   coerced to strings. */
MB.CoverArt.image_signatures = {
    0x38464947: 'image/gif',  /* GIF signature. "GIF8" */
    0x474E5089: 'image/png',  /* PNG signature, [137 "PNG"] */
    0xE0FFD8FF: 'image/jpeg', /* JPEG signature. */
};

MB.CoverArt.validate_file = function (file) {
    var deferred = $.Deferred ();
    var reader = new FileReader();
    reader.addEventListener("loadend", function() {
        var uint32view = new Uint32Array(reader.result);

        var mime_type = MB.CoverArt.image_signatures[uint32view[0]];
        if (mime_type)
        {
            deferred.resolve (mime_type);
        }
        else
        {
            deferred.reject ();
        }
    });
    reader.readAsArrayBuffer(file.slice (0, 4));

    return deferred.promise ();
};

MB.CoverArt.sign_upload = function (file, gid) {
    var deferred = $.Deferred ();

    var postfields = $.getJSON('/ws/js/cover-art-upload/' + gid);
    postfields.fail (function (jqxhr, status, error) {
        deferred.reject ();
    });

    postfields.done (function (data, status, jqxhr) {
        deferred.resolve (data);
    });

    return deferred.promise ();
};

MB.CoverArt.upload_image = function (postfields, file) {
    var deferred = $.Deferred ();

    var formdata = new FormData();
    formdata.append("file", file);
    $.each (postfields.formdata, function (key, val) {
        formdata.append (key, val);
    });

    var xhr = new XMLHttpRequest ();
    xhr.upload.addEventListener("progress", function (event) {
        if (event.lengthComputable)
        {
            deferred.notify (100 * event.loaded / event.total);
        }
    });

    xhr.addEventListener("load", function (event) {
        if (xhr.status >= 200 && xhr.status < 210)
        {
            deferred.notify (100);
            deferred.resolve ();
        }
        else
        {
            deferred.reject();
        }
    });

    xhr.addEventListener("error", deferred.reject);
    xhr.addEventListener("abort", deferred.reject);
    xhr.open ("POST", postfields.action);
    xhr.send (formdata);

    return deferred.promise ();
};

MB.CoverArt.submit_edit = function () {
    var deferred = $.Deferred ();

    console.log ("submit edit not implemented. got nothing");
    deferred.resolve ();
    return deferred.promise ();
};

MB.CoverArt.FileUpload = function(file) {
    var self = this;
    var statuses = MB.CoverArt.upload_status_enum;

    self.name = file.name;
    self.size = filesize (file.size);
    self.comment = ko.observable ();
    self.types = MB.CoverArt.CoverArtTypes ();
    self.data = file;
    self.image_id = null;
    self.mime_type = null;

    self.progress = ko.observable (0);
    self.status = ko.observable ('validating');

    self.startUpload = function (gid, position) {
        var deferred = $.Deferred ();
        self.status (statuses.signing);

        var signing = MB.CoverArt.sign_upload (self.data, gid);
        signing.fail (function () {
            self.status (statuses.sign_error);
            deferred.reject ();
        });

        signing.done (function (postfields) {
            self.status (statuses.uplading);

            var uploading = MB.CoverArt.upload_image (postfields, self.data);
            uploading.fail (function () {
                self.status (statuses.upload_error);
                deferred.reject ();
            });
            uploading.done (function () {
                self.status (statuses.submitting);

                var submitting = MB.CoverArt.submit_edit ();
                submitting.fail (function () {
                    self.status (statuses.submit_error);
                    deferred.reject ();
                })
                submitting.done (function () {
                    self.status (statuses.done);
                    deferred.resolve ();
                });
            });
        });

        return deferred.promise ();
    };

    MB.CoverArt.validate_file (self.data)
        .fail (function () { self.status (statuses.validate_error) })
        .then (function (mime_type) {
            self.mime_type = mime_type;
            self.status (statuses.waiting)
        });
}

MB.CoverArt.UploadProcessViewModel = function () {
    var self = this;
    self.files_to_upload = ko.observableArray ();

    self.addFile = function (file) {
        self.files_to_upload.push (new MB.CoverArt.FileUpload (file));
    }

    self.moveFile = function (to_move, direction) {
        var new_pos = self.files_to_upload ().indexOf (to_move) + direction;
        if (new_pos < 0 || new_pos >= self.files_to_upload().length)
            return

        self.files_to_upload.remove (to_move);
        self.files_to_upload.splice (new_pos, 0, to_move);
    }
};

MB.CoverArt.add_cover_art_submit = function (gid, upvm) {
    var pos = parseInt ($('#id-add-cover-art\\.position').val (), 10);
    console.log ("submit some cover arts!!", gid, pos);

    var queue = _(upvm.files_to_upload ()).map (function (item, idx) {
        return function () {
            return item.startUpload (gid, pos++);
        };
    });

    MB.utility.iteratePromises (queue).then (function () {
        console.log ("all promises done, yay!");
    });
};

MB.CoverArt.add_cover_art = function (gid) {
    if (typeof (FormData) === "function")
    {
        /* FormData is supported, so we can present the multifile ajax
         * upload form. */

        upvm = new MB.CoverArt.UploadProcessViewModel ();
        ko.applyBindings (upvm);

        $(document).on ('click', 'button.cancel-file', function (event) {
            event.preventDefault ();
            upvm.files_to_upload.remove (ko.dataFor (this));
        });

        $(document).on ('click', 'input.file-up', function (event) {
            event.preventDefault ();
            upvm.moveFile (ko.dataFor (this), -1);
        });

        $(document).on ('click', 'input.file-down', function (event) {
            event.preventDefault ();
            upvm.moveFile (ko.dataFor (this), 1);
        });

        $('button.add-files').on ('click', function (event) {
            $('input.add-files').trigger ('click');
        });

        $('input.add-files').on ('change', function (event) {
            $.each ($('input.add-files')[0].files, function (idx, file) {
                upvm.addFile (file);
            });

            $('#add-cover-art-submit').prop ('disabled', false);
        });

        $('#add-cover-art-submit').on ('click.mb', function (event) {
            event.preventDefault ();
            console.log ("submit!");
            MB.CoverArt.add_cover_art_submit (gid, upvm);
        });
    }
    else
    {
        $('#add-cover-art-submit').prop('disabled', false);

        $('#add-cover-art-submit').on ('click.mb', function (event) {
            event.preventDefault ();

            var mime_type = MB.CoverArt.get_image_mime_type ();
            $('#id-add-cover-art\\.mime_type').val(mime_type);

            if (mime_type)
            {
                $('iframe')[0].contentWindow.upload (
                    mbid, $('#id-add-cover-art\\.id').val (), mime_type);
            }
            else
            {
                $('iframe').contents ().find ('#cover-art-file-error').show ();
            }

            return false;
        });
    }
};
