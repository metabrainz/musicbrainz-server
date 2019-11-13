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

import filesize from 'filesize';
import $ from 'jquery';
import ko from 'knockout';
import _ from 'lodash';

import MB from '../../common/MB';

MB.CoverArt = {};

MB.CoverArt.get_image_mime_type = function () {
    var filename = $('iframe').contents().find('#file').val();
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
    else if (filename.match(/\.pdf$/i))
    {
        mime_type = "application/pdf";
    }

    return mime_type;
};

MB.CoverArt.image_error = function ($img, image) {
    if ($img.attr("src") !== image.image)
    {
        $img.attr("src", image.image)
    }
    else
    {
        /* image doesn't exist at all, perhaps it was removed
           between requesting the index and loading the image.
           FIXME: start over if this happens?  obviously the
           data in the index is incorrect. */
        $img.attr("src", require('../../../images/image404-125.png'));
    }
};

MB.CoverArt.reorder_button = function (direction, $container) {
    return function (event) {
        var $editimage = $(this).closest('div.editimage');

        var $swap = $editimage[direction === 'next' ? 'next' : 'prev']();
        var insert_after = (direction === 'next');
        if (!$swap.length) {
            // no direct neighbour, so wrap around
            $swap = $editimage.siblings()[direction === 'next' ? 'first' : 'last']();
            insert_after = !insert_after;
        }
        if ($swap.length)
        {
            $editimage[insert_after ? 'insertAfter' : 'insertBefore']($swap);
            $container.sortable('refresh');
        }

        $(this).focus();
        event.preventDefault();
        return false;
    }
};

MB.CoverArt.reorder_position = function () {
    var $container = $('div.image-position');

    $container.sortable({
            items: '> div.thumb-position',
            cancel: 'button,div.thumb-position:not(".editimage")',
            placeholder: 'thumb-position',
            cursor: 'grabbing',
            distance: 10,
            tolerance: 'pointer',
        });

    $('div.editimage button.left').bind('click.mb',
      MB.CoverArt.reorder_button('prev', $container));

    $('div.editimage button.right').bind('click.mb',
      MB.CoverArt.reorder_button('next', $container));

    // For the Add Cover Art page, the following is a no-op.
    $('#reorder-cover-art').submit(
        function (event) {
            $('div.editimage input.position').val(function (index, oldvalue) { return (index + 1); });
        },
    );

    /* moving <script> elements around with insertBefore() and
     * insertAfter() will rerun them.  The script bits for these
     * images should NOT be ran again, so remove those nodes. */
    $('div.editimage script').remove();
};

MB.CoverArt.CoverArtType = function (name, id) {
    var self = this;
    self.name = name;
    self.id = id;
    self.checked = ko.observable(false);
}

MB.CoverArt.cover_art_types = function () {
    return ko.observableArray(
        _.map(MB.cover_art_types_json, function (item) {
            return new MB.CoverArt.CoverArtType(item.l_name, item.id);
        }),
    );
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
    'done':           'done',
};

MB.CoverArt.validate_file = function (file) {
    var deferred = $.Deferred();
    var reader = new window.FileReader();
    reader.addEventListener("loadend", function () {
        var uint32view = new Uint32Array(reader.result);

        /* JPEG signature is usually FF D8 FF E0 (JFIF), or FF D8 FF E1 (EXIF).
           Some cameras and phones write a different fourth byte. */

        if ((uint32view[0] & 0x00FFFFFF) === 0x00FFD8FF)
        {
            deferred.resolve('image/jpeg');
        }
        else if (uint32view[0] === 0x38464947) /* GIF signature. "GIF8" */
        {
            deferred.resolve('image/gif');
        }
        else if (uint32view[0] === 0x474E5089) /* PNG signature, 0x89 "PNG" */
        {
            deferred.resolve('image/png');
        }
        else if (uint32view[0] === 0x46445025) /* PDF signature, 0x89 "%PDF" */
        {
            deferred.resolve('application/pdf');
        }
        else
        {
            deferred.reject("unrecognized image format");
        }
    });
    reader.readAsArrayBuffer(file.slice(0, 4));

    return deferred.promise();
};

