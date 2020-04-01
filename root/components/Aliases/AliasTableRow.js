/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import isolateText from '../../static/scripts/common/utility/isolateText';
import formatDate from '../../static/scripts/common/utility/formatDate';
import formatEndDate from '../../static/scripts/common/utility/formatEndDate';
import entityHref from '../../static/scripts/common/utility/entityHref';
import bracketed from '../../static/scripts/common/utility/bracketed';
import locales from '../../static/scripts/common/constants/locales';

type Props = {
  +alias: AliasT,
  +allowEditing: boolean,
  +entity: CoreEntityT,
  +row: string,
};

const AliasTableRow = ({alias, allowEditing, entity, row}: Props) => (
  <tr className={row}>
    <td colSpan={alias.name === alias.sort_name ? 2 : 1}>
      {alias.editsPending
        ? <span className="mp">{isolateText(alias.name)}</span>
        : isolateText(alias.name)}
    </td>
    {alias.name === alias.sort_name
      ? null
      : <td>{isolateText(alias.sort_name)}</td>}
    <td>{formatDate(alias.begin_date)}</td>
    <td>{formatEndDate(alias)}</td>
    <td>
      {alias.typeName ? lp_attributes(alias.typeName, 'alias_type') : ''}
    </td>
    <td>
      {alias.locale ? locales[alias.locale] : null}
      {alias.primary_for_locale
        ? (
          <>
            {' '}
            {bracketed(<span className="comment">{l('primary')}</span>)}
          </>
        )
        : null}
    </td>
    <td className="actions">
      {allowEditing
        ? (
          <>
            <a href={entityHref(entity, `/alias/${alias.id}/edit`)}>
              {lp('Edit', 'button/link')}
            </a>
            {' | '}
            <a href={entityHref(entity, `/alias/${alias.id}/delete`)}>
              {l('Remove')}
            </a>
          </>
        )
        : null
      }
    </td>
  </tr>
);

export default AliasTableRow;
