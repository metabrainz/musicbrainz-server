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

MB.Control.ArtistCredit = function(obj, boxnumber, container) {
    var self = MB.Object();

    self.container = container;

    if (obj === null)
    {
        self.$row = self.container.box[boxnumber - 1].$row.clone ();

        var nameid = new RegExp ("artist_credit.names.[0-9]+");
        self.$row.find ("*").each (function (idx, element) {
            var item = $(element);
            if (item.attr ('id'))
            {
                item.attr ('id', item.attr('id').
                           replace(nameid, "artist_credit.names." + boxnumber));
            }
            if (item.attr ('name'))
            {
                item.attr ('name', item.attr('name').
                           replace(nameid, "artist_credit.names." + boxnumber));
            }
        });
    }
    else
    {
        self.$row = obj;
    }

    self.boxnumber = boxnumber;
    self.$name = self.$row.find ('input.name');
    self.$sortname = self.$row.find ('input.sortname');
    self.$credit = self.$row.find ('input.credit');
    self.$join = self.$row.find ('input.join');
    self.$gid = self.$row.find ('input.gid');
    self.$id = self.$row.find ('input.id');
    self.$remove_artist = self.$row.find ('input.remove-artist-credit');

    self.clear = function () {
        self.$name.val ('');
        self.$sortname.val ('');
        self.$credit.val ('');
        self.$join.val ('');
        self.$gid.val ('');
        self.$id.val ('');
    };

    self.render = function (data) {

        self.$name.val (data.artist_name).removeClass('error');
        self.$sortname.val (data.sortname);
        self.$join.val (data.join || '');
        self.$credit.val (data.name);
        self.$gid.val (data.gid);
        self.$id.val (data.id);

        if (self.$credit.val () === '')
        {
            self.$credit.val (data.name);
        }

    };

    self.update = function(event, data) {

        if (data.name)
        {
            self.$name.val (data.name).removeClass ('error');
            self.$sortname.val (data.sortname);
            self.$gid.val (data.gid);
            self.$id.val (data.id);

            if (self.$credit.val () === '')
            {
                self.$credit.val (data.name);
            }

            self.container.renderPreview();
        }

        event.preventDefault();
        return false;
    };

    self.nameBlurred = function(event) {
        /* mark the field as having an error if no lookup was
         * performed for this artist name. */
        if (self.$name.val() !== "" && self.$id.val() === "")
        {
            self.$name.addClass('error');
        }

        /* if the artist was cleared the user probably wants to delete it,
           make sure ids are emptied out too. */
        if (self.$name.val() === '')
        {
            self.$gid.val ('');
            self.$id.val ('');
        }

        self.container.renderPreview();
    };

    self.creditBlurred = function(event) {
        self.container.renderPreview();
    };

    self.joinBlurred = function(event) {
        self.container.renderPreview();
    };

    self.isEmpty = function () {
        return (self.$name.val () === '' &&
                self.$credit.val () === '' &&
                self.$join.val () === '');
    };

    self.renderPreviewText = function () {
        return self.$credit.val () + self.$join.val ();
    };

    self.renderPreviewHTML = function () {
        return '<a target="_blank" href="/artist/' + self.$gid.val () +
            '" title="' + self.$sortname.val () + '">' +
            self.$credit.val () + '</a>' + self.$join.val ();
    };

    self.remove = function () {
        if (self.container.removeArtistBox (self.boxnumber))
        {
            self.$row.remove ();
        }
    };

    self.showJoin = function () {
        self.$join.closest ('.join-container').show ();
    };

    self.hideJoin = function () {
        self.$join.closest ('.join-container').hide ();
    };

    self.$join.bind('blur.mb', self.joinBlurred);
    self.$name.bind('blur.mb', self.nameBlurred);
    self.$credit.bind('blur.mb', self.creditBlurred);
    self.$remove_artist.bind ('click.mb', self.remove);

    MB.Control.Autocomplete ({
        'input': self.$name,
        'entity': 'artist',
        'select': self.update
    });

    if (obj === null)
    {
        /* we need to empty some variables if we created a new artist
         * credit by cloning the previous artist. */
        self.clear ();
    }

    return self;
}

/* an ArtistCreditContainer is the base container for all the artist credits
   on a track or the release. */