MB.CoverArt.file_data_uri = function (file) {
    var deferred = $.Deferred();
    var reader = new window.FileReader();
    reader.addEventListener("loadend", function () {
        deferred.resolve(reader.result);
    });
    reader.readAsDataURL(file);

    return deferred.promise();
};

MB.CoverArt.sign_upload = function (file, gid, mime_type) {
    var deferred = $.Deferred();

    var postfields = $.ajax({
        url: "/ws/js/cover-art-upload/" + gid,
        data: { mime_type: mime_type },
        dataType: "json",
        cache: false,
    });

    postfields.fail(function (jqxhr, status, error) {
        deferred.reject("error obtaining signature: " + status + " " + error);
    });

    postfields.done(function (data, status, jqxhr) {
        deferred.resolve(data);
    });

    return deferred.promise();
};

MB.CoverArt.upload_image = function (postfields, file) {
    var deferred = $.Deferred();

    var formdata = new window.FormData();

    $.each(postfields.formdata, function (key, val) {
        formdata.append(key, val);
    });

    formdata.append("file", file);

    var xhr = new XMLHttpRequest();
    xhr.upload.addEventListener("progress", function (event) {
        if (event.lengthComputable)
        {
            deferred.notify(100 * event.loaded / event.total);
        }
    });

    xhr.addEventListener("load", function (event) {
        if (xhr.status >= 200 && xhr.status < 210)
        {
            deferred.notify(100);
            deferred.resolve();
        }
        else
        {
            deferred.reject("error uploading image: " + xhr.status + " " +
                             xhr.responseText, xhr.status);
        }
    });

    /* IE10 and older don't have overrideMimeType. */
    if (typeof (xhr.overrideMimeType) === 'function')
    {
        /* prevent firefox from parsing a 204 No Content response as XML.
           https://bugzilla.mozilla.org/show_bug.cgi?id=884693 */
        xhr.overrideMimeType('text/plain');
    }
    xhr.addEventListener("error", function (event) {
        deferred.reject("error uploading image");
    });
    xhr.addEventListener("abort", function (event) {
        deferred.reject("image upload aborted");
    });
    xhr.open("POST", postfields.action);
    xhr.send(formdata);

    return deferred.promise();
};

MB.CoverArt.submit_edit = function (file_upload, postfields, mime_type, position) {
    var deferred = $.Deferred();

    var formdata = new window.FormData();
    formdata.append('add-cover-art.id', postfields.image_id);
    formdata.append('add-cover-art.position', position);
    formdata.append('add-cover-art.mime_type', mime_type);
    formdata.append('add-cover-art.comment', file_upload.comment());
    formdata.append('add-cover-art.edit_note', $('textarea.edit-note').val());
    if ($('#id-add-cover-art\\.make_votable').prop('checked')) {
        formdata.append('add-cover-art.make_votable', 'on');
    }

    _.each(file_upload.types(), function (checkbox) {
        if (checkbox.checked())
        {
            formdata.append('add-cover-art.type_id', checkbox.id);
        }
    });

    var xhr = new XMLHttpRequest();
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

    xhr.open("POST", $('#add-cover-art').attr('action'));
    xhr.send(formdata);

    return deferred.promise();

};

