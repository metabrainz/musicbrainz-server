/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010,2011 MetaBrainz Foundation

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

    self.boxnumber = boxnumber;
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

    self.$name = self.$row.find ('input.name');
    self.$sortname = self.$row.find ('input.sortname');
    self.$comment = self.$row.find ('input.comment');
    self.$credit = self.$row.find ('input.credit');
    self.$join = self.$row.find ('input.join');
    self.$gid = self.$row.find ('input.gid');
    self.$id = self.$row.find ('input.id');
    self.$remove_artist = self.$row.find ('input.remove-artist-credit');

    self.clear = function () {
        self.$name.val ('').removeClass('error');
        self.$sortname.val ('');
        self.$comment.val ('');
        self.$credit.val ('');
        self.$join.val ('');
        self.$gid.val ('');
        self.$id.val ('');
        self.updateLookupPerformed ();
        self.$credit.val("");
    };

    self.render = function (data) {
        self.$name.val (data.artist.name).removeClass('error');
        self.container.clearError (self);
        self.$sortname.val (data.artist.sortname);
        self.$comment.val (data.artist.comment);
        self.$join.val (data.join_phrase || '');
        self.$gid.val (data.artist.gid);
        self.$id.val (data.artist.id);
        self.updateLookupPerformed ();
        self.$credit.val(data.name || data.artist.name);

        if (self.$join.val () !== '')
        {
            self.$join.data ('mb_automatic', false).removeClass ('mb_automatic');
        }
    };

    self.guessCase = function () {
        /* only GuessCase new artists, not those which have already been identified. */
        if (self.$gid.val () === "" && self.$id.val () === "")
        {
            self.$name.val (MB.GuessCase.artist.guess (self.$name.val ()));

            if (self.$credit.val () !== "")
            {
                self.$credit.val (MB.GuessCase.artist.guess (self.$credit.val ()));
            }
        }
    };

    self.updateLookupPerformed = function ()
    {
        if (self.$gid.val () && self.$id.val ())
        {
            self.$name.addClass ('lookup-performed');
        }
        else
        {
            self.$name.removeClass ('lookup-performed');
        }

        if (self.$gid.val () === MB.constants.VARTIST_GID ||
            self.$id.val () === String (MB.constants.VARTIST_ID))
        {
            if (!self.$name.hasClass ('various-artists'))
            {
                self.$name.addClass ('various-artists');
                self.$name.trigger ('VariousArtists');
            }
        }
        else
        {
            if (self.$name.hasClass ('various-artists'))
            {
                self.$name.removeClass ('various-artists');
                self.$name.trigger ('VariousArtists');
            }
        }
    };

    self.update = function(event, data) {
        if (data.name)
        {
            var oldName = self.$name.data("mb_selected_name");
            var oldCredit = self.$credit.val();
            self.$name.data ('mb_selected_name', data.name);
            self.$name.val (data.name).removeClass ('error');
            if (oldName === oldCredit) {
                self.$credit.val(data.name);
            }
            self.container.clearError (self);
            self.$sortname.val (data.sortname);
            self.$gid.val (data.gid);
            self.$id.val (data.id);
            self.updateLookupPerformed ();
            self.container.renderPreview();
        }

        event.preventDefault();
        return false;
    };

    self.lookupHook = function (request) {

        self.$name.removeClass ('error');

        return request;
    };

    self.nameBlurred = function(event) {
        /* mark the field as having an error if no lookup was
         * performed for this artist name. */
        if (self.$name.val() !== "" && self.$id.val() === "")
        {
            self.$name.addClass('error');
            self.container.error (self);
        }

        /* if the artist was cleared the user probably wants to delete it,
           make sure ids are emptied out too. */
        if (self.$name.val() === '')
        {
            self.$gid.val ('');
            self.$id.val ('');
            self.updateLookupPerformed ();
        }

        /* if the artist name was changed without performing another
         * lookup the identifiers should be cleared. */
        if (self.$name.data ('mb_selected_name')
            && (self.$name.val () !== self.$name.data ('mb_selected_name')))
        {
            self.$gid.val ('');
            self.$id.val ('');
            self.$name.data ('mb_selected_name', '');
            self.updateLookupPerformed ();
        }

        self.container.renderPreview();
    };

    self.creditBlurred = function(event) {
        if (self.$credit.val() === "") {
            self.$credit.val(self.$name.val());
        }

        self.container.renderPreview();
    };


    self.joinBlurred = function(event) {
        self.container.renderPreview();
    };

    /* A note on mb_automatic.
       =======================

       The behaviour created by following change event and controlled
       through the "mb_automatic" data variable on the input is
       somewhat similar to the behaviour of the placeholder attribute
       on the artist credit.

       The most important difference is that the value is not cleared
       on focus, this allows the user to clear the value and in this
       way submit an empty value.

       Because the behaviour is slightly different from a regular
       placeholder, the value is not displayed in gray.  This is
       unfortunate in the sense that it is not apparent to the user
       that the value is automatic -- the user will not be able to
       determine wether a ', ' or ' & ' value may change when
       adding/removing artist credits just from viewing the form.

       --warp.
    */

    self.joinChanged = function(event) {
        if (self.$join.data ('mb_automatic'))
        {
            /* this is the first value the user has entered into this field.

               If it is a simple word (such as "and") or an abbreviation
               (such as "feat.") it is likely that it should be surrounded
               by spaces.  Add those spaces automatically only this first
               time.
               Also standardise "feat." according to our guidelines.
            */

            var join = self.$join.val ();
            join = join.replace (/^\s*(feat\.?|ft\.?|featuring)\s*$/i,"feat.");
            if (join.match (/^[A-Za-z]*\.?$/))
            {
                self.$join.val (' ' + join + ' ');
            }
            else if(join.match(/^,$/)) {
                self.$join.val (', ');
            }
            else if(join.match(/^&$/)) {
                self.$join.val (' & ');
            }
        }

        /* this join phrase has been changed, it should no langer be automatic. */
        self.$join.data ('mb_automatic', false).removeClass ('mb_automatic');
    };

    self.isEmpty = function () {
        return (self.$name.val () === '' &&
                self.$credit.val () === '' &&
                self.$join.val () === '');
    };

    self.hasCredit = function () {
        return (self.$credit.val () !== '' &&
                self.$credit.val () !== self.$name.val ());
    };

    self.renderName = function () {
        var name = self.$credit.val ();
        if (name === '')
        {
            name = self.$name.val ();
        }

        if (!name)
        {
            name = '';
        }

        return name;
    };

    self.renderPreviewText = function () {
        return self.renderName () + self.$join.val ();
    };

    self.renderPreviewHTML = function () {
        if (self.$gid.val () === '')
        {
            return MB.utility.escapeHTML (self.renderName ()) +
                MB.utility.escapeHTML (self.$join.val ());
        }

        var hover = self.$sortname.val ();
        if (self.$comment.val () != '')
        {
            hover = hover + ", " + self.$comment.val ();
        }

        return '<a target="_blank" href="/artist/' +
            MB.utility.escapeHTML (self.$gid.val ()) + '" title="' +
            MB.utility.escapeHTML (hover) + '">' +
            MB.utility.escapeHTML (self.renderName ()) + '</a>' +
            MB.utility.escapeHTML (self.$join.val ());
    };

    self.remove = function () {
        if (self.container.removeArtistBox (self.boxnumber))
        {
            self.$row.remove ();
        }
    };

    self.setIndex = function(idx) {
        self.boxnumber = idx;
        var nameid = new RegExp ("artist_credit.names.[0-9]+");
        self.$row.find ("*").each (function (idx, element) {
            var item = $(element);
            if (item.attr ('id'))
            {
                item.attr ('id', item.attr('id').
                           replace(nameid, "artist_credit.names." + self.boxnumber));
            }
            if (item.attr ('name'))
            {
                item.attr ('name', item.attr('name').
                           replace(nameid, "artist_credit.names." + self.boxnumber));
            }
        });
    };


    /* showJoin will uncover a possibly hidden join phrase input, and if
       neccesary automatically set its value.  The pos argument should be
       the position counted from the end, so that the join phrases between
       the final two artist credits has position 1, the one before that
       position 2, etc...
    */
    self.showJoin = function (pos) {
        if (self.$join.data ('mb_automatic'))
        {
            self.$join.val (pos === 1 ? ' & ' : ', ');
        }

        self.$join.closest ('.join-container').show ();
    };

    self.hideJoin = function () {
        self.$join.closest ('.join-container').hide ();
        self.$join.val ('');

        /* join phrases are automatic on those join phrases which will only
           be shown when a new artist credit is added. */
        self.$join.data ('mb_automatic', true).addClass ('mb_automatic');
    };

    self.$name.bind('blur.mb', self.nameBlurred);
    self.$credit.bind('blur.mb', self.creditBlurred);
    self.$join.bind('blur.mb', self.joinBlurred);
    self.$join.bind('change.mb', self.joinChanged);
    self.$remove_artist.bind ('click.mb', self.remove);

    MB.Control.Autocomplete ({
        'input': self.$name,
        'entity': 'artist',
        'select': self.update,
        'clear': self.clear,
        'lookupHook': self.lookupHook,
        'allow_empty': true
    }).initialize ();

    if (obj === null)
    {
        /* we need to empty some variables if we created a new artist
         * credit by cloning the previous artist. */
        self.clear ();
    }
    else
    {
        if (self.$id.val () !== '')
        {
            self.$name.data ('mb_selected_name', self.$name.val ());
        }

        self.updateLookupPerformed ();
    }

    return self;
}

