/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2010 Kuno Woudt <kuno@frob.nl>
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
MB.Control.BubbleBase = function (parent, $target, $content, offset) {
    var self = MB.Object ();

    self.parent = parent;
    self.offset = offset ? offset : 20;
    self.$target = $target;
    self.$content = $content;
    self.$container = self.$content.parent ();

    self.$target.data ('bubble', self);

    self.tail = function () {
        self.$balloon0.css ('position', 'absolute').css ('z-index', '1');

        self.$balloon1.css ('position', 'absolute')
            .css ('padding', '0')
            .css ('margin', '0');

        self.$balloon2.css ('float', 'left')
            .css ('background', '#fff')
            .css ('padding', '0')
            .css ('margin', '0')
            .css ('border-style', 'solid')
            .css ('border-color', '#999');

        self.$balloon3.css ('float', 'left')
            .css ('background', '#fff')
            .css ('padding', '0')
            .css ('margin', '0')
            .css ('border-style', 'solid')
            .css ('border-color', '#999');
    };

    self.show = function () {
        if (self.visible)
            return;

        var ev = $.Event ('bubbleOpen');
        self.$content.trigger (ev);

        if (ev.isDefaultPrevented ())
        {
            return ev;
        }

        self.parent.hideOthers (self);
        self.$container.show ();
        self.move ();
        self.tail ();
        self.visible = true;
    };

    self.hide = function () {
        if (!self.visible)
            return;

        var ev = $.Event ('bubbleClose');
        self.$content.trigger (ev);

        if (ev.isDefaultPrevented ())
        {
            return ev;
        }

        self.$container.hide ();
        self.visible = false;
    };

    self.toggle = function (showOrHide) {
        if (showOrHide === true)
        {
            self.show ();
        }
        else if (showOrHide === false)
        {
            self.hide ();
        }
        else if (self.visible)
        {
            self.hide ();
        }
        else
        {
            self.show ();
        }
    };

    self.initialize = function () {
        self.button = false;
        self.textinput = false;

        if (self.$target.filter ('a').length ||
            self.$target.filter ('input[type=submit]').length ||
            self.$target.filter ('input[type=button]').length ||
            self.$target.filter ('img').length)
        {
            self.button = true;
        }
        else if (self.$target.filter ('input[type=text]').length ||
                 self.$target.filter ('textarea').length ||
                 self.$target.filter ('select').length)
        {
            self.textinput = true;
        }

        if (self.button)
        {
            /* show content when a button is pressed. */
            self.$target.bind ('click.mb', function (event) {
                self.toggle ();
                event.preventDefault ();
            });
        }

        if (self.textinput)
        {
            /* show content when an input field is focused. */
            self.$target.bind ('focus.mb', function (event) {

                self.show ();
            });
        }

        return self;
    };


    self.visible = false;

    self.move = function () {};

    self.$balloon0 = $('<div>');
    self.$balloon1 = $('<div>');
    self.$balloon2 = $('<div>');
    self.$balloon3 = $('<div>');

    self.$balloon0.append (
        self.$balloon1.append (self.$balloon2).append (self.$balloon3)
    ).insertBefore (self.$content);

    return self;
};

/* BubbleDocBase turns a documentation div into a bubble pointing at an
   input to the left of it on the Release Editor information tab.

   It also positions the bubble vertically when 'move ()' is called.
   If the target input can move (e.g. because other inputs are
   inserted above it) make sure to call move() again whenever that
   input is focused and the documentation div displayed.
*/
MB.Control.BubbleDocBase = function (parent, $target, $content) {
    var self = MB.Control.BubbleBase (parent, $target, $content);

    var parent_tail = self.tail;
    var parent_hide = self.hide;

    self.move = function () {
        self.$container.show ();

        self.$container.position({
            my: "left+37 top-23",
            at: "right top",
            of: self.$target,
            collision: "none none"
        });

        /* FIXME: figure out why opera doesn't position this correctly on the
           first call and fix that issue or submit a bug report to opera. */
        if (window.opera)
        {
            self.$container.position({
                my: "left+37 top-23",
                at: "right top",
                of: self.$target,
                collision: "none none"
            });
        }

        var height = self.$content.height ();

        if (height < 42)
        {
            height = 42;
        }

        self.$container.css ('min-height', height);
        self.$content.css ('min-height', height);

        var pageBottom = self.$page.offset ().top + self.$page.outerHeight ();
        var bubbleBottom = self.$container.offset ().top + self.$container.outerHeight ();

        if (pageBottom < bubbleBottom)
        {
            var newHeight = self.$page.outerHeight () + bubbleBottom - pageBottom + 10;

            self.$page.css ('min-height', newHeight);
        }
    };

    self.tail = function () {

        parent_tail ();

        var targetY = self.$target.offset ().top - 24 + self.$target.height () / 2;
        var offsetY = targetY - self.$content.offset ().top;

        self.$balloon0.position({
            my: "right top+" + Math.floor(offsetY),
            at: "left top",
            of: self.$content
        });

        self.$balloon1.css ('background', '#eee')
            .css ('width', '14px')
            .css ('height', '42px')
            .css ('left', '-12px')
            .css ('top', '10px');

        self.$balloon2.borderRadius ({ 'bottom-right': '12px' })
            .css ('width', '12px')
            .css ('height', '20px')
            .css ('border-width', '0 1px 1px 0');

        self.$balloon3.borderRadius ({ 'top-right': '12px' })
            .css ('width', '12px')
            .css ('height', '20px')
            .css ('border-width', '1px 1px 0 0');
    };

    self.hide = function () {
        parent_hide ();

        self.$page.css ('min-height', '');
    };

    self.$page = $('#page');

    return self;
};

