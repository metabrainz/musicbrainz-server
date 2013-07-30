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

MB.CoverArt.reorder_button = function(direction, $editimage, after) {
    return function (event) {
        if (!$editimage) {
            $editimage = $(this).closest('div.editimage');
        }
        var $swap = $editimage[direction === 'next' ? 'next' : 'prev']();
        if ($swap.length)
        {
            $editimage[direction === 'next' ? 'insertAfter' : 'insertBefore']($swap);
            after($swap, $editimage)
        }

        $(this).focus();
        event.preventDefault();
        return false;
    }
};

MB.CoverArt.image_position = function () {
    var $pos = $('#id-add-cover-art\\.position');
    var $editimage = $('div.editimage');

    $('div.editimage button.left').bind('click.mb',
      MB.CoverArt.reorder_button('prev', $editimage,
                                 function() { $pos.val(parseInt($pos.val(), 10) - 1) }));

    $('div.editimage button.right').bind('click.mb',
      MB.CoverArt.reorder_button('next', $editimage,
                                 function() { $pos.val(parseInt($pos.val(), 10) + 1) }));
};

MB.CoverArt.reorder_position = function () {
    var swap_values = function ($a, $b) {
        var otherval = $a.val ();
        $a.val ($b.val ());
        $b.val (otherval);
    };

    $('div.editimage button.left').bind('click.mb',
      MB.CoverArt.reorder_button('prev', null,
                                 function($swap, $editimage) { swap_values($swap.find('input.position'), $editimage.find('input.position')) }));

    $('div.editimage button.right').bind('click.mb',
      MB.CoverArt.reorder_button('next', null,
                                 function($swap, $editimage) { swap_values($swap.find('input.position'), $editimage.find('input.position')) }));

    /* moving <script> elements around with insertBefore() and
     * insertAfter() will rerun them.  The script bits for these
     * images should NOT be ran again, so remove those nodes. */
    $('div.editimage script').remove ();
};

MB.CoverArt.CoverArtType = function (name, id) {
    var self = this;
    self.name = name;
    self.id = id;
    self.checked = ko.observable(false);
}

MB.CoverArt.cover_art_types = function () {
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

   most of these have an accompanying error state.
*/

MB.CoverArt.upload_status_enum = {
    'validating':     'validating',
    'validate_error': 'validate_error',
    'waiting':        'waiting',
    'signing':        'signing',
    'sign_error':     'sign_error',
    'uploading':      'uploading',
    'upload_error':   'upload_error',
    'slowdown_error': 'slowdown_error',
    'submitting':     'submitting',
    'submit_error':   'submit_error',
    'done':           'done'
};

MB.CoverArt.validate_file = function (file) {
    var deferred = $.Deferred ();
    var reader = new FileReader();
    reader.addEventListener("loadend", function() {
        var uint32view = new Uint32Array(reader.result);

        /* JPEG signature is usually FF D8 FF E0 (JFIF), or FF D8 FF E1 (EXIF).
           Some cameras and phones write a different fourth byte. */

        if ((uint32view[0] & 0x00FFFFFF) === 0x00FFD8FF)
        {
            deferred.resolve ('image/jpeg');
        }
        else if (uint32view[0] === 0x38464947) /* GIF signature. "GIF8" */
        {
            deferred.resolve ('image/gif');
        }
        else if (uint32view[0] === 0x474E5089) /* PNG signature, 0x89 "PNG" */
        {
            deferred.resolve ('image/png');
        }
        else
        {
            deferred.reject ("unrecognized image format");
        }
    });
    reader.readAsArrayBuffer(file.slice (0, 4));

    return deferred.promise ();
};

MB.CoverArt.file_data_uri = function (file) {
    var deferred = $.Deferred ();
    var reader = new FileReader();
    reader.addEventListener("loadend", function() {
        deferred.resolve(reader.result);
    });
    reader.readAsDataURL(file);

    return deferred.promise();
};

MB.CoverArt.sign_upload = function (file, gid, mime_type) {
    var deferred = $.Deferred ();

    var postfields = $.getJSON('/ws/js/cover-art-upload/' + gid,
                               { mime_type: mime_type });
    postfields.fail (function (jqxhr, status, error) {
        deferred.reject ("error obtaining signature: " + status + " " + error);
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
            deferred.reject ("error uploading image: " + xhr.status + " " +
                             xhr.responseText, xhr.status);
        }
    });

    /* prevent firefox from parsing a 204 No Content response as XML.
       https://bugzilla.mozilla.org/show_bug.cgi?id=884693 */
    xhr.overrideMimeType('text/plain');
    xhr.addEventListener("error", function (event) {
        deferred.reject("error uploading image");
    });
    xhr.addEventListener("abort", function (event) {
        deferred.reject("image upload aborted");
    });
    xhr.open ("POST", postfields.action);
    xhr.send (formdata);

    return deferred.promise ();
};

