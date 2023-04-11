/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import formatEntityTypeName
  from '../../common/utility/formatEntityTypeName.js';
import type {TargetTypeOptionsT} from '../types.js';
import type {
  DialogActionT,
} from '../types/actions.js';

/* eslint-enable flowtype/sort-keys */

type PropsT = {
  +dispatch: (DialogActionT) => void,
  +hasPreselectedTargetType: boolean,
  +options: ?TargetTypeOptionsT,
  +source: RelatableEntityT,
  +targetType: RelatableEntityTypeT,
};

const DialogTargetType = (React.memo<PropsT>((
  props: PropsT,
): React$MixedElement => {
  const {
    dispatch,
    hasPreselectedTargetType,
    options,
    source,
    targetType,
  } = props;

  function handleTargetTypeChange(event: SyntheticEvent<HTMLSelectElement>) {
    dispatch({
      source,
      // $FlowIgnore[unclear-type]
      targetType: (event.currentTarget.value: any),
      type: 'update-target-type',
    });
  }

  return (
    <tr>
      <td className="required section">
        {l('Related type')}
      </td>
      <td className="fields">
        {options == null ? (
          formatEntityTypeName(targetType)
        ) : (
          <select
            className={
              'entity-type' +
              (hasPreselectedTargetType ? '' : ' focus-first')
            }
            onChange={handleTargetTypeChange}
            value={targetType}
          >
            {options.map((option) => (
              <option key={option.value} value={option.value}>
                {option.text}
              </option>
            ))}
          </select>
        )}
      </td>
    </tr>
  );
}): React$AbstractComponent<PropsT, mixed>);

export default DialogTargetType;
