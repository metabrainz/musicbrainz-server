/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010 MetaBrainz Foundation

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

MB.CoverArt.validate_cover_art_file = function () {
    var filename = $('iframe').contents ().find ('#file').val ();
    var invalid = (filename == ""
                   || filename.match(/\.j(peg|pg|pe|fif|if)$/i) == null);

    $('iframe').contents ().find ('#cover-art-file-error').toggle (invalid);

    return !invalid;
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

MB.CoverArt.upload_error = function ($filebox, error) {
    var message = "";
    if (error && error.slice (0, 5) === '<?xml')
    {
        message = ("<strong>code</strong>: " +
                   $(error).find ('Code').text () +
                   "<br /><strong>message</strong>: " +
                   $(error).find ('Message').text () +
                   "<br />");
    }
    else
    {
        message = "<strong>" + error + "</strong>";
    }

    $filebox.find ('div.row').not ('.file-info').hide ();
    $filebox.find ('div.upload-error').show ()
        .find (".errortext").empty ().append ($(message));
};

MB.CoverArt.create_edit = function ($filebox, gid, position) {
    var deferred = $.Deferred ();

    var formdata = new FormData ();
    formdata.append ('add-cover-art.id', $filebox.data('image-id'));
    $filebox.find('input.type:checked').each (function (idx, elem) {
        formdata.append ('add-cover-art.type_id', $(elem).val ());
    });

    formdata.append ('add-cover-art.position', position);
    formdata.append ('add-cover-art.comment', $filebox.find ('input.comment').val ());
    formdata.append ('add-cover-art.edit_note', $('textarea.edit-note').val ());

    var xhr = new XMLHttpRequest ();
    xhr.addEventListener("load", function (event) {
        if (xhr.status === 200)
        {
            deferred.resolve();
        }
        else
        {
            MB.CoverArt.upload_error ($filebox, xhr.status + " " + xhr.statusText);
            deferred.reject();
        }
    });

    xhr.addEventListener("error", function (event) {
        MB.CoverArt.upload_error ($filebox, "An unknown error occured while creating this edit");
        deferred.reject();
    });

    xhr.addEventListener("abort", function (event) {
        MB.CoverArt.upload_error ($filebox, "Aborted create edit");
        deferred.reject();
    });

    xhr.open ("POST", $('form.add-cover-art').attr ('action'));
    xhr.send (formdata);

    return deferred.promise ();
};

MB.CoverArt.upload_image = function ($filebox, gid, position) {

    var set_progress = function ($filebox, progress) {
      $filebox.find ('.ui-progressbar-value').css ('width', Math.floor (progress) + "%");
    };

    var deferred = $.Deferred ();
    var formdata = new FormData();
    formdata.append("file", $filebox.data ('file'));

    var postfields = $.getJSON('/ws/js/cover-art-upload/' + gid);
    postfields.done (function (data, status, jqxhr) {
        $filebox.data('image-id', data.image_id);
        $.each (data.formdata, function (key, val) {
            formdata.append (key, val);
        });

        var xhr = new XMLHttpRequest ();
        xhr.upload.addEventListener("progress", function (event) {
            if (event.lengthComputable)
            {
                set_progress ($filebox, 100 * event.loaded / event.total);
            }
        });

        xhr.addEventListener("load", function (event) {
            if (xhr.status >= 200 && xhr.status < 210)
            {
                set_progress ($filebox, 100);

                var edit_promise = MB.CoverArt.create_edit ($filebox, gid, position);
                edit_promise.done (deferred.resolve);
                edit_promise.fail (deferred.reject);
            }
            else
            {
                MB.CoverArt.upload_error (
                    $filebox, xhr.status + " " + xhr.statusText);
                deferred.reject();
            }
        });

        xhr.addEventListener("error", function (event) {
            MB.CoverArt.upload_error ($filebox, "An unknown error occured while uploading the image");
            deferred.reject();
        });

        xhr.addEventListener("abort", function (event) {
            MB.CoverArt.upload_error ($filebox, "Image upload aborted");
            deferred.reject();
        });

        xhr.open ("POST", data.action);
        xhr.send (formdata);
    });

    postfields.fail (function (jqxhr, status, errorText) {
        MB.CoverArt.upload_error ($filebox, status + " " + errorText);
        deferred.reject();
    });


    return deferred.promise ();
};

MB.CoverArt.file_down = function (event) {
    var $filebox = $(this).closest ('.file-box');
    var $next = $filebox.next ('.file-box');
    $next.insertBefore ($filebox);
};

MB.CoverArt.file_up = function (event) {
    var $filebox = $(this).closest ('.file-box');
    var $prev = $filebox.prev ('.file-box');
    $filebox.insertBefore ($prev);
};

MB.CoverArt.add_files = function (event) {
    $.each ($('input.add-files')[0].files, function (idx, file) {
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
    });

    /* Only display the the cover art type help once. */
    $('.cover-art-types-help').hide ().eq (1).show ();
};

MB.CoverArt.add_cover_art_submit = function (gid) {
    var queue = [];

    var position = parseInt ($('#id-add-cover-art\\.position').val (), 10);

    if (! $('.file-box').not('.template').length)
        return; /* no files selected. */

    $('.file-box').not('.template').each (function (idx, elem) {
        queue.push (function () {
            return MB.CoverArt.upload_image ($(elem), gid, position++);
        });
    });

    MB.utility.iteratePromises (queue).then (function () {
        var url = window.location.href.replace (/add-cover-art$/, 'added-cover-art');
        window.location = url;
    });

    return false;
};

MB.CoverArt.add_cover_art = function (gid)
{
    $('#add-cover-art-submit').removeAttr('disabled');
    $('form.add-cover-art').show ();

    $(document).on ('click', 'button.cancel-file', function (event) {
        event.preventDefault ();
        $(this).closest ('.file-box').remove ();
    });

    if (typeof (FormData) === "function")
    {
        /* FormData is supported, so we can present the multifile ajax
         * upload form. */
        $('.xmlhttprequest-upload').show ();

        $('button.add-files').click (function (event) {
            $('input.add-files').trigger ('click');
        });

        $('input.add-files').bind ('change', MB.CoverArt.add_files);

        $('#add-cover-art-submit')
            .bind ('click.mb', function (event) {
                event.preventDefault ();
                MB.CoverArt.add_cover_art_submit (gid);
                return false;
            });
    }
    else
    {
        /* FormData not supported, fallback to iframe hack. */
        $('.iframe-upload').show ();

        $('#add-cover-art-submit')
            .bind ('click.mb', function (event) {
                event.preventDefault ();

                var valid = MB.CoverArt.validate_cover_art_file ();
                if (valid)
                {
                    $('iframe').contents ().find ('form').submit ();
                }

                return false;
            });
    }

};