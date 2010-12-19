/* Copyright (C) 2010 Kuno Woudt

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

MB.debug = (MB.debug) ? MB.debug : {};

MB.debug._waitFor_interval = 20;

/* Wait for something to be true before calling another function. */
MB.debug.waitFor = function (check, callback) {

    if (check ())
    {
        callback ();
        return;
    }

    setTimeout (function () { MB.debug.waitFor (check, callback); },
                MB.debug._waitFor_interval);
};

MB.debug.waitForElement = function (selector, callback) {

    MB.debug.waitFor (
        function () { return jQuery (selector).length; },
        function () { callback (jQuery (selector)) });
};