MB.CoverArt.FileUpload = function (file) {
    var self = this;
    var statuses = MB.CoverArt.upload_status_enum;

    self.name = file.name;
    self.size = filesize(file.size, { round: 1, bits: false });
    self.comment = ko.observable("");
    self.types = MB.CoverArt.cover_art_types();
    self.data = file;
    self.data_uri_data = ko.observable("");
    self.mime_type = ko.observable("");

    self.data_uri = ko.computed(function () {
        if (self.mime_type() == "" || self.data_uri_data() == "") {
            return "";
        } else if (self.mime_type() == "application/pdf") {
            return "/static/images/icons/pdf-icon.png";
        } 
        return self.data_uri_data();
    });


    MB.CoverArt.file_data_uri(file)
        .done(function (data_uri) {
            self.data_uri_data(data_uri);
        });

    self.progress = ko.observable(0);
    self.status = ko.observable('validating');
    self.busy = ko.computed(function () {
        return (self.status() === 'validating' ||
                self.status() === 'signing' ||
                self.status() === 'uploading' ||
                self.status() === 'submitting');
    });

    self.validating = MB.CoverArt.validate_file(self.data)
        .fail(function () {
            self.status(statuses.validate_error)
        })
        .done(function (mime_type) {
            self.mime_type(mime_type);
            self.status(statuses.waiting)
        });

    self.doUpload = function (gid, position) {
        var deferred = $.Deferred();

        if (self.status() === 'done' || self.busy())
        {
            /* This file is currently being uploaded or has already
               been uploaded. */
            deferred.reject();
            return deferred.promise();
        }

        self.validating.fail(function (msg) { deferred.reject(msg); });
        self.validating.done(function (mime_type) {
            self.status(statuses.signing);

            var signing = MB.CoverArt.sign_upload(self.data, gid, mime_type);
            signing.fail(function (msg) {
                self.status(statuses.sign_error);
                deferred.reject(msg);
            });

            signing.done(function (postfields) {
                self.status(statuses.uploading);
                self.updateProgress(1, 100);

                var uploading = MB.CoverArt.upload_image(postfields, self.data);
                uploading.progress(function (value) {
                    self.updateProgress(2, value);
                });
                uploading.fail(function (msg, status) {
                    self.status(status === 503 ?
                                 statuses.slowdown_error : statuses.upload_error);
                    deferred.reject(msg);
                });
                uploading.done(function () {
                    self.status(statuses.submitting);
                    self.updateProgress(2, 100);

                    var submitting = MB.CoverArt.submit_edit(
                        self, postfields, mime_type, position);

                    submitting.fail(function (msg) {
                        self.status(statuses.submit_error);
                        deferred.reject(msg);
                    })
                    submitting.done(function () {
                        self.status(statuses.done);
                        self.updateProgress(3, 100);
                        deferred.resolve();
                    });
                });
            });

        });

        return deferred.promise();
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
            self.progress(0 + value * 0.1);
            break;
        case 2:
            self.progress(10 + value * 0.8);
            break;
        case 3:
            self.progress(90 + value * 0.1);
            break;
        }
    };

};

MB.CoverArt.UploadProcessViewModel = function () {
    var self = this;
    self.files_to_upload = ko.observableArray();

    self.addFile = function (file) {
        var file_upload = new MB.CoverArt.FileUpload(file);
        self.files_to_upload.push(file_upload);
        return file_upload;
    }

    self.moveFile = function (to_move, direction) {
        var new_pos = self.files_to_upload().indexOf(to_move) + direction;
        if (new_pos < 0 || new_pos >= self.files_to_upload().length)
            return

        self.files_to_upload.remove(to_move);
        self.files_to_upload.splice(new_pos, 0, to_move);
    }
};


MB.CoverArt.process_upload_queue = function (gid, upvm, pos) {

    var queue = _.map(upvm.files_to_upload(), function (item) {
        return function () {
            return item.doUpload(gid, pos++);
        };
    });

    return queue;
};

MB.CoverArt.add_cover_art_submit = function (gid, upvm) {
    var pos = parseInt($('#id-add-cover-art\\.position').val(), 10);

    $('.add-files.row').hide();
    $('#cover-art-position-row').hide();
    $('#content')[0].scrollIntoView();
    $('#add-cover-art-submit').prop('disabled', true);

    var queue = MB.CoverArt.process_upload_queue(gid, upvm, pos);

    iteratePromises(queue)
        .done(function () {
            window.location.href = '/release/' + gid + '/cover-art';
        })
        .fail(function () {
            $('#add-cover-art-submit').prop('disabled', false);
        });
};

