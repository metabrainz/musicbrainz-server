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

MB.CoverArt.add_cover_art = function (mbid) {
    $('#add-cover-art-submit').prop('disabled', false);

    $('button.submit').bind ('click.mb', function (event) {
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
};
