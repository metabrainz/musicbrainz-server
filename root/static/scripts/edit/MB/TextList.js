/*
   This file is part of MusicBrainz, the open internet music database.
   Copyright (C) 2012 MetaBrainz Foundation

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

import $ from 'jquery';

import MB from '../../common/MB';

MB.Form = (MB.Form) ? MB.Form : {};

MB.Form.TextList = function (input) {
    var template = input + '-template';
    var self = {};
    var $template = $('.' + template.replace(/\./g, '\\.'));
    var counter = 0;

    var last_item = input;

    self.removeEvent = function (event) {
        $(this).closest('div.text-list-row').remove();
    };

    self.init = function (max_index) {
        counter = max_index;
        $template.parent()
            .find('div.text-list-row input.value')
            .siblings('button.remove-item')
            .bind('click.mb', self.removeEvent);

        return self;
    };

    self.add = function (init_value) {
        $template.clone()
            .removeClass(template)
            .insertAfter($template.parent().find('div.text-list-row').last())
            .show()
            .find('input.value').attr('name', input + '.' + counter).val(init_value)
            .end()
            .find('button.remove-item').bind('click.mb', self.removeEvent);

        counter++;

        return self;
    };

    $template.parent().find('button.add-item').bind('click.mb', function (event) {
        var parts = last_item.split('.');
        var field_name = parts.pop();
        var idx = parseInt(parts.pop(), 10) + 1;
        var prefix = parts.join('.') + '.' + idx + '.';
        self.add('');
    });

    return self;
};
