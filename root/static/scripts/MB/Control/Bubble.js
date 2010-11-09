/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010 Kuno Woudt <kuno@frob.nl>
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

jQuery.fn.borderRadius = function (radius) {

    this.each (function () {

        var elem = jQuery (this);

        if (typeof radius === 'number')
        {
            radius = '' + radius + 'px';
        }

        if (typeof radius === 'string')
        {
            elem.css ('border-radius', radius);
            elem.css ('-webkit-border-radius', radius);
            elem.css ('-moz-border-radius', radius);
            return;
        }

        if (typeof radius !== 'object')
            return;

        jQuery.each ([ 'top', 'bottom' ], function (i, ver) {
            jQuery.each (['left', 'right' ], function (j, hor) {

                var value = radius[ver + '-' + hor];
                if (!value)
                    return;

                elem.css ('border-' + ver + '-' + hor + '-radius', value);
                elem.css ('-webkit-border-' + ver + '-' + hor + '-radius', value);
                elem.css ('-moz-border-radius-' + ver + hor, value);
            });
        });
    });

    return this;
};

/* BubbleBase provides the common code for speech bubbles as used
   on the Release Editor.
*/
MB.Control.BubbleBase = function (parent, target, content, offset) {
    var self = MB.Object ();

    self.parent = parent;
    self.offset = offset ? offset : 20;
    self.target = $(target);
    self.content = $(content);
    self.container = self.content.parent ();

    self.target.data ('bubble', self);

    var tail = function () {
        self.balloon0.css ('position', 'absolute').css ('z-index', '1');

        self.balloon1.css ('position', 'absolute')
            .css ('padding', '0')
            .css ('margin', '0');

        self.balloon2.css ('float', 'left')
            .css ('background', '#fff')
            .css ('padding', '0')
            .css ('margin', '0')
            .css ('border-style', 'solid')
            .css ('border-color', '#999');

        self.balloon3.css ('float', 'left')
            .css ('background', '#fff')
            .css ('padding', '0')
            .css ('margin', '0')
            .css ('border-style', 'solid')
            .css ('border-color', '#999');
    };

    var show = function () {
        self.parent.hideOthers (self);
        self.container.show ();
        self.move ();
        self.tail ();
        self.visible = true;
    };

    var hide = function () {
        self.container.hide ();
        self.visible = false;
    };

    var toggle = function () {
        if (self.visible)
        {
            self.hide ();
        }
        else
        {
            self.show ();
        }
    };

    self.visible = false;

    self.move = function () {};
    self.tail = tail;
    self.show = show;
    self.hide = hide;
    self.toggle = toggle;

    self.balloon0 = $('<div>');
    self.balloon1 = $('<div>');
    self.balloon2 = $('<div>');
    self.balloon3 = $('<div>');

    self.balloon0.append (
        self.balloon1.append (self.balloon2).append (self.balloon3)
    ).insertBefore (self.content);

    return self;
};

/* BubbleDocBase turns a documentation div into a bubble pointing at an
   input to the left of it on the Release Editor information tab.

   It also positions the bubble vertically when 'move ()' is called.
   If the target input can move (e.g. because other inputs are
   inserted above it) make sure to call move() again whenever that
   input is focused and the documentation div displayed.
*/
MB.Control.BubbleDocBase = function (parent, target, content) {
    var self = MB.Control.BubbleBase (parent, target, content);

    var parent_tail = self.tail;
    var parent_hide = self.hide;

    var move = function () {

        self.container.show ();

        var top = self.target.offset ().top - 23;
        var left = self.content.offset ().left;
        var height = self.content.height ();
        var width = self.content.width ();

        if (height < 42)
        {
            height = 42;
        }

        self.container.css ('position', 'absolute');
        self.container.css ('width', width);
        self.container.css ('min-height', height);
        self.content.css ('min-height', height);
        self.content.css ('width', '100%');
        self.container.offset ({ 'top': top, 'left': left });

        var pageBottom = self.page.offset ().top + self.page.outerHeight ();
        var bubbleBottom = self.container.offset ().top + self.container.outerHeight ();

         if (pageBottom < bubbleBottom)
         {
             var newHeight = self.page.outerHeight () + bubbleBottom - pageBottom + 10;

             self.page.css ('min-height', newHeight);
         }
    };

    var tail = function () {

        parent_tail ();

        var left = self.content.offset ().left;
        var top = self.target.offset ().top - 23 + self.target.height () / 2;

        self.balloon0.offset ({ 'top': top, 'left': left });

        self.balloon1.css ('background', '#eee')
            .css ('width', '14px')
            .css ('height', '42px')
            .css ('left', '-12px')
            .css ('top', '10px');

        self.balloon2.borderRadius ({ 'bottom-right': '12px' })
            .css ('width', '12px')
            .css ('height', '20px')
            .css ('border-width', '0 1px 1px 0');

        self.balloon3.borderRadius ({ 'top-right': '12px' })
            .css ('width', '12px')
            .css ('height', '20px')
            .css ('border-width', '1px 1px 0 0');

    };

    var hide = function () {
        parent_hide ();

        self.page.css ('min-height', '');
    };


    self.page = $('#page');

    self.move = move;
    self.tail = tail;
    self.hide = hide;

    return self;
};


