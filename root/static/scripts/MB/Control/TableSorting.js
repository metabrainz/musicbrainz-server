/* Copyright (C) 2009 Oliver Charles

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

(function(MB) {
    MB.Control.TableSorting = function(options) {
        var self = this;

        options = $.extend({
            dragComplete: undefined,
        }, options);

        var currentDrag;
        var currentOver;
        var dragTables, dropTables;
        var insertMethod;
        var oldTable;
        var rows;
        var startPos;

        var dragHelper = $(MB.html.table({
                             style: 'position: absolute',
                             'class': 'dragHelper'
                         }))
                           .appendTo('body')
                           .hide();
        

        function beginDrag(ev) {
            ev.preventDefault();

            // The cell the user clicked on isn't necessarily the row we want
            var possible = dragTables.children('tbody').children('tr');
            var el = ev.target;
            while (el) {
                var index = $.inArray(el, possible);
                if (index !== -1) {
                    break;
                }
                el = el.parentNode;
            }

            // We didn't find the row at all, cancel the drag event
            if (!el) {
                return;
            }

            $(document)
                .mousemove(mouseMove)
                .mouseup(endDrag);

            rows = dropTables.find('> tbody > tr');

            currentDrag = $(el);
            startPos = currentDrag.prevAll().length;
            
            oldTable = currentDrag.parent('table');
            dragHelper
                .append(currentDrag.clone())
                .show();

            mouseMove(ev);
        }

        function endDrag(ev) {
            $(document)
                .unbind('mousemove', mouseMove)
                .unbind('mouseup', endDrag);

            if(insertMethod === 'before') {
                currentOver.before(currentDrag);
            } else {
                currentOver.after(currentDrag);
            }

            currentOver.removeClass('overBelow').removeClass('overAbove');
            dragHelper.hide().empty();

            if (options.dragComplete) {
                options.dragComplete(currentDrag, oldTable, startPos, currentDrag.prevAll().length);
            }

            currentDrag = currentOver = oldTable = startPos = null;
        }

        function above(element, y) {
            return y <= (element.offset().top + (element.height() / 2));
        }

        function below(element, y) {
            return y >= (element.offset().top + (element.height() / 2));
        }

        function inside(element, y) {
            var top = element.offset().top;
            var bot = top + element.height();
            return y >= top && y <= bot;
        }

        function setOver(ov) {
            if (!ov) {
                return;
            }

            if (currentOver && ov[0] !== currentOver[0]) {
                currentOver
                    .removeClass('overAbove')
                    .removeClass('overBelow');
            }
            
            currentOver = ov;
            currentOver
                .removeClass(insertMethod === 'before' ? 'overBelow' : 'overAbove')
                .addClass(insertMethod === 'after' ? 'overBelow' : 'overAbove'); 
        }

        function mouseMove(ev) {
            var mY = ev.pageY;
            var over = null;
            rows.each(function() {
                over = $(this);
                if(over === currentDrag) { return false; }
                insertMethod = above(over, mY) ? 'before' : 'after';

                // Keep looping *until* we find a row that the mouse is in
                return !inside(over, mY);
            });

            setOver(over);
            dragHelper.css({
                top: mY,
                left: ev.pageX
            });
        }

        $.extend(self, {
            rebind: function() {
                dragTables.find(options.dragHandle).mousedown(beginDrag);
            },
            addDragSource: function(tab) {
                dragTables = dragTables ? dragTables.add(tab) : $(tab);
                dragTables.find(options.dragHandle).mousedown(beginDrag);
            },
            addDropTarget: function(tab) {
                dropTables = dropTables ? dropTables.add(tab) : $(tab);
            }
        });
    };
})(MB);