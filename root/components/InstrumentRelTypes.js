/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {commaOnlyListText}
  from '../static/scripts/common/i18n/commaOnlyList.js';
import {bracketedText} from '../static/scripts/common/utility/bracketed.js';

type Props = {
  ...InstrumentCreditsAndRelTypesRoleT,
  +entity: ArtistT | RecordingT | ReleaseT,
};

const InstrumentRelTypes = ({
  entity,
  instrumentCreditsAndRelTypes,
}: Props): string | null => (
  instrumentCreditsAndRelTypes &&
    instrumentCreditsAndRelTypes[entity.gid] ? (
      commaOnlyListText(
        instrumentCreditsAndRelTypes[entity.gid].map(json => {
          const relType = JSON.parse(json);
          let listElement = l_relationships(relType.typeName);
          if (relType.credit) {
            listElement = listElement + ' ' +
              bracketedText(texp.l(
                'as “{credit}”',
                {credit: relType.credit},
              ));
          }
          return listElement;
        }),
      )
    ) : null
);

export default InstrumentRelTypes;