MB.Control.ArtistCreditContainer = function($input, $artistcredits) {
    var self = MB.Object();

    self.box = [];
    self.$artist_input = $input;
    self.$artistcredits = $artistcredits;
    self.$preview = $artistcredits.find ('span.artist-credit-preview');
    self.$add_artist = self.$artistcredits.find ('input.add-artist-credit');

    self.initialize = function() {

        self.$artistcredits.find('.artist-credit-box').each(function(i) {
            self.box[i] = MB.Control.ArtistCredit($(this), i, self);
        });

        if (self.box.length == 0)
        {
            throw MB.utility.exception (
                'ArtistCreditBoxNotFound',
                'Atleast one div.artist-credit-box is required, none were found.');
        }

        MB.Control.Autocomplete ({
            'input': self.$artist_input,
            'entity': 'artist',
            'select': self.update
        });

        self.$add_artist.bind ('click.mb', self.addArtistBox);

        self.updateJoinVisibility ();
        self.renderPreview ();
    };

    self.update = function(event, data) {
        event.preventDefault();
        self.box[0].update(event, data);
    };

    self.addArtistBox = function () {
        var pos = self.box.length;
        var prev = self.box[pos-1];

        self.box[pos] = MB.Control.ArtistCredit(null, pos, self);
        self.box[pos].$row.insertAfter (prev.$row);

        prev.showJoin ();
        self.box[pos].hideJoin ();

        return self.box[pos];
    };

    self.removeArtistBox = function (pos) {
        if (self.box.length < 2)
        {
            /* Do not allow the last box to be deleted. */
            return false;
        }

        self.box.splice (pos, 1);

        $.each (self.box, function (idx, box) { box.boxnumber = idx; });
        self.updateJoinVisibility ();

        return true;
    };

    self.updateJoinVisibility = function () {

        $.each (self.box, function (idx, box) {
            if (idx === self.box.length - 1)
            {
                box.hideJoin ();
            }
            else
            {
                box.showJoin ();
            }
        });

    };

    /* renderPreview updates both the main entity artist input field
       and the preview displayed inside the artist credit bubble. */
    self.renderPreview = function() {
        var previewText = [];
        var previewHTML = [];

        $.each (self.box, function (idx, box) {
            previewText.push (box.renderPreviewText ());
            previewHTML.push (box.renderPreviewHTML ());
        });

        self.$artist_input.val (previewText.join (""));
        self.$preview.html (previewHTML.join (""));
    };

    self.render = function (data) {
        $.each (self.box, function (idx, item) {
             item.clear();
        });

        $.each (data.names, function (idx, item) {
            if (self.box.length === idx)
            {
                self.addArtistBox (idx);
            }

            self.box[idx].render (item);
        });

        self.renderPreview ();
    };

    self.isVariousArtists = function () {
        return self.box[0].$gid.val () === MB.constants.VARTIST_GID;
    };

    self.clear = function () {
        $.each (self.box, function (idx, item) {
            item.clear ();
        });

        self.renderPreview ();
    };

    self.toData = function () {
        var ret = [];

        $.each (self.box, function (idx, item) {
            if(item.isEmpty ())
                return;

            ret.push({
                'artist_name': item.$name.val (),
                'name': item.$credit.val (),
                'id': item.$id.val (),
                'gid': item.$gid.val (),
                'join': item.$join.val () || ''
            });
        });

        return { 'names': ret, 'preview': self.$artist_input.val() };
    };

    self.initialize ();

    return self;
};

/* an ArtistCreditRow is the container for all the artist credits on a track. */
MB.Control.ArtistCreditRow = function ($target, $container, $button) {
    var self = MB.Control.ArtistCreditContainer ($target, $container);

    $container.bind ('bubbleOpen.mb', function () {
        $target.attr ('disabled', 'disabled');
    });

    $container.bind ('bubbleClose.mb', function () {
        $target.removeAttr ('disabled');
    });


    return self;
};

/* ArtistCreditVertical is the container for all the artist credits on the
   release (which appears on the information page). */
MB.Control.ArtistCreditVertical = function ($target, $container, $button) {
    var self = MB.Control.ArtistCreditContainer ($target, $container);

    $container.bind ('bubbleOpen.mb', function () {
        $button.val (' << ');
        $target.attr ('disabled', 'disabled');
    });

    $container.bind ('bubbleClose.mb', function () {
        $button.val (' >> ');
        $target.removeAttr ('disabled');
    });

    return self;
}



/* A generic artist credit initialize function for use outside the
   release editor. */
MB.Control.initialize_artist_credit = function () {

    var $target = $('input#entity-artist');
    var $button = $('input#open-ac');
    var $container = $('div.artist-credit');

    MB.Control.BubbleCollection ($button, $container);
    MB.Control.ArtistCreditVertical ($target, $container, $button);
};

