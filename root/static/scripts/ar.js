/* Copyright (C) 2009 Lukas Lalinsky
   Copyright (C) 2009 Oliver Charles

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

$(function() {

    function incrementLastPart(s) {
        var parts = s.split('.');
        parts[parts.length-1] = 1 + parseInt(parts[parts.length-1], 10);
        return parts.join('.');
    }

    function updateLinkType(select) {
        var id = select.options[select.selectedIndex].value;
        var message;
        var attrs;
        if (id) {
            var selected = typeInfo[id];
            if (selected.descr) {
                message = selected.descr;
            }
            else {
                message = MB.text.PleaseSelectARSubtype;
            }
            attrs = selected.attrs;
        }
        else {
            message = MB.text.PleaseSelectARType;
            attrs = {};
        }
        $('#type_descr').html(message);
        $('div.ar-attr').each(function() {
            var id = this.id.substr(13);
            var attrDiv = $(this);
            if (attrs[id]) {
                attrDiv.show();
                var attr = attrs[id];
                var selects = attrDiv.find('.selects');
                if (selects.length > 0) {
                    if (attr[1] == 1) {
                        selects.remove('div:not(:first)');
                        attrDiv.find('input:button').hide();
                    }
                    else {
                        attrDiv.find('input:button').show();
                    }
                }
            }
            else {
                attrDiv.hide();
            }
        });
    }

    function filterSelect($filter, direction) {
        var i, select = $filter.siblings('select')[0];
        var filterValue = $filter.val().toLowerCase();
        if (!direction) {
            i = 0;
            direction = 1;
        }
        else {
            i = select.selectedIndex + direction;
        }
        while (i >= 0 && i < select.options.length) {
            if (select.options[i].text.toLowerCase().indexOf(filterValue) != -1) {
                select.selectedIndex = i;
                return;
            }
            i += direction;
        }
    }

    $('div.ar-attr .selects').each(function() {
        var selects = $(this);
        var btn = $(MB.html.input({ type: 'button', value: MB.text.AddAnother} ));
        btn.click(function() {
            var lastDiv = selects.find('div:last');
            var lastSelectName = lastDiv.find('select').attr('name');
            var newSelectName = incrementLastPart(lastSelectName);
            var newDiv = lastDiv.clone();
            var newSelect = newDiv.find('select');
            newSelect.attr('name', newSelectName);
            newSelect.attr('id', 'id-' + newSelectName);
            newSelect.val('');
            selects.append(newDiv);
        });
        selects.after(btn);
        selects.find('div').each(function() {
            $(this).append(' ')
                .append(MB.html.a({ href: '#', 'class': 'selectFilterPrev' }, '&#9668'))
                .append(MB.html.input({ type: 'text', size: '7', 'class': 'selectFilter' }))
                .append(MB.html.a({ href: '#', 'class': 'selectFilterNext' }, '&#9658;'));
        });
    });

    $('a.selectFilterPrev').live('click', function() {
        var $input = $(this).siblings('input');
        $input.focus();
        filterSelect($input, -1);
        return false;
    });
    $('a.selectFilterNext').live('click', function() {
        var $input = $(this).siblings('input');
        $input.focus();
        filterSelect($input, 1);
        return false;
    });

    var KEY_UP = 37, KEY_LEFT = 38,
        KEY_DOWN = 40, KEY_RIGHT = 39;
    $('input.selectFilter').live('keyup', function(event) {
        var $input = $(this);
        if (event.keyCode == KEY_UP || event.keyCode == KEY_LEFT) {
            filterSelect($input, -1);
        }
        else if(event.keyCode == KEY_DOWN || event.keyCode == KEY_RIGHT) {
            filterSelect($input, 1);
        }
        else {
            filterSelect($input, 0);
        }
    });

    var linkTypeSelect = $("select[id='id-ar.link_type_id']");
    linkTypeSelect.change(function() { updateLinkType(this) });
    updateLinkType(linkTypeSelect[0]);

});
