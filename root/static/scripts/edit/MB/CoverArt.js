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

MB.CoverArt.create_edit = function ($filebox, gid) {
    var deferred = $.Deferred ();

    var formdata = new FormData ();
    formdata.append ('add-cover-art.id', $filebox.data('image-id'));
    $filebox.find('input.type:checked').each (function (idx, elem) {
        formdata.append ('add-cover-art.type_id', $(elem).val ());
    });

    /* FIXME: increment with each image. */
    formdata.append ('add-cover-art.position', $('#id-add-cover-art\\.position').val ());
    formdata.append ('add-cover-art.comment', $filebox.find ('input.comment').val ());
    formdata.append ('add-cover-art.edit_note', $('textarea.edit-note').val ());

    var xhr = new XMLHttpRequest ();
    xhr.addEventListener("load", function (event) {
        deferred.resolve();
    });
    xhr.addEventListener("error", function (event) { console.log ("edit create error", event); deferred.reject(); });
    xhr.addEventListener("abort", function (event) { console.log ("edit create abort", event); deferred.reject(); });

    xhr.open ("POST", $('form.add-cover-art').attr ('action'));
    xhr.send (formdata);

    return deferred.promise ();
};

MB.CoverArt.upload_image = function ($filebox, gid) {

    var set_progress = function ($filebox, progress) {
      $filebox.find ('.ui-progressbar-value').css ('width', Math.floor (progress) + "%");
    };

    var deferred = $.Deferred ();
    var formdata = new FormData();
    formdata.append("file", $filebox.data ('file'));

    var postfields = $.getJSON('/ws/js/cover-art-upload/' + gid);
    postfields.success (function (data, status, jqxhr) {
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
            set_progress ($filebox, 100);

            var edit_promise = MB.CoverArt.create_edit ($filebox, gid);
            /* resolve our promise when creating the edit succeeded or failed,
               so the next image can be uploaded. */
            edit_promise.always (function () { deferred.resolve(); });
        });
        xhr.addEventListener("error", function (event) { console.log ("error", event); deferred.reject(); });
        xhr.addEventListener("abort", function (event) { console.log ("abort", event); deferred.reject(); });

        xhr.open ("POST", data.action);
        xhr.send (formdata);
    });

    return deferred.promise ();
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
        $filebox.insertBefore ($('#cover-art-position-row'))
            .show ()
            .find ('.filename').text (file.name).end ()
            .find ('.filesize').text ('(' + filesize (file.size) + ')').end ()
            .data ('file', file);
    });

    var checkboxid = 0;
    $('div.cover-art-types input[type="checkbox"]').each (function (idx, elem) {
        checkboxid++;
        $(elem).attr ('name', 'checkbox' + checkboxid)
            .next ('label').attr ('for', 'checkbox' + checkboxid);
    });

    /* Only display the the cover art type help once. */
    $('.cover-art-types-help').hide ().eq (1).show ();
};

MB.CoverArt.add_cover_art_submit = function (gid) {
    var queue = [];

    $('.file-box').not('.template').each (function (idx, elem) {
        queue.push (function () {
            return MB.CoverArt.upload_image ($(elem), gid);
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