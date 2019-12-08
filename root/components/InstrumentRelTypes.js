/*
 * @flow
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import {commaOnlyListText} from '../static/scripts/common/i18n/commaOnlyList';
import {bracketedText} from '../static/scripts/common/utility/bracketed';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  +entity: RecordingT | ReleaseT,
};

const InstrumentRelTypes = ({
  entity,
  instrumentCreditsAndRelTypes,
}: Props) => (
  <td>
    {instrumentCreditsAndRelTypes &&
      instrumentCreditsAndRelTypes[entity.gid] ? (
        commaOnlyListText(
          instrumentCreditsAndRelTypes[entity.gid].map(json => {
            const relType = JSON.parse(json);
            let listElement = l_relationships(relType.name);
            if (relType.credit) {
              listElement = listElement + ' ' +
                bracketedText(texp.l('as “{credit}”', {credit: relType.credit}));
            }
            return listElement;
          }),
        )
      ) : null}
  </td>
);

export default InstrumentRelTypes;