MB.CoverArt.submit_edit = function (file_upload, postfields, mime_type, position) {
    var deferred = $.Deferred ();

    var formdata = new FormData ();
    formdata.append ('add-cover-art.id', postfields.image_id);
    formdata.append ('add-cover-art.position', position);
    formdata.append ('add-cover-art.mime_type', mime_type);
    formdata.append ('add-cover-art.comment', file_upload.comment ());
    formdata.append ('add-cover-art.edit_note', $('textarea.edit-note').val ());
    if ($('#id-add-cover-art\\.as_auto_editor').prop('checked')) {
        formdata.append ('add-cover-art.as_auto_editor', 'on');
    }

    _(file_upload.types ()).each (function (checkbox) {
        if (checkbox.checked ())
        {
            formdata.append ('add-cover-art.type_id', checkbox.id);
        }
    });

    var xhr = new XMLHttpRequest ();
    xhr.addEventListener("load", function (event) {
        if (xhr.status === 200)
        {
            deferred.resolve();
        }
        else
        {
            deferred.reject("error creating edit: " + xhr.status + " " + xhr.statusText);
        }
    });

    xhr.addEventListener("error", function (event) {
        deferred.reject("unknown error creating edit");
    });

    xhr.addEventListener("abort", function (event) {
        deferred.reject("create edit aborted");
    });

    xhr.open ("POST", $('#add-cover-art').attr ('action'));
    xhr.send (formdata);

    return deferred.promise ();

};

MB.CoverArt.FileUpload = function(file) {
    var self = this;
    var statuses = MB.CoverArt.upload_status_enum;

    self.name = file.name;
    self.size = MB.utility.filesize (file.size);
    self.comment = ko.observable ("");
    self.types = MB.CoverArt.cover_art_types ();
    self.data = file;
    self.data_uri = ko.observable("");

    MB.CoverArt.file_data_uri(file)
        .done(function (data_uri) {
            self.data_uri(data_uri);
        });

    self.progress = ko.observable (0);
    self.status = ko.observable ('validating');
    self.busy = ko.computed(function () {
        return (self.status () === 'validating' ||
                self.status () === 'signing' ||
                self.status () === 'uploading' ||
                self.status () === 'submitting');
    });

    self.validating = MB.CoverArt.validate_file (self.data)
        .fail (function () {
            self.status (statuses.validate_error)
        })
        .done (function (mime_type) {
            self.status (statuses.waiting)
        });

    self.doUpload = function (gid, position) {
        var deferred = $.Deferred ();

        self.validating.fail (function (msg) { deferred.reject(msg); });
        self.validating.done (function (mime_type) {
            if (self.status () !== "waiting")
            {
                /* This file already had its upload started. */
                return;
            }

            self.status (statuses.signing);

            var signing = MB.CoverArt.sign_upload (self.data, gid, mime_type);
            signing.fail (function (msg) {
                self.status (statuses.sign_error);
                deferred.reject (msg);
            });

            signing.done (function (postfields) {
                self.status (statuses.uploading);
                self.updateProgress (1, 100);

                var uploading = MB.CoverArt.upload_image (postfields, self.data);
                uploading.progress (function (value) {
                    self.updateProgress (2, value);
                });
                uploading.fail (function (msg, status) {
                    self.status (status === 503 ?
                                 statuses.slowdown_error : statuses.upload_error);
                    deferred.reject (msg);
                });
                uploading.done (function () {
                    self.status (statuses.submitting);
                    self.updateProgress (2, 100);

                    var submitting = MB.CoverArt.submit_edit (
                        self, postfields, mime_type, position);

                    submitting.fail (function (msg) {
                        self.status (statuses.submit_error);
                        deferred.reject (msg);
                    })
                    submitting.done (function () {
                        self.status (statuses.done);
                        self.updateProgress (3, 100);
                        deferred.resolve ();
                    });
                });
            });

        });

        return deferred.promise ();
    };

    self.updateProgress = function (step, value) {
        /*
          To make the progress bar show progress for the entire process each of
          the three requests get a chunk of the progress bar:

          step 1. Signing       0% to  10%
          step 2. Upload       10% to  90%
          step 3. Create edit  90% to 100%
        */

        switch (step) {
        case 1:
            self.progress ( 0 + value * 0.1);
            break;
        case 2:
            self.progress (10 + value * 0.8);
            break;
        case 3:
            self.progress (90 + value * 0.1);
            break;
        }
    };

};

