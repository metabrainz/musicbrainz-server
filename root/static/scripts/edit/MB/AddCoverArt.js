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


MB.AddCoverArt = {};

MB.AddCoverArt.lastCheck;

MB.AddCoverArt.validate_cover_art_type = function () {
    var $select = $('#id-add-cover-art\\.type');

    var invalid = $select.find ('option:selected').val () == "";

    $('#cover-art-type-error').toggle (invalid);
    return !invalid;
};

MB.AddCoverArt.validate_cover_art_file = function () {
    var filename = $('iframe').contents ().find ('#file').val ();
    var invalid = (filename == ""
                   || filename.match(/\.j(peg|pg|pe|fif|if)$/i) == null);

    $('iframe').contents ().find ('#cover-art-file-error').toggle (invalid);

    return !invalid;
};

MB.AddCoverArt.validate_existing = function() {
    var type = $('#id-add-cover-art\\.type option:selected').text();
    var index = $('#id-add-cover-art\\.page').val();

    if (lastCheck === undefined || !(lastCheck[0] == type && lastCheck[1] == index))
    {
        $.ajax({
            async: false,
            complete: function(xhr, status) {
                if (xhr.status != 404) {
                    $('#confirmer').show();
                    $('#confirm-preview').attr(
                        'src',
                        'http://coverartarchive.org/release/[% release.gid %]/' +
                            [ type, index ].join('-') + '.jpg'
                    );
                    $('#confirmed').attr('checked', null);
                }
                else {
                    $('#confirmed').attr('checked', 'checked');
                    $('#confirmer').hide();
                }
            },
            data: {
                mbid: '[% release.gid %]',
                type: type,
                index: index
            },
            type: 'HEAD',
            url: '/ws/js/caa/exists'
        });

        lastCheck = [ type, index ];
    }

    return $('#confirmed').is(':checked');
};

MB.AddCoverArt.image_position = function (gid) {

    /* FIXME: replace with coverartarchive urls. */
    var url = "http://s3.us.archive.org/mbid-" + gid + "/";
    var image_prefix = url + "mbid-" + gid + "-";
    var $pos = $('#id-add-cover-art\\.position');

    $('div.newimage button.left').bind ('click.mb', function (event) {
        var $prev = $('div.newimage').prev ();
        if ($prev.length)
        {
            $('div.newimage').insertBefore ($prev);
            $pos.val (parseInt ($pos.val (), 10) - 1);
        }

        console.log ('pos val:', $pos.val ());
        event.preventDefault ();
        return false;
    });

    $('div.newimage button.right').bind ('click.mb', function (event) {
        var $next = $('div.newimage').next ();
        if ($next.length)
        {
            $('div.newimage').insertAfter ($next);
            $pos.val (parseInt ($pos.val (), 10) + 1);
        }

        console.log ('pos val:', $pos.val ());
        event.preventDefault ();
        return false;
    });

    $.getJSON (url + "index.json", function (data, textStatus, jqXHR) {
        if (data.images.length > 0)
        {
            $('#cover-art-position-row').show ();
            $pos.val (data.images.length + 1);
        }

        $.each (data.images, function (idx, image) {
            var div = $('<div>').addClass ("thumb-position").insertBefore ($("div.newimage"));
            $('<img />')
                .bind ("error.mb", function (event) {
                    if ($(this).attr ("src") !== (image_prefix + image.image))
                    {
                        $(this).attr ("src", image_prefix + image.image)
                    }
                    else
                    {
                        /* image doesn't exist at all, perhaps it was removed 
                           between requesting the index and loading the image.
                           FIXME: start over if this happens?  obviously the
                           data in the index is incorrect. */
                        $(this).closest ('div').hide ();
                    }
                })
                .attr ("src", image_prefix + image.thumbnails.small)
                .appendTo (div);

            $('<div>' + image.types.join (", ") + '</div>').appendTo (div);
        });
    });
};


MB.AddCoverArt.hideConfirmer = function() {
    $('#confirmer').hide();
    lastCheck = undefined;
};

$(document).ready (function () {
    $('button.submit').bind ('click.mb', function (event) {
        event.preventDefault ();
    
        var valid = MB.AddCoverArt.validate_cover_art_file () &&
            MB.AddCoverArt.validate_cover_art_type () &&
            MB.AddCoverArt.validate_existing();

        if (valid)
        {
            $('iframe').contents ().find ('form').submit ();
        }

        return false;
    });

    $('#id-add-cover-art\\.type').change(MB.AddCoverArt.hideConfirmer);
    $('#id-add-cover-art\\.page').change(MB.AddCoverArt.hideConfirmer);
});



