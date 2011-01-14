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

MB.Control.AutocompleteRecording = function (options) {

    var formatItem = function (ul, item) {
        var a = $("<a>").text (item.name);

        a.append (' - <span class="autocomplete-artist">' + item.artist + '</span>');

        if (item.releasegroups)
        {
            var rgs = {};
            /* don't display the same name multiple times. */
            $.each (item.releasegroups, function (idx, item) {
                rgs[item.name] = item.name;
            });

            a.append ('<br /><span class="autocomplete-appears">appears on: '
                      + MB.utility.keys (rgs).join (", ") + '</span>');
        }

        if (item.comment)
        {
            a.append ('<br /><span class="autocomplete-comment">(' + item.comment + ')</span>');
        }

        if (item.isrcs.length)
        {
            a.append ('<br /><span class="autocomplete-isrcs">isrcs: '
                      + item.isrcs.join (", ") + '</span>');
        }

        return $("<li>").data ("item.autocomplete", item).append (a).appendTo (ul);
    };

    options.entity = 'recording';
    options.formatItem = options.formatItem ? options.formatItem : formatItem; 

    var self = MB.Control.Autocomplete (options);

    return self;
};