/* an ArtistCreditContainer is the base container for all the artist credits
   on a track or the release. */
MB.Control.ArtistCreditContainer = function($target, $container) {
    var self = MB.Object();

    self.box = [];
    self.$artist_input = $target;
    self.$container = $container;
    self.$preview = $container.find ('span.artist-credit-preview');
    self.$add_artist = self.$container.find ('.add-artist-credit');
    self.errors = {};

    self.initialize = function() {

        self.$container.find('.artist-credit-box').each(function(i) {
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
            'select': self.update,
            'clear': self.clear,
            'lookupHook': self.lookupHook,
            'allow_empty': true
        }).initialize ();

        self.$add_artist.bind ('click.mb', self.addArtistBox);
        self.$artist_input.bind ('blur.mb', self.targetBlurred);

        if (self.box[self.box.length - 1].$join.val () !== '')
        {
            /* This artist credit uses a join phrase on the final artist.  Add an
               artist credit to make sure that join phrase appears in the interface
               and isn't cleared. */
            self.addArtistBox ();
        }
        else
        {
            /* addArtistBox already calls updateJoinPhrases and renderPreview. so
               there is no need to call these unless addArtistBox wasn't called. */
            self.updateJoinPhrases ();
            self.renderPreview ();
        }

        if (self.box.length > 1 || self.box[0].hasCredit ())
        {
            /* multiple artists, disable main artist input. */
            self.disableTarget ();
        }
    };

    self.error = function (child) {
        self.errors[child.boxnumber] = true;
        self.$artist_input.addClass ('error');
    };

    self.clearError = function (child) {
        delete self.errors[child.boxnumber];

        if (MB.utility.keys (self.errors).length === 0)
        {
            self.$artist_input.removeClass ('error');
        }
    };

    self.update = function(event, data) {
        event.preventDefault();

        self.box[0].clear();
        self.box[0].update(event, data);
    };

    self.lookupHook = function (request) {

        self.$artist_input.removeClass ('error');

        return request;
    };

    self.addArtistBox = function () {
        var pos = self.box.length;
        var prev = self.box[pos-1];

        self.box[pos] = MB.Control.ArtistCredit(null, pos, self);
        self.box[pos].$row.insertAfter (prev.$row);

        self.updateJoinPhrases ();
        self.renderPreview ();

        return self.box[pos];
    };

    self.removeArtistBox = function (pos) {
        if (self.box.length < 2)
        {
            /* Do not allow the last box to be deleted. */
            return false;
        }

        self.box.splice (pos, 1);

        $.each (self.box, function (idx, box) {
            box.setIndex(idx);
        });
        self.updateJoinPhrases ();
        self.renderPreview ();

        return true;
    };

    self.updateJoinPhrases = function () {

        $.each (self.box, function (idx, box) {
            if (idx === self.box.length - 1)
            {
                box.hideJoin ();
            }
            else
            {
                box.showJoin (self.box.length - 1 - idx);
            }
        });

    };

    /* renderPreview updates both the main entity artist input field
       and the preview displayed inside the artist credit bubble. */
    self.renderPreview = function() {
        var previewText = [];
        var previewHTML = [];

        var lookupPerformed = true;
        $.each (self.box, function (idx, box) {
            if (!box.$gid.val () && !box.$id.val ())
            {
                lookupPerformed = false;
            }

            previewText.push (box.renderPreviewText ());
            previewHTML.push (box.renderPreviewHTML ());
        });

        self.$artist_input.val (previewText.join (""));
        if (self.$artist_input.val () === '')
        {
            self.$preview.html ('&nbsp;');
        }
        else
        {
            self.$preview.html (previewHTML.join (""));
        }

        self.$artist_input.trigger ('artistCreditChanged');

        if (lookupPerformed)
        {
            self.$artist_input.addClass ('lookup-performed');
        }
        else
        {
            self.$artist_input.removeClass ('lookup-performed');
        }

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

    self.guessCase = function () {
        $.each (self.box, function (idx, item) {
            item.guessCase();
        });

        self.renderPreview ();
    };

    self.isVariousArtists = function () {
        return self.box[0].$gid.val () === MB.constants.VARTIST_GID ||
            self.box[0].$id.val () === String (MB.constants.VARTIST_ID);
    };

    self.isEmpty = function () {
        var isEmpty = true;

        $.each (self.box, function (idx, box) {
            if (! box.isEmpty ())
            {
                isEmpty = false;
                return false;
            }
        });

        return isEmpty;
    };

    /**
     * This compares the current artist credit to the release artist
     * as it was rendered into a template on the tracklist tab of the
     * release editor.
     */
    self.isReleaseArtist = function () {
        $release_artist = $('table.tracklist-template tr.track-artist-credit');
        var isReleaseArtist = true;

        $release_artist.find ('tr.artist-credit-box').each (function (idx, row) {
            var box = self.box[idx];

            var box_credit = box.$credit.val ();
            if (box_credit === "")
            {
                box_credit = box.$name.val ();
            }

            var row_credit = $(row).find ('input.credit').val ();
            if (row_credit === "")
            {
                row_credit = $(row).find ('input.name').val ();
            }

            if (box_credit !== row_credit ||
                box.$name.val () !== $(row).find ('input.name').val () ||
                box.$gid.val () !== $(row).find ('input.gid').val () ||
                box.$join.val () !== $(row).find ('input.join').val ())
            {
                isReleaseArtist = false;
                return false;
            }
        });

        return isReleaseArtist;
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

            var artistname = _.clean(item.$name.val()),
                artistcredit = _.clean(item.$credit.val()) || artistname;

            ret.push({
                'artist': {
                    'name': artistname,
                    'id': item.$id.val (),
                    'gid': item.$gid.val ()
                },
                'name': artistcredit,
                'join_phrase': item.$join.val () || ''
            });
        });

        return { 'names': ret };
    };

    self.isComplex = function () {
        var ret = self.box.length > 1,
            box = self.box[0];

        if (!ret && box !== undefined) {
            ret = box.$id.val() || box.$gid.val();
        }

        return ret;
    };

    self.targetBlurred = function(event) {
        self.box[0].$name.val (self.$artist_input.val ());
        self.box[0].$name.trigger ('blur');
    };

    self.enableTarget = function () {
        /* multiple artists, do not enable main artist input. */
        if (self.box.length > 1 || self.box[0].hasCredit ())
            return;

        $target.prop('disabled', false);
        $target.closest ('span.autocomplete').removeClass ('disabled');
    };

    self.disableTarget = function () {
        $target.prop('disabled', true);
        $target.closest ('span.autocomplete').addClass ('disabled');
    };

    self.initialize ();

    return self;
};