/* There is no longer a difference between BubbleDocBase and BubbleDoc. --warp. */
MB.Control.BubbleDoc = MB.Control.BubbleDocBase;

/* BubbleRow turns the div inside a table row into a bubble pointing
   at one of the inputs in the preceding row. */
MB.Control.BubbleRow = function (parent, $target, $acrow, offset) {
    var $content = $acrow.find ('.bubble');
    var self = MB.Control.BubbleBase (parent, $target, $content, offset);

    self.$container = $acrow;

    var parent_tail = self.tail;

    self.tail = function () {
        parent_tail ();

        var $input = self.$target.closest ('td').prev ().find ('input');

        var targetX = $input.offset ().left + 24;
        var offsetX = targetX - self.$content.offset ().left;

        self.$balloon0.position({
            my: "left+" + parseInt(offsetX, 10) + " bottom+1",
            at: "left top",
            of: self.$content,
            collision: "none",
            'using': function (props) {
                /* fix unstable positioning due to fractions. */
                props.top = parseInt (props.top, 10);
                props.left = parseInt (props.left, 10);
                $(this).css (props);
            }
        });

        self.$balloon1.css ('background', '#eee')
            .css ('width', '42px')
            .css ('height', '14px')
            .css ('left', '10px')
            .css ('top', '-12px');

        self.$balloon2.borderRadius ({ 'bottom-right': '12px' })
            .css ('width', '20px')
            .css ('height', '12px')
            .css ('border-width', '0 1px 1px 0');

        self.$balloon3.borderRadius ({ 'bottom-left': '12px' })
            .css ('width', '20px')
            .css ('height', '12px')
            .css ('border-width', '0 0 1px 1px');
    };

    return self;
};


/* BubbleCollection is a containter for all the BubbleRows or
   BubbleDocs on a page.  It's main purpose is to allow a Bubble to
   hide any other active bubbles when it is to be shown.
*/
MB.Control.BubbleCollection = function ($targets, $contents) {
    var self = MB.Object ();

    self.bubbles = [];

    self.add = function ($targets, $contents) {

        var tmp = [];
        var bubble = null;

        if ($targets && $contents)
        {
            $targets.each (function (idx, data) { tmp.push ({ 'button': data }); });
            $contents.each (function (idx, data) { tmp[idx].doc = data; });
            $.each (tmp, function (idx, data) {
                bubble = self.type (self, $(data.button), $(data.doc)).initialize ();
                self.bubbles.push (bubble);
            });
        }

        /* .add() used to accept only a single target + container, it may still be
         * called like that, and the caller will expect that bubble to be returned.
         */
        return bubble;
    };

    self.hideOthers = function (bubble) {
        if (self.active)
        {
            self.active.hide ();
        }

        self.active = bubble;
    };

    self.hideAll = function () {
        self.hideOthers (null);
    };

    self.setType = function (type) {
        self.type = type;
    };

    self.resetType = function (type) {
        self.type = MB.Control.BubbleDoc;
    };

    self.initialize = function ()
    {
        var tmp = [];

        self.resetType ();
        self.add ($targets, $contents);
    }

    self.active = false;

    self.initialize ();

    return self;
};