MB.CoverArt.UploadProcessViewModel = function () {
    var self = this;
    self.files_to_upload = ko.observableArray ();

    self.addFile = function (file) {
        var file_upload = new MB.CoverArt.FileUpload (file);
        self.files_to_upload.push (file_upload);
        return file_upload;
    }

    self.moveFile = function (to_move, direction) {
        var new_pos = self.files_to_upload ().indexOf (to_move) + direction;
        if (new_pos < 0 || new_pos >= self.files_to_upload().length)
            return

        self.files_to_upload.remove (to_move);
        self.files_to_upload.splice (new_pos, 0, to_move);
    }
};


MB.CoverArt.process_upload_queue = function (gid, upvm, pos) {

    var queue = _(upvm.files_to_upload ()).map (function (item, idx) {
        return function () {
            return item.doUpload (gid, pos++);
        };
    });

    return queue;
};

MB.CoverArt.add_cover_art_submit = function (gid, upvm) {
    var pos = parseInt ($('#id-add-cover-art\\.position').val (), 10);

    $('.add-files.row').hide();
    $('#cover-art-position-row').hide ();
    $('#content')[0].scrollIntoView ();

    var queue = MB.CoverArt.process_upload_queue (gid, upvm, pos);

    MB.utility.iteratePromises (queue).done (function () {
        window.location.href = '/release/' + gid + '/cover-art';
    });
};

MB.CoverArt.add_cover_art = function (gid) {

    File.prototype.slice = File.prototype.webkitSlice || File.prototype.mozSlice || File.prototype.slice;

    if (typeof (FormData) === "function")
    {
        /* FormData is supported, so we can present the multifile ajax
         * upload form. */

        $('.with-formdata').show ();

        var upvm = new MB.CoverArt.UploadProcessViewModel ();
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

        $('#drop-zone').on ('dragover', function (event) {
            event.preventDefault();
            event.stopPropagation();
            event.dataTransfer.dropEffect = 'copy';
        });

        $('#drop-zone').on ('drop', function (event) {
            event.preventDefault();
            event.stopPropagation();
            $.each (event.originalEvent.dataTransfer.files, function (idx, file) {
                upvm.addFile (file);
            });

            $('#add-cover-art-submit').prop ('disabled', false);
        });

        $('#add-cover-art-submit').on ('click.mb', function (event) {
            event.preventDefault ();
            MB.CoverArt.add_cover_art_submit (gid, upvm);
        });
    }
    else
    {
        $('.without-formdata').show ();
        $('#add-cover-art-submit').prop('disabled', false);

        $('#add-cover-art-submit').on ('click.mb', function (event) {
            event.preventDefault ();

            var mime_type = MB.CoverArt.get_image_mime_type ();
            $('#id-add-cover-art\\.mime_type').val(mime_type);

            if (mime_type)
            {
                $('iframe')[0].contentWindow.upload (
                    gid, $('#id-add-cover-art\\.id').val (), mime_type);
            }
            else
            {
                $('iframe').contents ().find ('#cover-art-file-error').show ();
            }

            return false;
        });
    }
};
