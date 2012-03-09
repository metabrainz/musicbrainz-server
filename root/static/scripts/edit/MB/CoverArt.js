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

MB.CoverArt.validate_cover_art_type = function () {
    var $select = $('#id-add-cover-art\\.type_id');

    var invalid = $select.find ('option:selected').length < 1;

    $('#cover-art-type-error').toggle (invalid);
    return !invalid;
};

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

MB.CoverArt.image_position = function (url, image_id) {
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

    $.ajax (url + '?jsonp=parseResponse', {
        dataType: "jsonp",
        jsonpCallback: 'parseResponse',
        success: function (data, textStatus, jqXHR) {
            if (data.images.length > 0)
            {
                $('#cover-art-position-row').show ();
                $pos.val (data.images.length + 1);
            }

            $.each (data.images, function (idx, image) {
                if (image.id == image_id)
                {
                    $editimage.appendTo ($('div.image-position'))
                        .find ("img")
                        .bind ("error.mb", function () { MB.CoverArt.image_error ($(this), image); })
                        .attr ("src", image.thumbnails.small);
                }
                else
                {
                    var div = $('<div>').addClass ('thumb-position').appendTo ($('div.image-position'));
                    $('<img />')
                        .bind ("error.mb", function () { MB.CoverArt.image_error ($(this), image); })
                        .attr ("src", image.thumbnails.small)
                        .appendTo (div);

                    $('<div>' + image.types.join (", ") + '</div>').appendTo (div);
                }
            });

            if (MB.utility.isNullOrEmpty (image_id))
            {
                $editimage.appendTo ($('div.image-position'));
            }

            $('.image-position-loading').hide ();
            $('.image-position').show ();
        },
        error: function (jqXHR, textStatus, error) {
            $('.image-position-loading').hide ();
            $('.image-position-only').show ();
        }
    });
};

MB.CoverArt.add_cover_art = function () {
    $('button.submit').bind ('click.mb', function (event) {
        event.preventDefault ();
    
        var valid = MB.CoverArt.validate_cover_art_file () &&
            MB.CoverArt.validate_cover_art_type ();

        if (valid)
        {
            $('iframe').contents ().find ('form').submit ();
        }

        return false;
    });
};
