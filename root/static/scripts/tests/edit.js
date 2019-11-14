// This file is part of MusicBrainz, the open internet music database.
// Copyright (C) 2014 MetaBrainz Foundation
// Licensed under the GPL version 2, or (at your option) any later version:
// http://www.gnu.org/licenses/gpl-2.0.txt

import ko from 'knockout';
import test from 'tape';

import MB_edit from '../edit/MB/edit';

import '../edit/forms';

test('missing track numbers should be empty strings, not null (MBS-7246)', function (t) {
    t.plan(1);

    var data = MB_edit.fields.track({});

    t.equal(data.number, '', 'number is empty string');
});

test('loop binding keeps items in order when some are quickly removed and re-added (MBS-7751)', function (t) {
    t.plan(3);

    var parentNode = document.createElement('div'),
        childNode = document.createElement('span');

    parentNode.setAttribute('data-bind', "loop: { items: items, id: 'id' }");
    childNode.setAttribute('data-bind', 'text: id');
    parentNode.appendChild(childNode);

    var item1 = {id: 1},
        item2 = {id: 2},
        item3 = {id: 3},
        vm = {items: ko.observableArray([item1, item2, item3])};

    ko.applyBindings(vm, parentNode);

    vm.items.removeAll([item1, item2]);
    vm.items([item1, item2, item3]);

    var childNodes = parentNode.childNodes;
    t.equal(childNodes[0].textContent, '1');
    t.equal(childNodes[1].textContent, '2');
    t.equal(childNodes[2].textContent, '3');
});