MB.CoverArt.set_position = function () {
    var $editimage = $('div.editimage');
    if ($editimage.length) {
        var position = $editimage.index() + 1;
        $('#id-add-cover-art\\.position').val(position);
    }
};

MB.CoverArt.add_cover_art = function (gid) {
    if (typeof (window.FormData) !== "undefined" && typeof (window.FileReader) !== 'undefined')
    {
        File.prototype.slice = File.prototype.webkitSlice || File.prototype.mozSlice || File.prototype.slice;

        /* FormData is supported, so we can present the multifile ajax
         * upload form. */

        $('.with-formdata').show();

        var upvm = new MB.CoverArt.UploadProcessViewModel();
        ko.applyBindings(upvm);

        $(document).on('click', 'button.cancel-file', function (event) {
            event.preventDefault();
            upvm.files_to_upload.remove(ko.dataFor(this));
        });

        $(document).on('click', 'button.file-up', function (event) {
            event.preventDefault();
            upvm.moveFile(ko.dataFor(this), -1);
        });

        $(document).on('click', 'button.file-down', function (event) {
            event.preventDefault();
            upvm.moveFile(ko.dataFor(this), 1);
        });

        $('button.add-files').on('click', function (event) {
            $('input.add-files').trigger('click');
        });

        $('input.add-files').on('change', function (event) {
            $.each($('input.add-files')[0].files, function (idx, file) {
                upvm.addFile(file);
            });

            $('#add-cover-art-submit').prop('disabled', false);
        });

        $('#drop-zone').on('dragover', function (event) {
            event.preventDefault();
            event.stopPropagation();
            event.originalEvent.dataTransfer.dropEffect = 'copy';
        });

        $('#drop-zone').on('drop', function (event) {
            event.preventDefault();
            event.stopPropagation();
            $.each(event.originalEvent.dataTransfer.files, function (idx, file) {
                upvm.addFile(file);
            });

            $('#add-cover-art-submit').prop('disabled', false);
        });

        $('#add-cover-art-submit').on('click.mb', function (event) {
            event.preventDefault();
            MB.CoverArt.set_position();
            MB.CoverArt.add_cover_art_submit(gid, upvm);
        });
    }
    else
    {
        $('.without-formdata').show();
        $('#add-cover-art-submit').prop('disabled', false);

        $('#add-cover-art-submit').on('click.mb', function (event) {
            event.preventDefault();
            MB.CoverArt.set_position();

            var mime_type = MB.CoverArt.get_image_mime_type();
            $('#id-add-cover-art\\.mime_type').val(mime_type);

            if (mime_type)
            {
                $('iframe')[0].contentWindow.upload(
                    gid, $('#id-add-cover-art\\.id').val(), mime_type);
            }
            else
            {
                $('iframe').contents().find('#cover-art-file-error').show();
            }

            return false;
        });
    }
};

/* This takes a list of asynchronous functions (i.e. functions which
   return a jquery promise) and runs them in sequence.  It in turn
   returns a promise which is only resolved when all promises in the
   queue have been resolved.  If one of the promises is rejected, the
   rest of the queue is still processed (but the returned promise will
   be rejected).

   Note that any results are currently ignored, it is assumed you are
   interested in the side effects of the functions executed.
*/
function iteratePromises(promises) {
    var deferred = $.Deferred();
    var failed = false;

    function iterate() {
        if (promises.length > 0) {
            promises.shift()().then(iterate, function () {
                failed = true;
                iterate();
            });
        } else if (failed) {
            deferred.reject();
        } else {
            deferred.resolve();
        }
    }

    iterate();
    return deferred.promise();
}

export default MB.CoverArt;
