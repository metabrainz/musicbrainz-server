/*
 * Copyright (C) 2014 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import ko from 'knockout';
import test from 'tape';

import mbEdit from '../edit/MB/edit';

import '../edit/forms';

test((
  'missing track numbers should be empty strings, not null (MBS-7246)'
), function (t) {
  t.plan(1);

  const data = mbEdit.fields.track({});

  t.equal(data.number, '', 'number is empty string');
});

test((
  'loop binding keeps items in order when some are quickly removed and re-added (MBS-7751)'
), function (t) {
  t.plan(3);

  const parentNode = document.createElement('div');
  const childNode = document.createElement('span');

  parentNode.setAttribute('data-bind', "loop: { items: items, id: 'id' }");
  childNode.setAttribute('data-bind', 'text: id');
  parentNode.appendChild(childNode);

  const item1 = {id: 1};
  const item2 = {id: 2};
  const item3 = {id: 3};
  const vm = {items: ko.observableArray([item1, item2, item3])};

  ko.applyBindings(vm, parentNode);

  vm.items.removeAll([item1, item2]);
  vm.items([item1, item2, item3]);

  const childNodes = parentNode.childNodes;
  t.equal(childNodes[0].textContent, '1');
  t.equal(childNodes[1].textContent, '2');
  t.equal(childNodes[2].textContent, '3');
});
