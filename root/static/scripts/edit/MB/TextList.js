/*
 * Copyright (C) 2012 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
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
            .find('input.value').attr("name", input + '.' + counter).val(init_value)
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