/* an ArtistCreditRow is the container for all the artist credits on a track. */
MB.Control.ArtistCreditRow = function ($target, $container, $button) {
    var $box0 = $container.find('.artist-credit-box:eq(0)');

    /* clear any various artist values before initializing the artist credit. */
    if ($box0.find ('input.gid').val () === MB.constants.VARTIST_GID
        || $box0.find ('input.id').val () === MB.constants.VARTIST_ID)
    {
        $.each ('name sortname credit join gid id'.split (' '), function (idx, cls) {
            $box0.find ('input.' + cls).val ('');
        });
    }

    var self = MB.Control.ArtistCreditContainer ($target, $container);

    var $artistcolumn = $target.closest ('table.medium').find ('input.artistcolumn');
    var $credits = $target.closest ('tr.track').find ('a.credits-button');

    var parent_enableTarget = self.enableTarget;
    var parent_disableTarget = self.disableTarget;

    self.enableTarget = function () {
        if ($artistcolumn.is (':checked')) {
            parent_enableTarget ();
            $credits.show ();
        };
    };

    self.disableTarget = function (keep_credits) {
        parent_disableTarget ();
        if (keep_credits)
            return;

        $credits.hide ();
    };

    $container.bind ('bubbleOpen.mb', function (event) {
        /* do not open the bubble if the artist column isn't enabled. */
        if ($artistcolumn.is (':checked'))
        {
            self.disableTarget (1);
        }
        else
        {
            event.preventDefault ();
            return false;
        }
    });

    $container.bind ('bubbleClose.mb', function (event) {
        self.enableTarget ();
    });


    if ($artistcolumn.is (':checked')) {
        self.enableTarget ();
    }
    else
    {
        self.disableTarget ();
    }

    return self;
};

/* ArtistCreditVertical is the container for all the artist credits on the
   release (which appears on the information page). */
MB.Control.ArtistCreditVertical = function ($target, $container, $button) {
    var self = MB.Control.ArtistCreditContainer ($target, $container);

    $container.bind ('bubbleOpen.mb', function (event) {
        $button.val (' << ');
        self.disableTarget ();
    });

    $container.bind ('bubbleClose.mb', function (event) {
        $button.val (' >> ');
        self.enableTarget ();
    });

    return self;
}



/* A generic artist credit initialize function for use outside the
   release editor. */
MB.Control.initialize_artist_credit = function (bubbles) {

    var $button = $('input#open-ac');
    var $target = $('input#entity-artist');
    var $container = $('div.artist-credit.bubble');

    bubbles.add ($button, $container);
    MB.Control.ArtistCreditVertical ($target, $container, $button);
};

