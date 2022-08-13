/*
 * @flow
 * Copyright (C) 2015 Ulrich Klauer
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import editDiff, {
  INSERT,
  EQUAL,
  CHANGE,
  CLASS_MAP,
  stringEditDiff,
  type EditType,
} from '../../utility/editDiff.js';

/*
 * The max string length before we fall back from generic-diff
 * to fast-diff (which doesn't support the custom 'split' prop!).
 */
const FAST_DIFF_FALLBACK_LENGTH = 1024;

function splitText(text: string, split: string = '') {
  if (split !== '') {
    split = '(' + split + ')';
  }
  // the capture group becomes a separate part of the split output
  return text.split(new RegExp(split, 'u'));
}

type Props = {
  +filter: EditType,
  +newText: string,
  +oldText: string,
  +split?: string,
};

const DiffSide = ({
  filter,
  newText,
  oldText,
  split = '',
}: Props): React.MixedElement | string => {
  const stack = [];
  const splitMatch = new RegExp('^(?:' + split + ')$');

  let diffs;
  if (
    split === '' ||
    oldText.length > FAST_DIFF_FALLBACK_LENGTH ||
    newText.length > FAST_DIFF_FALLBACK_LENGTH
  ) {
    diffs = stringEditDiff(
      oldText,
      newText,
    );
  } else {
    diffs = editDiff(
      splitText(oldText, split),
      splitText(newText, split),
    );
  }

  for (let i = 0; i < diffs.length; i++) {
    const diff = diffs[i];
    const changeType = diff.type;

    if (!(changeType === CHANGE ||
          changeType === EQUAL ||
          changeType === filter)) {
      continue;
    }

    oldText = diff.oldItems ? diff.oldItems.join('') : diff.oldText;
    newText = diff.newItems ? diff.newItems.join('') : diff.newText;

    const sameChangeTypeAsBefore = !!(
      stack.length && stack[stack.length - 1].type === changeType
    );

    let nextChangeType;
    if ((i + 1) < diffs.length) {
      nextChangeType = diffs[i + 1].type;
    }

    /*
     * If an unchanged separator is between two changed sections, mark
     * it like its surroundings; it looks nicer to humans when there is
     * no gap.
     */
    const isSeparatorBetweenChanges = !!(
      stack.length &&
      nextChangeType &&
      stack[stack.length - 1].type === nextChangeType &&
      split !== '' &&
      changeType === EQUAL &&
      splitMatch.test(newText)
    );

    if (!sameChangeTypeAsBefore && !isSeparatorBetweenChanges) {
      // start new section
      stack.push({text: '', type: changeType});
    }

    if (changeType === CHANGE) {
      stack[stack.length - 1].text += filter === INSERT ? newText : oldText;
    } else {
      stack[stack.length - 1].text += changeType === INSERT
        ? newText : oldText;
    }
  }

  const children = stack.map(change => {
    const className =
      change.type === CHANGE ? CLASS_MAP[filter] : CLASS_MAP[change.type];
    return className ? (
      <span className={className}>
        {change.text}
      </span>
    ) : change.text;
  });

  return children.length > 1 ? React.createElement(
    React.Fragment,
    null,
    ...children,
  ) : (children.length ? children[0] : '');
};

export default DiffSide;
