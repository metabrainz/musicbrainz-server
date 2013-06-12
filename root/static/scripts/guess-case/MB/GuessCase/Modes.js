/*
  This file is part of MusicBrainz, the open internet music database.
  Copyright (c) 2005 Stefan Kestenholz (keschte)
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

MB.GuessCase = MB.GuessCase ? MB.GuessCase : {};

/**
 * GcModes class
 *
 **/
MB.GuessCase.Modes = function (language) {
    var self = MB.Object ();

    /**
     * Gets the currently selected element from the mode dropdown.
     **/
    var getMode = function () {
        var mode = self.dropdown.find ('option:selected').data ('mb.guesscase.mode');
        return mode || MB.GuessCase.Mode.Dummy ();
    };

    /**
     * Set mode.
     **/
    var setMode = function (mode) {
        self.dropdown.find ('option:selected').prop ('selected', false);
        self.dropdown.find ('option:contains(' + mode + ')').prop ('selected', true);

        return getMode ();
    };

    /**
     * Update the help text displayed when a mode is selected.
     **/
    var updateMode = function (event) {
        var mode = self.getMode ();

        $('#gc-help').html (mode.getDescription ());
        $.cookie ('guesscase_mode', mode.getName (), { path: '/', expires: 365 });
    };

    /**
     * Fill the mode dropdown with options from the mode list.
     */
    var initialize = function () {

        self.dropdown = $('#gc-mode');
        self.dropdown.empty ();

        $.each (['English', 'Sentence', 'French'], function (idx, mode) {
            if (typeof MB.GuessCase.Mode[mode] !== "undefined")
            {
                self.modes.push (MB.GuessCase.Mode[mode] (self));
            }
        });

        var selected = $.cookie ('guesscase_mode');
        if (!selected && self.modes.length)
        {
            selected = self.modes[0].getName ();
        }

        $.each (self.modes, function (idx, mode) {
            var option = $('<option>');
            option.text (mode.getName ());
            option.data ('mb.guesscase.mode', mode);
            if (mode.getName () === selected)
            {
                option.prop('selected', true);
            }

            self.dropdown.append (option);
        });

        self.dropdown.bind ('change.mb', self.updateMode);

        $('#gc-help').html (self.getMode ().getDescription ());
    };

    self.getMode = getMode;
    self.setMode = setMode;
    self.updateMode = updateMode;

    self.artist_mode = (typeof MB.GuessCase.Mode.Artist === "undefined") ?
        null : MB.GuessCase.Mode.Artist (self);
    self.dropdown = $('#gc-mode');

    self.modes = [];

    $(document).ready (function () {
        initialize ();
    });

    return self;
};