MB.Control.BubbleDoc = function (parent, target, content) {
    var self = MB.Control.BubbleDocBase (parent, target, content);

    var parent_show = self.show;
    var parent_hide = self.hide;

    var show = function () {
        parent_show ();

        if (self.button)
        {
            self.target.text (MB.text.Done);
        }
    };

    var hide = function () {
        parent_hide ();

        if (self.button)
        {
            self.target.text (MB.text.Change);
        }
    };

    var initialize = function () {

        self.button = false;
        self.textinput = false;

        if (self.target.filter ('a').length ||
            self.target.filter ('input[type=submit]').length ||
            self.target.filter ('input[type=button]').length)
        {
            self.button = true;
        }
        else if (self.target.filter ('input[type=text]').length ||
                 self.target.filter ('textarea').length)
        {
            self.textinput = true;
        }

        if (self.button)
        {
            /* show content when a button is pressed. */
            self.target.click (function (event) {
                self.toggle ();
                event.preventDefault ();
            });
        }

        if (self.textinput)
        {
            /* show content when an input field is focused. */
            self.target.focus (function (event) {

                self.show ();
            });
        }
    };

    self.initialize = initialize;

    return self;
};


/* BubbleRow turns the div inside a table row into a bubble pointing
   at one of the inputs in the preceding row. */
MB.Control.BubbleRow = function (parent, target, content, offset) {
    var self = MB.Control.BubbleBase (parent, target, content, offset);

    var parent_tail = self.tail;

    var tail = function () {

        var pos = self.offset;

        parent_tail ();

        if (self.target.css ('text-align') === 'right')
        {
            pos = self.target.width () - self.offset;
        }

        self.balloon0.offset ({
            left: self.target.offset ().left + pos,
            top: self.content.offset ().top - 14,
        });

        self.balloon1.css ('width', '42px')
            .css ('height', '15px')
            .css ('background', '#fff');

        self.balloon2.borderRadius ({ 'bottom-right': '12px' })
            .css ('background', '#eee')
            .css ('width', '20px')
            .css ('height', '14px')
            .css ('border-width', '0 1px 1px 0');

        self.balloon3.borderRadius ({ 'bottom-left': '12px' })
            .css ('background', '#eee')
            .css ('width', '20px')
            .css ('height', '14px')
            .css ('border-width', '0 0 1px 1px');
    };

    self.tail = tail;

    return self;
};


/* BubbleCollection is a containter for all the BubbleRows or
   BubbleDocs on a page.  It's main purpose is to allow a Bubble to
   hide any other active bubbles when it is to be shown.
*/
MB.Control.BubbleCollection = function (targets, contents) {
    var self = MB.Object ();

    var hideOthers = function (bubble) {
        if (self.active)
        {
            self.active.hide ();
        }

        self.active = bubble;
    };

    var hideAll = function () {
        self.hideOthers (null);
    };

    var add = function (target, contents) {
        MB.Control.BubbleDoc (self, target, contents).initialize ();
    };

    var initialize = function ()
    {
        var tmp = [];

        if (targets && contents)
        {
            targets.each (function (idx, data) { tmp.push ({ 'button': data }); });
            contents.each (function (idx, data) { tmp[idx].doc = data; });

            $.each (tmp, function (idx, data) {
                MB.Control.BubbleDoc (self, data.button, data.doc).initialize ();
            });
        }
    }

    self.hideOthers = hideOthers;
    self.hideAll = hideAll;
    self.add = add;
    self.initialize = initialize;
    self.active = false;

    self.initialize ();

    return self;
};
