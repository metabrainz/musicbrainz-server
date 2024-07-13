/*
 * @flow strict-local
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import test from 'tape';

import {
  createInitialState,
} from '../common/components/Autocomplete2.js';
import reducer from '../common/components/Autocomplete2/reducer.js';

const makeItem = (id: number, name: string) => ({
  disabled: true,
  entity: {
    child_order: 0,
    creditable: false,
    description: '',
    entityType: 'link_attribute_type',
    free_text: false,
    gid: '',
    id,
    name: name,
    parent_id: null,
    root_gid: '',
    root_id: id,
  },
  id,
  level: 0,
  name: name,
  type: 'option',
});

test('Autocomplete items are updated on input focus', function (t) {
  t.plan(4);
  const item = makeItem(1, 'foo');
  const state = reducer({
    ...createInitialState<LinkAttrTypeT>({
      entityType: 'link_attribute_type',
      id: 'attribute-type-test',
    }),
    recentItems: [item],
  }, {isFocused: true, type: 'set-input-focus'});
  t.equals(state.isInputFocused, true, 'input is focused');
  t.ok(state.items.length, 'items is non-empty');
  t.equals(state.items?.[0]?.id, 'recent-items-header', 'items contains recent items header');
  t.equals(state.items?.[1], item, 'items contains recent item');
});
