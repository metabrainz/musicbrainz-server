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

MB.Control.ReleaseEdits = function ($edits) {
    var self = MB.Object ();

    self.artistChanges = function (from, to) {

        var changes = false;

        $.each (to.names, function (idx, edited) {

            var current = from.names[idx];

            if ((!current && edited) || (current && !edited))
            {
                changes = true;
                return false;
            }
            else if (current && edited)
            {
                if (parseInt (current.id) !== parseInt (edited.id))
                {
                    changes = true;
                    return false;
                }

                var properties = [ 'artist_name', 'name', 'join', 'gid' ];
                $.each (properties, function (idx, key) {
                    if (!current[key])
                    {
                        current[key] = '';
                    }

                    if (current[key] !== edited[key])
                    {
                        changes = true;
                        return false;
                    }
                });
            }

        });

        return changes;
    };

    self.trackChanges = function (from, to) {

        var changes = false;

        if (self.artistChanges (from['artist_credit'], to['artist_credit']))
        {
            return true;
        }

        $.each ([ 'position', 'name', 'length', 'deleted' ], function (idx, key) {

            if (from[key] !== to[key])
            {
                changes = true;
                return false;
            }

        });

        return changes;
    };

    self.artistCreditToDeprecatedFormat = function (ac) {
        var ret = [];
        $.each (ac.names, function (idx, credit) {
            if (credit.artist_name)
            {
                /* already in the deprecated format. */
                ret.push (credit);
            }
            else
            {
                ret.push ({
                    'artist_name': credit.artist.name,
                    'gid': credit.artist.gid,
                    'id': credit.artist.id,
                    'join': credit.join_phrase,
                    'name': credit.name
                });
            }
        });

        ac.names = ret;
        return ac;
    };


    self.saveEdits = function (tracklist, tracks) {

        var changes = false;
        var edited_tracklist = [];

        $.each (tracks, function (idx, trk) {
            var from = tracklist[idx];

            var to = {
                'name': trk.$title.val (),
                'length': trk.$length.val (),
                'artist_credit': trk.artist_credit.toData ()
            };

            to['edit_sha1'] = b64_sha1 (MB.utility.structureToString (to));
            to['position'] = trk.$position.val ();
            to['deleted'] = trk.$deleted.val ();

            edited_tracklist.push (to);

            if (from)
            {
                from.position = '' + (idx + 1);
                from.deleted = "0";
                from.artist_credit = self.artistCreditToDeprecatedFormat (from.artist_credit);
            }

            if (!from || self.trackChanges (from, to))
            {
                changes = true;
            }
        });

        if (changes)
        {
            self.$edits.val (JSON.stringify (edited_tracklist));
        }
    };

    self.loadEdits = function () {
        var data = self.$edits.val ();

        if (data)
        {
            data = JSON.parse (data);
        }

        return data;
    };

    self.clearEdits = function () {
        self.$edits.val ('');
    };

    self.$edits = $edits;

    return self;
};
